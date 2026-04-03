import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/member.dart';
import '../models/news.dart';
import '../models/meeting.dart';
import '../models/recommendation.dart';
import '../models/thanks.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiException(this.message, {this.statusCode, this.errors});

  @override
  String toString() => message;
}

class ApiService {
  final String? _authToken;

  const ApiService({String? authToken}) : _authToken = authToken;

  Map<String, String> get _headers {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  Future<dynamic> _get(String url) async {
    final response = await http.get(Uri.parse(url), headers: _headers);
    return _handleResponse(response);
  }

  Future<dynamic> _post(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> _put(String url, Map<String, dynamic> body) async {
    final response = await http.put(
      Uri.parse(url),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (body.isEmpty) return null;
      return jsonDecode(body);
    }
    Map<String, dynamic>? errorBody;
    String message = 'Une erreur est survenue.';
    try {
      errorBody = jsonDecode(body) as Map<String, dynamic>;
      message = (errorBody['message'] as String?) ?? message;
    } catch (_) {}
    throw ApiException(
      message,
      statusCode: response.statusCode,
      errors: errorBody?['errors'] as Map<String, dynamic>?,
    );
  }

  // ─── Authentication ────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> login(String email, String password) async {
    final data = await _post(ApiConfig.login, {
      'email': email,
      'password': password,
    });
    return data as Map<String, dynamic>;
  }

  Future<void> logout() async {
    await _post(ApiConfig.logout, {});
  }

  // ─── Public routes ─────────────────────────────────────────────────────────

  Future<List<News>> getNews() async {
    final data = await _get(ApiConfig.news);
    return (data as List).map((e) => News.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Meeting>> getMeetings() async {
    final data = await _get(ApiConfig.meetings);
    return (data as List)
        .map((e) => Meeting.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Company>> getCompanies() async {
    final data = await _get(ApiConfig.companies);
    return (data as List)
        .map((e) => Company.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Member>> getMembers() async {
    final data = await _get(ApiConfig.members);
    return (data as List)
        .map((e) => Member.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ─── Private routes ────────────────────────────────────────────────────────

  Future<Member> getProfile() async {
    final data = await _get(ApiConfig.me);
    return Member.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Recommendation>> getRecommendationsReceived() async {
    final data = await _get(ApiConfig.recommendationsReceived);
    return (data as List)
        .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Recommendation>> getRecommendationsSent() async {
    final data = await _get(ApiConfig.recommendationsSent);
    return (data as List)
        .map((e) => Recommendation.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Recommendation> createRecommendation({
    required int recommandeId,
    required String nomContact,
    required String prenomContact,
    String? telephone,
    String? email,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'recommande_id': recommandeId,
      'nom_contact': nomContact,
      'prenom_contact': prenomContact,
    };
    if (telephone != null && telephone.isNotEmpty) body['telephone'] = telephone;
    if (email != null && email.isNotEmpty) body['email'] = email;
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    final data = await _post(ApiConfig.recommendations, body);
    return Recommendation.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Thanks>> getThanksReceived() async {
    final data = await _get(ApiConfig.thanksReceived);
    return (data as List)
        .map((e) => Thanks.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Thanks>> getThanksSent() async {
    final data = await _get(ApiConfig.thanksSent);
    return (data as List)
        .map((e) => Thanks.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Thanks> createThanks({
    required int remercieId,
    required String montantHt,
    required String dateAffaire,
    String? description,
  }) async {
    final body = <String, dynamic>{
      'remercie_id': remercieId,
      'montant_ht': montantHt,
      'date_affaire': dateAffaire,
    };
    if (description != null && description.isNotEmpty) {
      body['description'] = description;
    }
    final data = await _post(ApiConfig.thanks, body);
    return Thanks.fromJson(data as Map<String, dynamic>);
  }

  Future<Member> updateProfile({
    String? nom,
    String? prenom,
    String? telephone,
    String? presentation,
  }) async {
    final body = <String, dynamic>{};
    if (nom != null) body['nom'] = nom;
    if (prenom != null) body['prenom'] = prenom;
    if (telephone != null) body['telephone'] = telephone;
    if (presentation != null) body['presentation'] = presentation;
    final data = await _put(ApiConfig.me, body);
    return Member.fromJson(data as Map<String, dynamic>);
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    await _put(ApiConfig.mePassword, {
      'current_password': currentPassword,
      'password': newPassword,
      'password_confirmation': newPasswordConfirmation,
    });
  }

  Future<Company> updateCompany({
    String? nom,
    String? sousTitre,
    String? activites,
    String? description,
    String? logoUrl,
    String? photoUrl,
  }) async {
    final body = <String, dynamic>{};
    if (nom != null) body['nom'] = nom;
    if (sousTitre != null) body['sous_titre'] = sousTitre;
    if (activites != null) body['activites'] = activites;
    if (description != null) body['description'] = description;
    if (logoUrl != null) body['logo_url'] = logoUrl;
    if (photoUrl != null) body['photo_url'] = photoUrl;
    final data = await _put(ApiConfig.meCompany, body);
    return Company.fromJson(data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> addGuestToMeeting({
    required int meetingId,
    required String nom,
    required String prenom,
    String? nomEntreprise,
  }) async {
    final body = <String, dynamic>{'nom': nom, 'prenom': prenom};
    if (nomEntreprise != null && nomEntreprise.isNotEmpty) {
      body['nom_entreprise'] = nomEntreprise;
    }
    final data = await _post(ApiConfig.meetingGuests(meetingId), body);
    return data as Map<String, dynamic>;
  }
}
