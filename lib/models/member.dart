class Company {
  final int id;
  final String nom;
  final String? sousTitre;
  final String? activites;
  final String? description;
  final String? logoUrl;
  final String? photoUrl;
  final String createdAt;
  final String updatedAt;
  final List<Member>? members;

  const Company({
    required this.id,
    required this.nom,
    this.sousTitre,
    this.activites,
    this.description,
    this.logoUrl,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    this.members,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int,
      nom: json['nom'] as String,
      sousTitre: json['sous_titre'] as String?,
      activites: json['activites'] as String?,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      members: json['members'] != null
          ? (json['members'] as List)
              .map((m) => Member.fromJson(m as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (nom.isNotEmpty) 'nom': nom,
      if (sousTitre != null) 'sous_titre': sousTitre,
      if (activites != null) 'activites': activites,
      if (description != null) 'description': description,
      if (logoUrl != null) 'logo_url': logoUrl,
      if (photoUrl != null) 'photo_url': photoUrl,
    };
  }
}

class Member {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String? presentation;
  final int? companyId;
  final String createdAt;
  final String updatedAt;
  final Company? company;

  const Member({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    this.presentation,
    this.companyId,
    required this.createdAt,
    required this.updatedAt,
    this.company,
  });

  String get fullName => '$prenom $nom';

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String?,
      presentation: json['presentation'] as String?,
      companyId: json['company_id'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      company: json['company'] != null
          ? Company.fromJson(json['company'] as Map<String, dynamic>)
          : null,
    );
  }
}
