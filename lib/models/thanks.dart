import 'member.dart';

class Thanks {
  final int id;
  final String? description;
  final String montantHt;
  final String dateAffaire;
  final int remerciantId;
  final int remercieId;
  final String createdAt;
  final String updatedAt;
  final Member? remerciant;
  final Member? remercie;

  const Thanks({
    required this.id,
    this.description,
    required this.montantHt,
    required this.dateAffaire,
    required this.remerciantId,
    required this.remercieId,
    required this.createdAt,
    required this.updatedAt,
    this.remerciant,
    this.remercie,
  });

  factory Thanks.fromJson(Map<String, dynamic> json) {
    return Thanks(
      id: json['id'] as int,
      description: json['description'] as String?,
      montantHt: (json['montant_ht'] ?? '0.00').toString(),
      dateAffaire: json['date_affaire'] as String,
      remerciantId: json['remerciant_id'] as int,
      remercieId: json['remercie_id'] as int,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      remerciant: json['remerciant'] != null
          ? Member.fromJson(json['remerciant'] as Map<String, dynamic>)
          : null,
      remercie: json['remercie'] != null
          ? Member.fromJson(json['remercie'] as Map<String, dynamic>)
          : null,
    );
  }
}
