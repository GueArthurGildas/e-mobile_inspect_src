class AgentsShiping {
  final dynamic id;
  final dynamic nom;
  final dynamic prenom;
  final dynamic contact;
  final dynamic photo;
  final dynamic created_at;
  final dynamic updated_at;

  AgentsShiping({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.contact,
    required this.photo,
    required this.created_at,
    required this.updated_at,
  });

  factory AgentsShiping.fromJson(Map<String, dynamic> json) => AgentsShiping(
    id: json['id'],
    nom: json['nom'],
    prenom: json['prenom'],
    contact: json['contact'],
    photo: json['photo'],
    created_at: json['created_at'],
    updated_at: json['updated_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nom': nom,
    'prenom': prenom,
    'contact': contact,
    'photo': photo,
    'created_at': created_at,
    'updated_at': updated_at,
  };

  factory AgentsShiping.fromMap(Map<String, dynamic> map) => AgentsShiping(
    id: map['id'],
    nom: map['nom'],
    prenom: map['prenom'],
    contact: map['contact'],
    photo: map['photo'],
    created_at: map['created_at'],
    updated_at: map['updated_at'],
  );
}
