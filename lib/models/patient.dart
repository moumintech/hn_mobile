class Patient {
  final int idPatient;
  final String nom;
  final String prenom;
  final String? photo;
  final String? dateNaissance;
  final String? numSecu;
  final String? email;
  final String? telephone;
  final String? personneAContacter;
  final String? medecinTraitant;

  Patient({
    required this.idPatient,
    required this.nom,
    required this.prenom,
    this.photo,
    this.dateNaissance,
    this.numSecu,
    this.email,
    this.telephone,
    this.personneAContacter,
    this.medecinTraitant,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      idPatient: int.parse(json['id_patient'].toString()),
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      photo: json['photo'],
      dateNaissance: json['date_naissance']?.toString(),
      numSecu: json['num_secu'],
      email: json['email'],
      telephone: json['telephone'],
      personneAContacter: json['personne_a_contacter'],
      medecinTraitant: json['medecin_traitant'],
    );
  }
}