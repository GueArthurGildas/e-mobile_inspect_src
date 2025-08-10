// pays_model.dart
class Pays {
  final int id;
  final String code;
  final String libelle;

  Pays({required this.id, required this.code, required this.libelle});

  factory Pays.fromJson(Map<String, dynamic> json) {
    return Pays(id: json['id'], code: json['code'], libelle: json['libelle']);
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'code': code, 'libelle': libelle};
  }

  factory Pays.fromMap(Map<String, dynamic> map) {
    return Pays(id: map['id'], code: map['code'], libelle: map['libelle']);
  }
}
