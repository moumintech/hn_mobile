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
  final bool rappelActif;

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
    this.rappelActif = false,
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
      rappelActif: json['rappel_actif'] != null
          ? (json['rappel_actif'].toString() == '1' || json['rappel_actif'] == true)
          : false,
    );
  }

  RendezVous copyWith({bool? rappelActif}) {
    return RendezVous(
      idRdv: idRdv,
      dateRdv: dateRdv,
      heureRdv: heureRdv,
      statut: statut,
      specialisteNom: specialisteNom,
      specialistePrenom: specialistePrenom,
      specialite: specialite,
      etablissementNom: etablissementNom,
      adresse: adresse,
      rappelActif: rappelActif ?? this.rappelActif,
    );
  }

  // ── SQLite ────────────────────────────────────────────────────────────────

  /// Convertit l'objet en Map pour SQLite.
  Map<String, dynamic> toMap() => {
        'id_rdv': idRdv,
        'date_rdv': dateRdv,
        'heure_rdv': heureRdv,
        'statut': statut,
        'specialiste_nom': specialisteNom,
        'specialiste_prenom': specialistePrenom,
        'specialite': specialite,
        'etablissement_nom': etablissementNom,
        'adresse': adresse,
        'rappel_actif': rappelActif ? 1 : 0,
      };

  /// Construit un [RendezVous] depuis une ligne SQLite.
  factory RendezVous.fromMap(Map<String, dynamic> map) => RendezVous(
        idRdv: map['id_rdv'] as int,
        dateRdv: map['date_rdv'] as String?,
        heureRdv: map['heure_rdv'] as String?,
        statut: map['statut'] as String?,
        specialisteNom: map['specialiste_nom'] as String?,
        specialistePrenom: map['specialiste_prenom'] as String?,
        specialite: map['specialite'] as String?,
        etablissementNom: map['etablissement_nom'] as String?,
        adresse: map['adresse'] as String?,
        rappelActif: (map['rappel_actif'] as int? ?? 0) == 1,
      );
}
