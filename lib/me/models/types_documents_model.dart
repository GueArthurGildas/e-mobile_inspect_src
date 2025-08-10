class TypesDocuments {
  final dynamic id;
  final dynamic libelle;
  final dynamic created_at;
  final dynamic updated_at;

  TypesDocuments({
    required this.id,
    required this.libelle,
    required this.created_at,
    required this.updated_at,
  });

  factory TypesDocuments.fromJson(Map<String, dynamic> json) => TypesDocuments(
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

  factory TypesDocuments.fromMap(Map<String, dynamic> map) => TypesDocuments(
    id: map['id'],
    libelle: map['libelle'],
    created_at: map['created_at'],
    updated_at: map['updated_at'],
  );
}
