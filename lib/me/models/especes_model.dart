class Especes {
  final dynamic id;
  final dynamic code;
  final dynamic name;
  final dynamic created_at;
  final dynamic updated_at;

  Especes({required this.id, required this.code, required this.name , required this.created_at, required this.updated_at});

  factory Especes.fromJson(Map<String, dynamic> json) => Especes(
    id: json['id'],
    code: json['code'],
    name : json['name'],
    created_at: json['created_at'],
    updated_at: json['updated_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'code': code,
     'name' : name,
    'created_at': created_at,
    'updated_at': updated_at,
  };

  factory Especes.fromMap(Map<String, dynamic> map) => Especes(
    id: map['id'],
    code: map['code'],
    name: map['name'],
    created_at: map['created_at'],
    updated_at: map['updated_at'],
  );
}
