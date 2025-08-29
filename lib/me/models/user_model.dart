// lib/models/user_model.dart
import 'dart:convert';

class UserRole {
  final int? id;
  final String? name;

  const UserRole({this.id, this.name});

  factory UserRole.fromJson(Map<String, dynamic> json) => UserRole(
    id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
    name: json['name']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };

  factory UserRole.fromMap(Map<String, dynamic> map) => UserRole(
    id: map['id'] as int?,
    name: map['name'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };
}

class User {
  final int? id;
  final String? name;
  final String? email;

  /// API: "json_role": [ { id, name }, ... ]
  final List<UserRole> jsonRole;

  /// API: "field_json_inspect_done": [...]
  ///      "field_json_inspect_pending": [...]
  /// Type inconnu côté API -> on garde `List<dynamic>` pour rester souple.
  final List<dynamic> fieldJsonInspectDone;
  final List<dynamic> fieldJsonInspectPending;

  /// Flag local (optionnel) pour suivi/sync
  final int sync;

  const User({
    this.id,
    this.name,
    this.email,
    this.jsonRole = const [],
    this.fieldJsonInspectDone = const [],
    this.fieldJsonInspectPending = const [],
    this.sync = 0,
  });

  // ------------------ API JSON -> Objet ------------------
  factory User.fromJson(Map<String, dynamic> json) {
    try {
      final roles = <UserRole>[];
      final rawRoles = json['json_role'];
      if (rawRoles is List) {
        for (final r in rawRoles) {
          if (r is Map<String, dynamic>) roles.add(UserRole.fromJson(r));
        }
      }

      final done = json['field_json_inspect_done'];
      final pending = json['field_json_inspect_pending'];

      return User(
        id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
        name: json['name']?.toString(),
        email: json['email']?.toString(),
        jsonRole: roles,
        fieldJsonInspectDone:
        done is List ? List<dynamic>.from(done) : const [],
        fieldJsonInspectPending:
        pending is List ? List<dynamic>.from(pending) : const [],
        // sync: côté API généralement absent -> 0 par défaut
      );
    } catch (e, s) {
      // ignore: avoid_print
      print('❌ User.fromJson error: $e\n$s');
      rethrow;
    }
  }

  // ------------------ Objet -> API JSON ------------------
  Map<String, dynamic> toJson() {
    try {
      return {
        'id': id,
        'name': name,
        'email': email,
        'json_role': jsonRole.map((r) => r.toJson()).toList(),
        'field_json_inspect_done': fieldJsonInspectDone,
        'field_json_inspect_pending': fieldJsonInspectPending,
        // 'sync': sync, // En général, on ne renvoie pas ce champ local à l’API.
      };
    } catch (e, s) {
      // ignore: avoid_print
      print('❌ User.toJson error: $e\n$s');
      return {};
    }
  }

  // --------------- SQLite Map -> Objet -------------------
  factory User.fromMap(Map<String, dynamic> map) {
    try {
      // Les colonnes SQLite pour les listes seront stockées en TEXT (JSON)
      List<UserRole> roles = const [];
      final rawRoles = map['json_role'];
      if (rawRoles != null) {
        final decoded = rawRoles is String ? jsonDecode(rawRoles) : rawRoles;
        if (decoded is List) {
          roles = decoded
              .whereType<Map<String, dynamic>>()
              .map((m) => UserRole.fromJson(m))
              .toList();
        }
      }

      List<dynamic> done = const [];
      if (map['field_json_inspect_done'] != null) {
        final decoded = map['field_json_inspect_done'] is String
            ? jsonDecode(map['field_json_inspect_done'])
            : map['field_json_inspect_done'];
        if (decoded is List) done = List<dynamic>.from(decoded);
      }

      List<dynamic> pending = const [];
      if (map['field_json_inspect_pending'] != null) {
        final decoded = map['field_json_inspect_pending'] is String
            ? jsonDecode(map['field_json_inspect_pending'])
            : map['field_json_inspect_pending'];
        if (decoded is List) pending = List<dynamic>.from(decoded);
      }

      return User(
        id: map['id'] is int ? map['id'] : int.tryParse('${map['id']}'),
        name: map['name']?.toString(),
        email: map['email']?.toString(),
        jsonRole: roles,
        fieldJsonInspectDone: done,
        fieldJsonInspectPending: pending,
        sync: map['sync'] is int ? map['sync'] : int.tryParse('${map['sync']}') ?? 0,
      );
    } catch (e, s) {
      // ignore: avoid_print
      print('❌ User.fromMap error: $e\n$s');
      rethrow;
    }
  }

  // --------------- Objet -> SQLite Map -------------------
  Map<String, dynamic> toMap() {
    try {
      return {
        'id': id,
        'name': name,
        'email': email,
        // On stocke les listes en JSON (TEXT)
        'json_role': jsonEncode(jsonRole.map((r) => r.toJson()).toList()),
        'field_json_inspect_done': jsonEncode(fieldJsonInspectDone),
        'field_json_inspect_pending': jsonEncode(fieldJsonInspectPending),
        'sync': sync,
      };
    } catch (e, s) {
      // ignore: avoid_print
      print('❌ User.toMap error: $e\n$s');
      return {};
    }
  }

  // -------------------- Helpers --------------------------
  String? get primaryRoleName =>
      jsonRole.isNotEmpty ? jsonRole.first.name : null;

  bool get isAdmin =>
      jsonRole.any((r) => (r.name ?? '').toLowerCase() == 'admin');

  int get nbInspectionsDone => fieldJsonInspectDone.length;
  int get nbInspectionsPending => fieldJsonInspectPending.length;

  User copyWith({
    int? id,
    String? name,
    String? email,
    List<UserRole>? jsonRole,
    List<dynamic>? fieldJsonInspectDone,
    List<dynamic>? fieldJsonInspectPending,
    int? sync,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      jsonRole: jsonRole ?? this.jsonRole,
      fieldJsonInspectDone:
      fieldJsonInspectDone ?? this.fieldJsonInspectDone,
      fieldJsonInspectPending:
      fieldJsonInspectPending ?? this.fieldJsonInspectPending,
      sync: sync ?? this.sync,
    );
  }
}
