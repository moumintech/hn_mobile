class Patient {
  final int     idPatient;
  final String  nom;
  final String  prenom;
  final String? photo;
  final String? dateNaissance;
  final String? numSecu;
  final String? email;
  final String? telephone;
  final String? personneAContacter;
  final String? contactUrgenceTel;
  final String? medecinTraitant;
  final String? adresse;
  final String? ville;
  final String? codePostal;

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
    this.contactUrgenceTel,
    this.medecinTraitant,
    this.adresse,
    this.ville,
    this.codePostal,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      idPatient:          int.tryParse(json['id_patient'].toString()) ?? 0,
      nom:                json['nom']     ?? '',
      prenom:             json['prenom']  ?? '',
      photo:              json['photo']?.toString(),
      dateNaissance:      json['date_naissance']?.toString(),
      numSecu:            json['num_secu']?.toString(),
      email:              json['email']?.toString(),
      telephone:          json['telephone']?.toString(),
      personneAContacter: json['personne_a_contacter']?.toString(),
      contactUrgenceTel:  json['contact_urgence_tel']?.toString(),
      medecinTraitant:    json['medecin_traitant']?.toString(),
      adresse:            json['adresse']?.toString(),
      ville:              json['ville']?.toString(),
      codePostal:         json['code_postal']?.toString(),
    );
  }
}
