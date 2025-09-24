// lib/services/api_get/user_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';

import 'package:e_Inspection_APP/me/config/api_constants.dart';
import 'package:e_Inspection_APP/me/services/database_service.dart';
import 'package:e_Inspection_APP/me/models/user_model.dart';

class UserService {
  Future<Database> get _db async => await DatabaseHelper.database;

  String get _endpoint {
    final base = base_url_api; // Assure-toi que base se termine par '/'
    return '${base}users';
  }

  /// 1) API -> List<User> (robuste)
  Future<List<User>> fetchUsersFromApi() async {
    final res = await http.get(Uri.parse(_endpoint));
    if (res.statusCode != 200) {
      throw Exception('Erreur API users: HTTP ${res.statusCode}');
    }

    final decoded = jsonDecode(res.body);

    // Normalisation:
    // - [ {...}, {...} ]
    // - { users: [...] } / { data: [...] } / { result: [...] } / { items: [...] }
    // - { user: {...} } (single)
    List<dynamic> arr;
    if (decoded is List) {
      arr = decoded;
    } else if (decoded is Map<String, dynamic>) {
      final listLike = decoded['users'] ??
          decoded['data'] ??
          decoded['result'] ??
          decoded['items'];
      if (listLike is List) {
        arr = listLike;
      } else if (decoded['user'] is Map<String, dynamic>) {
        arr = [decoded['user']];
      } else {
        // Dernier recours: si l'objet ressemble déjà à un user
        arr = [decoded];
      }
    } else {
      throw Exception('Format JSON inattendu pour /users');
    }

    return arr
        .where((e) => e is Map<String, dynamic>)
        .map<User>((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 2) Insert/Upsert local
  Future<void> insertLocal(User user) async {
    final db = await _db;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 3) Sync API -> local (transaction, upsert)
  Future<void> syncUsersToLocal() async {
    final list = await fetchUsersFromApi();
    final db = await _db;
    await db.transaction((txn) async {
      for (final u in list) {
        await txn.insert(
          'users',
          u.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// 4) Lecture locale (pour UserController.loadLocalOnly / loadAndSync)
  Future<List<User>> getLocalUsers() async {
    final db = await _db;
    final rows = await db.query('users', orderBy: 'id DESC');
    return rows.map((m) => User.fromMap(m)).toList();
  }

  /// 5) Lecture par id (optionnel)
  Future<User?> getById(int id) async {
    final db = await _db;
    final rows = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (rows.isNotEmpty) return User.fromMap(rows.first);
    return null;
  }

  /// 6) Création locale (tu peux brancher une vraie API si besoin)
  // Future<User> createUser(User user) async {
  //   final db = await _db;
  //   // Si ton id vient du backend, remplace par un POST API puis upsert local.
  //   final id = await db.insert('users', user.toMap(),
  //       conflictAlgorithm: ConflictAlgorithm.replace);
  //   return user.copyWith(id: id);
  // }

  /// 7) Mise à jour locale
  Future<User> updateUser(User user) async {
    final db = await _db;
    await db.update('users', user.toMap(),
        where: 'id = ?', whereArgs: [user.id]);
    return user;
  }

  /// 8) Suppression locale
  Future<void> deleteUser(int id) async {
    final db = await _db;
    await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  /// 9) Truncate (optionnel)
  Future<void> clearTable() async {
    final db = await _db;
    await db.delete('users');
  }

  Future<User?> getLocalUserByEmail(String email) async {
    final db = await _db;
    final e = email.trim().toLowerCase();

    // ⚠️ Adapte le nom de table/colonnes si besoin
    final rows = await db.query(
      'users',
      where: 'LOWER(email) = ?',
      whereArgs: [e],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return User.fromMap(rows.first); // ou fromJson selon ton modèle
  }


}
