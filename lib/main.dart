import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'providers/auth_provider.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks([
      'Manrope',
    ], await rootBundle.loadString('assets/fonts/OFL-Manrope.txt'));
  });
  await _initializeFirebase();
  await initializeDateFormatting('fr_FR', null);
  runApp(const CecApp());
}

Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    await NotificationService.initialize();
  } catch (error) {
    debugPrint('Firebase non initialise: $error');
  }
}

class CecApp extends StatelessWidget {
  const CecApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..restoreSession(),
      child: MaterialApp(
        navigatorKey: NotificationService.navigatorKey,
        title: 'CEC 2026',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeAnimationDuration: AppTheme.motion,
        themeAnimationCurve: AppTheme.motionCurve,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
        home: const MainScreen(),
      ),
    );
  }
}
