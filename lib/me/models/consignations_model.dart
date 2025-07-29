class Consignations {
  final dynamic id;
  final dynamic nom_societe;
  final dynamic contact;
  final dynamic situation_geo;
  final dynamic persone_contact;
  final dynamic email_contact;
  final dynamic tel_contact;
  final dynamic created_at;
  final dynamic updated_at;

  Consignations({required this.id, required this.nom_societe, required this.contact, required this.situation_geo, required this.persone_contact, required this.email_contact, required this.tel_contact, required this.created_at, required this.updated_at});

  factory Consignations.fromJson(Map<String, dynamic> json) => Consignations(
    id: json['id'],
    nom_societe: json['nom_societe'],
    contact: json['contact'],
    situation_geo: json['situation_geo'],
    persone_contact: json['persone_contact'],
    email_contact: json['email_contact'],
    tel_contact: json['tel_contact'],
    created_at: json['created_at'],
    updated_at: json['updated_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nom_societe': nom_societe,
    'contact': contact,
    'situation_geo': situation_geo,
    'persone_contact': persone_contact,
    'email_contact': email_contact,
    'tel_contact': tel_contact,
    'created_at': created_at,
    'updated_at': updated_at,
  };

  factory Consignations.fromMap(Map<String, dynamic> map) => Consignations(
    id: map['id'],
    nom_societe: map['nom_societe'],
    contact: map['contact'],
    situation_geo: map['situation_geo'],
    persone_contact: map['persone_contact'],
    email_contact: map['email_contact'],
    tel_contact: map['tel_contact'],
    created_at: map['created_at'],
    updated_at: map['updated_at'],
  );
}
