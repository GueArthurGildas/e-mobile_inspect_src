class TypesEngins {
  final dynamic id;
  final dynamic created_at;
  final dynamic updated_at;
  final dynamic code;
  final dynamic label_english_name;
  final dynamic french_name;

  TypesEngins({
    this.id,
    this.code,
    this.label_english_name,
    this.french_name,
    this.created_at,
    this.updated_at,
  });

  factory TypesEngins.fromJson(Map<String, dynamic> json) => TypesEngins(
    id: json['id'],
    code: json['code'],
    label_english_name: json['label_english_name'],
    french_name: json['french_name'],
    created_at: json['created_at'],
    updated_at: json['updated_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'code': code,
    'label_english_name': label_english_name,
    'french_name': french_name,
    'created_at': created_at,
    'updated_at': updated_at,
  };

  factory TypesEngins.fromMap(Map<String, dynamic> map) => TypesEngins(
    id: map['id'],
    code: map['code'],
    label_english_name: map['label_english_name'],
    french_name: map['french_name'],
    created_at: map['created_at'],
    updated_at: map['updated_at'],
  );
}
