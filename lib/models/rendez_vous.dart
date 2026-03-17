class RendezVous {
  final int idRdv;
  final String? dateRdv;
  final String? heureRdv;
  final String? statut;
  final String? specialisteNom;
  final String? specialistePrenom;
  final String? specialite;
  final String? etablissementNom;
  final String? adresse;

  RendezVous({
    required this.idRdv,
    this.dateRdv,
    this.heureRdv,
    this.statut,
    this.specialisteNom,
    this.specialistePrenom,
    this.specialite,
    this.etablissementNom,
    this.adresse,
  });

  factory RendezVous.fromJson(Map<String, dynamic> json) {
    return RendezVous(
      idRdv: int.parse(json['id_rdv'].toString()),
      dateRdv: json['date_rdv']?.toString(),
      heureRdv: json['heure_rdv']?.toString(),
      statut: json['statut'],
      specialisteNom: json['specialiste_nom'],
      specialistePrenom: json['specialiste_prenom'],
      specialite: json['specialite'],
      etablissementNom: json['etablissement_nom'],
      adresse: json['adresse'],
    );
  }
}