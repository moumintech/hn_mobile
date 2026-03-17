class RappelMedicament {
  final int idRappel;
  final String? heure;
  final bool actif;
  final int? idLigne;

  RappelMedicament({
    required this.idRappel,
    this.heure,
    required this.actif,
    this.idLigne,
  });

  factory RappelMedicament.fromJson(Map<String, dynamic> json) {
    return RappelMedicament(
      idRappel: int.parse(json['id_rappel'].toString()),
      heure: json['heure']?.toString(),
      actif: json['actif'].toString() == '1' || json['actif'] == true,
      idLigne: json['id_ligne'] == null ? null : int.parse(json['id_ligne'].toString()),
    );
  }
}