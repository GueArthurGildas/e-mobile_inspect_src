// lib/services/user_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'package:test_app_divkit/me/models/user_model.dart';
import 'package:test_app_divkit/me/services/database_service.dart';
// Si tu as un fichier de constantes d'API, préfère l'import suivant et remplace la constante locale :
// import 'package:test_app_divkit/me/config/api_constants.dart';

class UserService {
  // --- API ---
  static const String _baseUrl = 'https://www.mirah-csp.com/api/v1/___T_api_users';

  final http.Client _client;
  UserService({http.Client? client}) : _client = client ?? http.Client();

  // --- DB ---
  Future<Database> get _db async => await DatabaseHelper.database;

  // =========================================================
  //                     API (online)
  // =========================================================

  Future<List<User>> fetchUsersFromApi() async {
    final resp = await _client.get(Uri.parse(_baseUrl));
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);
      return data
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Failed to load users: ${resp.statusCode}');
    }
  }

  Future<User> createUser(User user) async {
    final resp = await _client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (resp.statusCode == 201 || resp.statusCode == 200) {
      return User.fromJson(jsonDecode(resp.body));
    } else {
      throw Exception('Failed to create user: ${resp.statusCode}');
    }
  }

  Future<User> updateUser(User user) async {
    final url = '$_baseUrl/${user.id}';
    final resp = await _client.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (resp.statusCode == 200) {
      return User.fromJson(jsonDecode(resp.body));
    } else {
      throw Exception('Failed to update user: ${resp.statusCode}');
    }
  }

  Future<void> deleteUser(int id) async {
    final url = '$_baseUrl/$id';
    final resp = await _client.delete(Uri.parse(url));
    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception('Failed to delete user: ${resp.statusCode}');
    }
  }

  // =========================================================
  //                 LOCAL (SQLite, offline-first)
  // =========================================================
  // 💡 Table attendue: 'users'
  // Colonnes conseillées: id INTEGER PRIMARY KEY, name TEXT, email TEXT, payload_json TEXT (optionnel)
  // Assure-toi que DatabaseHelper crée bien la table (ou remplace toMap/fromMap selon ton schéma).

  Future<void> insertUserLocal(User user) async {
    final db = await _db;
    await db.insert(
      'users',
      user.toMap(), // -> doit renvoyer un Map<String, dynamic> cohérent avec ta table
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateUserLocal(User user) async {
    final db = await _db;
    await db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteUserLocal(int id) async {
    final db = await _db;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<User>> getLocalUsers() async {
    final db = await _db;
    final maps = await db.query('users', orderBy: 'id DESC');
    return maps.map((e) => User.fromMap(e)).toList();
  }

  /// API -> Local : télécharge tous les users et upsert localement
  Future<void> syncUsersToLocal() async {
    final users = await fetchUsersFromApi();
    final db = await _db;

    // Transaction pour accélérer et garantir la cohérence
    await db.transaction((txn) async {
      for (final u in users) {
        await txn.insert(
          'users',
          u.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

// =========================================================
//  (Optionnel) Stratégies hybrides pour un vrai offline-first
// =========================================================
// - createUserLocalThenSync(User user)
// - updateUserLocalThenSync(User user)
// - deleteUserLocalThenSync(int id)
//
// Tu peux pousser ces opérations dans une table 'user_sync_queue'
// et implémenter un service de sync différée (retry avec backoff).
}
