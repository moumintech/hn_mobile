class Prescription {
  final int idOrdonnance;
  final String? dateOrdonnance;
  final String? description;
  final int? idLigne;
  final String? medicament;
  final String? dosage;
  final String? frequence;
  final String? duree;

  Prescription({
    required this.idOrdonnance,
    this.dateOrdonnance,
    this.description,
    this.idLigne,
    this.medicament,
    this.dosage,
    this.frequence,
    this.duree,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      idOrdonnance: int.parse(json['id_ordonnance'].toString()),
      dateOrdonnance: json['date_ordonnance']?.toString(),
      description: json['description'],
      idLigne: json['id_ligne'] == null ? null : int.parse(json['id_ligne'].toString()),
      medicament: json['medicament'],
      dosage: json['dosage'],
      frequence: json['frequence'],
      duree: json['duree'],
    );
  }
}