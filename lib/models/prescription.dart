class LigneMedicament {
  final int? idLigne;
  final String? medicament;
  final String? dosage;
  final String? frequence;
  final String? duree;

  LigneMedicament({
    this.idLigne,
    this.medicament,
    this.dosage,
    this.frequence,
    this.duree,
  });

  factory LigneMedicament.fromJson(Map<String, dynamic> json) {
    return LigneMedicament(
      idLigne:    json['id_ligne'] == null ? null : int.tryParse(json['id_ligne'].toString()),
      medicament: json['medicament']?.toString(),
      dosage:     json['dosage']?.toString(),
      frequence:  json['frequence']?.toString(),
      duree:      json['duree']?.toString(),
    );
  }

  // ── SQLite ────────────────────────────────────────────────────────────────

  /// [idOrdonnance] est fourni par la prescription parente lors de l'insertion.
  Map<String, dynamic> toMap(int idOrdonnance) => {
        if (idLigne != null) 'id_ligne': idLigne,
        'id_ordonnance': idOrdonnance,
        'medicament': medicament,
        'dosage': dosage,
        'frequence': frequence,
        'duree': duree,
      };

  factory LigneMedicament.fromMap(Map<String, dynamic> map) => LigneMedicament(
        idLigne:    map['id_ligne'] as int?,
        medicament: map['medicament'] as String?,
        dosage:     map['dosage'] as String?,
        frequence:  map['frequence'] as String?,
        duree:      map['duree'] as String?,
      );
}

class Prescription {
  final int    idOrdonnance;
  final String? datePrescription;
  final String? instructionsGenerales;
  final bool   estValide;
  final List<LigneMedicament> medicaments;

  Prescription({
    required this.idOrdonnance,
    this.datePrescription,
    this.instructionsGenerales,
    this.estValide = true,
    this.medicaments = const [],
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    final meds = (json['medicaments'] as List? ?? [])
        .map((m) => LigneMedicament.fromJson(m as Map<String, dynamic>))
        .toList();

    return Prescription(
      idOrdonnance:          int.tryParse(json['id_ordonnance'].toString()) ?? 0,
      datePrescription:      json['date_prescription']?.toString(),
      instructionsGenerales: json['instructions_generales']?.toString(),
      estValide:             (json['est_valide'] == true || json['est_valide'] == 1),
      medicaments:           meds,
    );
  }

  // ── SQLite ────────────────────────────────────────────────────────────────

  /// Sérialise la prescription (sans les lignes — gérées séparément).
  Map<String, dynamic> toMap() => {
        'id_ordonnance': idOrdonnance,
        'date_prescription': datePrescription,
        'instructions_generales': instructionsGenerales,
        'est_valide': estValide ? 1 : 0,
      };

  /// Reconstruit une [Prescription] depuis une ligne SQLite + ses lignes.
  factory Prescription.fromMap(
    Map<String, dynamic> map,
    List<LigneMedicament> lignes,
  ) =>
      Prescription(
        idOrdonnance:          map['id_ordonnance'] as int,
        datePrescription:      map['date_prescription'] as String?,
        instructionsGenerales: map['instructions_generales'] as String?,
        estValide:             (map['est_valide'] as int? ?? 1) == 1,
        medicaments:           lignes,
      );
}
