class EtatsEngins {
  final dynamic id;
  final dynamic libelle;
  final dynamic created_at;
  final dynamic updated_at;

  EtatsEngins({required this.id, required this.libelle, required this.created_at, required this.updated_at});

  factory EtatsEngins.fromJson(Map<String, dynamic> json) => EtatsEngins(
    id: json['id'],
    libelle: json['libelle'],
    created_at: json['created_at'],
    updated_at: json['updated_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'libelle': libelle,
    'created_at': created_at,
    'updated_at': updated_at,
  };

  factory EtatsEngins.fromMap(Map<String, dynamic> map) => EtatsEngins(
    id: map['id'],
    libelle: map['libelle'],
    created_at: map['created_at'],
    updated_at: map['updated_at'],
  );
}
