import 'member.dart';

class Recommendation {
  final int id;
  final String nomContact;
  final String prenomContact;
  final String? telephone;
  final String? email;
  final String? description;
  final int recommandateurId;
  final int recommandeId;
  final String createdAt;
  final String updatedAt;
  final Member? recommandateur;
  final Member? recommande;

  const Recommendation({
    required this.id,
    required this.nomContact,
    required this.prenomContact,
    this.telephone,
    this.email,
    this.description,
    required this.recommandateurId,
    required this.recommandeId,
    required this.createdAt,
    required this.updatedAt,
    this.recommandateur,
    this.recommande,
  });

  String get contactFullName => '$prenomContact $nomContact';

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      id: json['id'] as int,
      nomContact: json['nom_contact'] as String,
      prenomContact: json['prenom_contact'] as String,
      telephone: json['telephone'] as String?,
      email: json['email'] as String?,
      description: json['description'] as String?,
      recommandateurId: json['recommandateur_id'] as int,
      recommandeId: json['recommande_id'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      recommandateur: json['recommandateur'] != null
          ? Member.fromJson(json['recommandateur'] as Map<String, dynamic>)
          : null,
      recommande: json['recommande'] != null
          ? Member.fromJson(json['recommande'] as Map<String, dynamic>)
          : null,
    );
  }
}
