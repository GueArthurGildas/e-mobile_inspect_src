class ZonesCapture {
  final dynamic id;
  final dynamic code;
  final dynamic libelle;
  final dynamic deleted_at;
  final dynamic created_at;
  final dynamic updated_at;

  ZonesCapture({
    required this.id,
    required this.code,
    required this.libelle,
    required this.deleted_at,
    required this.created_at,
    required this.updated_at,
  });

  factory ZonesCapture.fromJson(Map<String, dynamic> json) => ZonesCapture(
    id: json['id'],
    code: json['code'],
    libelle: json['libelle'],
    deleted_at: json['deleted_at'],
    created_at: json['created_at'],
    updated_at: json['updated_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'code': code,
    'libelle': libelle,
    'deleted_at': deleted_at,
    'created_at': created_at,
    'updated_at': updated_at,
  };

  factory ZonesCapture.fromMap(Map<String, dynamic> map) => ZonesCapture(
    id: map['id'],
    code: map['code'],
    libelle: map['libelle'],
    deleted_at: map['deleted_at'],
    created_at: map['created_at'],
    updated_at: map['updated_at'],
  );
}
