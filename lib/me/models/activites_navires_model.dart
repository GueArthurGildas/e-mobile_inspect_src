class ActivitesNavires {
  final dynamic id;
  final dynamic libelle;
  final dynamic created_at;
  final dynamic updated_at;

  ActivitesNavires({required this.id, required this.libelle, required this.created_at, required this.updated_at});

  factory ActivitesNavires.fromJson(Map<String, dynamic> json) => ActivitesNavires(
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

  factory ActivitesNavires.fromMap(Map<String, dynamic> map) => ActivitesNavires(
    id: map['id'],
    libelle: map['libelle'],
    created_at: map['created_at'],
    updated_at: map['updated_at'],
  );
}
