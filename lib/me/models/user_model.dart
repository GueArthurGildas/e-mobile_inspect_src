import 'dart:convert';

class User {
  final int id;
  final String name;
  final String email;

  /// Stockés tels quels depuis l’API
  final List<dynamic> jsonRole;
  final List<dynamic> fieldJsonInspectDone;
  final List<dynamic> fieldJsonInspectPending;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.jsonRole,
    required this.fieldJsonInspectDone,
    required this.fieldJsonInspectPending,
  });

  // --- API JSON -> Objet
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      jsonRole: json['json_role'] ?? [],
      fieldJsonInspectDone: json['field_json_inspect_done'] ?? [],
      fieldJsonInspectPending: json['field_json_inspect_pending'] ?? [],
    );
  }

  // --- Objet -> API JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'json_role': jsonRole,
      'field_json_inspect_done': fieldJsonInspectDone,
      'field_json_inspect_pending': fieldJsonInspectPending,
    };
  }

  // --- SQLite Map -> Objet
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      jsonRole: map['json_role'] != null
          ? jsonDecode(map['json_role'] as String)
          : [],
      fieldJsonInspectDone: map['field_json_inspect_done'] != null
          ? jsonDecode(map['field_json_inspect_done'] as String)
          : [],
      fieldJsonInspectPending: map['field_json_inspect_pending'] != null
          ? jsonDecode(map['field_json_inspect_pending'] as String)
          : [],
    );
  }

  // --- Objet -> SQLite Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'json_role': jsonEncode(jsonRole),
      'field_json_inspect_done': jsonEncode(fieldJsonInspectDone),
      'field_json_inspect_pending': jsonEncode(fieldJsonInspectPending),
    };
  }
}
