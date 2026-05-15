class RappelMedicament {
  final int idRappel;
  final String? heure;
  final bool actif;
  final int? idLigne;
  final String? medicament;
  final String? dosage;
  final String? frequence;
  final String? duree;

  RappelMedicament({
    required this.idRappel,
    this.heure,
    required this.actif,
    this.idLigne,
    this.medicament,
    this.dosage,
    this.frequence,
    this.duree,
  });

  factory RappelMedicament.fromJson(Map<String, dynamic> json) {
    return RappelMedicament(
      idRappel:   int.parse(json['id_rappel'].toString()),
      heure:      json['heure']?.toString(),
      actif:      json['actif'].toString() == '1' || json['actif'] == true,
      idLigne:    json['id_ligne'] == null ? null : int.parse(json['id_ligne'].toString()),
      medicament: json['medicament'],
      dosage:     json['dosage'],
      frequence:  json['frequence'],
      duree:      json['duree'],
    );
  }

  // ── SQLite ────────────────────────────────────────────────────────────────

  Map<String, dynamic> toMap() => {
        'id_rappel': idRappel,
        'heure': heure,
        'actif': actif ? 1 : 0,
        'id_ligne': idLigne,
        'medicament': medicament,
        'dosage': dosage,
        'frequence': frequence,
        'duree': duree,
      };

  factory RappelMedicament.fromMap(Map<String, dynamic> map) =>
      RappelMedicament(
        idRappel:   map['id_rappel'] as int,
        heure:      map['heure'] as String?,
        actif:      (map['actif'] as int? ?? 1) == 1,
        idLigne:    map['id_ligne'] as int?,
        medicament: map['medicament'] as String?,
        dosage:     map['dosage'] as String?,
        frequence:  map['frequence'] as String?,
        duree:      map['duree'] as String?,
      );
}
