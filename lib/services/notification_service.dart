import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/private/recommendations_screen.dart';
import '../screens/private/thanks_screen.dart';
import '../models/notification_target.dart';
import '../screens/meetings/meeting_notification_screen.dart';
import 'api_service.dart';

const _kInstallIdKey = 'push_install_id';
const _kAuthTokenKey = 'auth_token';
const _kNotificationChannelId = 'cec_notifications';

enum PushRegistrationStatus {
  idle,
  registering,
  registered,
  denied,
  retryPending,
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
  } catch (_) {}
}

class NotificationService {
  NotificationService._();

  static final navigatorKey = GlobalKey<NavigatorState>();
  static final _messaging = FirebaseMessaging.instance;
  static final _localNotifications = FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static bool _registering = false;
  static int _sessionEpoch = 0;
  static int _retryCount = 0;
  static Timer? _retryTimer;
  static final registrationStatus = ValueNotifier(PushRegistrationStatus.idle);
  static Map<String, dynamic>? _pendingNavigationData;

  static Future<void> initialize() async {
    if (_initialized || kIsWeb) return;

    if (Firebase.apps.isEmpty) await Firebase.initializeApp();

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        _openPayload(response.payload);
      },
    );

    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      _openPayload(launchDetails?.notificationResponse?.payload);
    }

    const androidChannel = AndroidNotificationChannel(
      _kNotificationChannelId,
      'Notifications CEC',
      description: 'Recommandations, remerciements et réunions',
      importance: Importance.high,
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(androidChannel);

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_openMessage);
    try {
      final message = await _messaging.getInitialMessage();
      if (message != null) _openMessage(message);
    } catch (error) {
      if (kDebugMode) debugPrint('FCM initial message error: $error');
    }

    _messaging.onTokenRefresh.listen((token) async {
      if (kDebugMode) debugPrint('FCM TOKEN REFRESHED: $token');

      await syncCurrentSession();
    });

    _initialized = true;
    WidgetsBinding.instance.addObserver(_NotificationLifecycle());
    if (kDebugMode) unawaited(_printCurrentToken());
  }

  static Future<void> _printCurrentToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null || token.isEmpty) {
        debugPrint('FCM TOKEN: aucun token disponible');
        return;
      }

      debugPrint('FCM TOKEN: $token');
    } catch (error) {
      debugPrint('FCM TOKEN ERROR: $error');
    }
  }

  static Future<void> requestPermissionAndRegister(ApiService api) async {
    if (kIsWeb) return;
    await _sync(api, prompt: true);
  }

  static Future<void> syncCurrentSession() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString(_kAuthTokenKey);
    if (authToken == null || authToken.isEmpty) return;
    await _sync(ApiService(authToken: authToken), prompt: false);
  }

  static Future<void> _sync(ApiService api, {required bool prompt}) async {
    if (_registering) return;
    _registering = true;
    final epoch = _sessionEpoch;
    registrationStatus.value = PushRegistrationStatus.registering;
    try {
      await initialize();
      final settings = prompt
          ? await _messaging.requestPermission(
              alert: true,
              badge: true,
              sound: true,
            )
          : await _messaging.getNotificationSettings();
      if (epoch != _sessionEpoch) return;
      if (settings.authorizationStatus == AuthorizationStatus.denied ||
          settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        registrationStatus.value = PushRegistrationStatus.denied;
        _retryTimer?.cancel();
        return;
      }
      if (!await _waitForApnsToken()) {
        throw StateError('APNs token unavailable');
      }
      final token = await _messaging.getToken().timeout(
        const Duration(seconds: 15),
      );
      if (token == null || token.isEmpty) {
        throw StateError('FCM token unavailable');
      }
      if (epoch != _sessionEpoch) return;
      await _registerToken(api, token).timeout(const Duration(seconds: 20));
      if (epoch != _sessionEpoch) return;
      _retryCount = 0;
      _retryTimer?.cancel();
      registrationStatus.value = PushRegistrationStatus.registered;
    } catch (error) {
      if (epoch != _sessionEpoch) return;
      registrationStatus.value = PushRegistrationStatus.retryPending;
      if (kDebugMode) debugPrint('FCM registration failed: $error');
      _retryTimer?.cancel();
      if (_retryCount < 5) {
        _retryTimer = Timer(Duration(seconds: 5 * (1 << _retryCount++)), () {
          unawaited(syncCurrentSession());
        });
      }
    } finally {
      _registering = false;
      if (epoch != _sessionEpoch) unawaited(syncCurrentSession());
    }
  }

  static void clearSession() {
    _sessionEpoch++;
    _retryTimer?.cancel();
    _retryCount = 0;
    _pendingNavigationData = null;
    registrationStatus.value = PushRegistrationStatus.idle;
  }

  static Future<void> deleteCurrentToken(ApiService api) async {
    if (kIsWeb) return;

    final token = await _messaging.getToken();
    if (token == null || token.isEmpty) return;

    try {
      await api
          .deletePushToken(token: token)
          .timeout(const Duration(seconds: 15));
    } finally {
      await _messaging.deleteToken();
    }
  }

  static Future<void> _registerToken(ApiService api, String token) async {
    final prefs = await SharedPreferences.getInstance();
    final installId = await _getInstallId(prefs);

    await api.registerPushToken(
      token: token,
      platform: Platform.isIOS ? 'ios' : 'android',
      deviceId: installId,
    );
  }

  static Future<String> _getInstallId(SharedPreferences prefs) async {
    final saved = prefs.getString(_kInstallIdKey);
    if (saved != null && saved.isNotEmpty) return saved;

    final random = Random.secure().nextInt(1 << 32);
    final installId = '${DateTime.now().microsecondsSinceEpoch}-$random';
    await prefs.setString(_kInstallIdKey, installId);
    return installId;
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    // iOS displays foreground notifications through the presentation options
    // configured above. Creating a local notification as well would duplicate it.
    if (Platform.isIOS || Platform.isMacOS) return;

    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      _kNotificationChannelId,
      'Notifications CEC',
      channelDescription: 'Recommandations, remerciements et réunions',
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
  }

  static void _openMessage(RemoteMessage message) {
    _openData(message.data);
  }

  static void _openPayload(String? payload) {
    if (payload == null || payload.isEmpty) return;

    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      _openData(data.map((key, value) => MapEntry(key, value.toString())));
    } catch (_) {}
  }

  static void _openData(Map<String, dynamic> data) {
    final type = data['type']?.toString();
    final target = NotificationTarget.fromData(data);
    if (target == null) return;
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingNavigationData = Map<String, dynamic>.from(data);
      return;
    }

    SharedPreferences.getInstance().then((preferences) {
      final authToken = preferences.getString(_kAuthTokenKey);
      if (target.requiresAuthentication &&
          (authToken == null || authToken.isEmpty)) {
        _pendingNavigationData = Map<String, dynamic>.from(data);
        return;
      }

      _navigateToNotification(type, data);
    });
  }

  static void _navigateToNotification(String? type, Map<String, dynamic> data) {
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      _pendingNavigationData = Map<String, dynamic>.from(data);
      return;
    }

    _pendingNavigationData = null;

    if (type == 'recommendation') {
      navigator.push(
        MaterialPageRoute(builder: (_) => const RecommendationsScreen()),
      );
    } else if (type == 'thanks') {
      navigator.push(MaterialPageRoute(builder: (_) => const ThanksScreen()));
    } else if (type == 'meeting') {
      final target = NotificationTarget.fromData(data);
      if (target?.id != null) {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => MeetingNotificationScreen(meetingId: target!.id!),
          ),
        );
      }
    }
  }

  static void handlePendingNavigation() {
    final data = _pendingNavigationData;
    if (data == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (navigatorKey.currentState != null) _openData(data);
    });
  }

  static Future<bool> _waitForApnsToken() async {
    if (!Platform.isIOS && !Platform.isMacOS) return true;

    for (var attempt = 0; attempt < 20; attempt++) {
      if (await _messaging.getAPNSToken() != null) return true;
      await Future<void>.delayed(const Duration(milliseconds: 500));
    }
    return false;
  }
}

class _NotificationLifecycle extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(NotificationService.syncCurrentSession());
      NotificationService.handlePendingNavigation();
    }
  }
}
