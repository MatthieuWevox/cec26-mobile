import 'member.dart';

class Guest {
  final int id;
  final String nom;
  final String prenom;
  final String? nomEntreprise;
  final Member? invitedBy;
  final String createdAt;
  final String updatedAt;

  const Guest({
    required this.id,
    required this.nom,
    required this.prenom,
    this.nomEntreprise,
    this.invitedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$prenom $nom';

  factory Guest.fromJson(Map<String, dynamic> json) {
    return Guest(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      nomEntreprise: json['nom_entreprise'] as String?,
      invitedBy: json['invited_by'] != null
          ? Member.fromJson(json['invited_by'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}

class Meeting {
  final int id;
  final String date;
  final String heure;
  final String adresse;
  final String? ordreDuJour;
  final String? compteRendu;
  final String createdAt;
  final String updatedAt;
  final List<Guest> guests;

  const Meeting({
    required this.id,
    required this.date,
    required this.heure,
    required this.adresse,
    this.ordreDuJour,
    this.compteRendu,
    required this.createdAt,
    required this.updatedAt,
    required this.guests,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] as int,
      date: json['date'] as String,
      heure: json['heure'] as String,
      adresse: json['adresse'] as String,
      ordreDuJour: json['ordre_du_jour'] as String?,
      compteRendu: json['compte_rendu'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      guests: json['guests'] != null
          ? (json['guests'] as List)
              .map((g) => Guest.fromJson(g as Map<String, dynamic>))
              .toList()
          : [],
    );
  }
}
