class News {
  final int id;
  final String titre;
  final String sousTitre;
  final String statut;
  final String contenu;
  final String createdAt;
  final String updatedAt;

  const News({
    required this.id,
    required this.titre,
    required this.sousTitre,
    required this.statut,
    required this.contenu,
    required this.createdAt,
    required this.updatedAt,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'] as int,
      titre: json['titre'] as String,
      sousTitre: (json['sous_titre'] as String?) ?? '',
      statut: (json['statut'] as String?) ?? '',
      contenu: (json['contenu'] as String?) ?? '',
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}
