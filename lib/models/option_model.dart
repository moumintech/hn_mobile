class OptionModel {
  final int idOption;
  final String? libelle;
  final String? valeur;
  final bool active;

  OptionModel({
    required this.idOption,
    this.libelle,
    this.valeur,
    required this.active,
  });

  factory OptionModel.fromJson(Map<String, dynamic> json) {
    return OptionModel(
      idOption: int.parse(json['id_option'].toString()),
      libelle: json['libelle'],
      valeur: json['valeur'],
      active: json['active'].toString() == '1' || json['active'] == true,
    );
  }
}