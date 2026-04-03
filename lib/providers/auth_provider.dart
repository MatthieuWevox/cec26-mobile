import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/member.dart';
import '../services/api_service.dart';

const _kTokenKey = 'auth_token';
const _kMemberKey = 'member_data';

class AuthProvider extends ChangeNotifier {
  String? _token;
  Member? _currentMember;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  Member? get currentMember => _currentMember;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ApiService get _api => ApiService(authToken: _token);

  /// Persist member data to local storage.
  Future<void> _saveMember(Member? member) async {
    final prefs = await SharedPreferences.getInstance();
    if (member != null) {
      await prefs.setString(_kMemberKey, jsonEncode(member.toJson()));
    } else {
      await prefs.remove(_kMemberKey);
    }
  }

  /// Restore session from local storage on app start.
  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString(_kTokenKey);
    if (savedToken == null || savedToken.isEmpty) return;

    _token = savedToken;

    // Restore member from local cache first
    final savedMember = prefs.getString(_kMemberKey);
    if (savedMember != null && savedMember.isNotEmpty) {
      try {
        _currentMember =
            Member.fromJson(jsonDecode(savedMember) as Map<String, dynamic>);
      } catch (_) {}
    }
    notifyListeners();

    // Then refresh from API in background
    try {
      _currentMember = await _api.getProfile();
      await _saveMember(_currentMember);
      notifyListeners();
    } catch (_) {
      // Keep cached data — don't clear session on network error
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final publicApi = const ApiService();
      final data = await publicApi.login(email, password);
      _token = data['token'] as String?;
      if (data['member'] != null) {
        _currentMember =
            Member.fromJson(data['member'] as Map<String, dynamic>);
      }
      final prefs = await SharedPreferences.getInstance();
      if (_token != null) {
        await prefs.setString(_kTokenKey, _token!);
        await _saveMember(_currentMember);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Impossible de se connecter. Vérifiez votre connexion internet.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    if (_token != null) {
      try {
        await _api.logout();
      } catch (_) {}
    }
    _token = null;
    _currentMember = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTokenKey);
    await prefs.remove(_kMemberKey);
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? nom,
    String? prenom,
    String? telephone,
    String? presentation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final updated = await _api.updateProfile(
        nom: nom,
        prenom: prenom,
        telephone: telephone,
        presentation: presentation,
      );
      _currentMember = updated;
      await _saveMember(_currentMember);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Erreur lors de la mise à jour du profil.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _api.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: confirmation,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = 'Erreur lors du changement de mot de passe.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCompany({
    String? nom,
    String? sousTitre,
    String? activites,
    String? description,
    String? logoUrl,
    String? photoUrl,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final company = await _api.updateCompany(
        nom: nom,
        sousTitre: sousTitre,
        activites: activites,
        description: description,
        logoUrl: logoUrl,
        photoUrl: photoUrl,
      );
      if (_currentMember != null) {
        _currentMember = Member(
          id: _currentMember!.id,
          nom: _currentMember!.nom,
          prenom: _currentMember!.prenom,
          email: _currentMember!.email,
          telephone: _currentMember!.telephone,
          presentation: _currentMember!.presentation,
          companyId: _currentMember!.companyId,
          createdAt: _currentMember!.createdAt,
          updatedAt: _currentMember!.updatedAt,
          company: company,
        );
      }
      await _saveMember(_currentMember);
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      _error = "Erreur lors de la mise à jour de l'entreprise.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
