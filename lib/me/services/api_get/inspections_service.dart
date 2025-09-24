import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:e_Inspection_APP/me/config/api_constants.dart';
import 'package:e_Inspection_APP/me/models/inspection_model.dart'; // ❌ à retirer
import 'package:e_Inspection_APP/me/services/database_service.dart';

class InspectionService {
  Future<Database> get _db async => await DatabaseHelper.database;

  String get _endpoint {
    // Sécurise le slash final
    final base = base_url_api ;
    return '${base}inspections';
  }

  /// 1) API -> Liste<Inspection> (robuste aux différents formats)
  Future<List<Inspection>> fetchFromApi() async {
    final response = await http.get(Uri.parse(_endpoint));
    if (response.statusCode != 200) {
      throw Exception('Erreur API inspections: HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);

    // Normalise en liste :
    // - si l'API renvoie une liste: [ {...}, {...} ]
    // - si elle renvoie un objet: { ... }
    // - si elle renvoie { data: [...] }
    final List<dynamic> arr = decoded is List
        ? decoded
        : (decoded is Map && decoded['data'] is List)
        ? decoded['data'] as List
        : [decoded];

    return arr
        .map((e) => Inspection.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 2) Insert local (navire* seront encodés en TEXT via toMap())
  Future<void> insert(Inspection inspection) async {
    final db = await _db;
    await db.insert(
      'inspections',
      inspection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// 3) Sync API -> local (transaction)
  Future<void> syncToLocal() async {
    final list = await fetchFromApi();
    final db = await _db;
    await db.transaction((txn) async {
      for (final item in list) {
        await txn.insert(
          'inspections',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  /// 4) Lecture locale
  Future<List<Inspection>> getAll() async {
    final db = await _db;
    final maps = await db.query('inspections', orderBy: 'id DESC');
    return maps.map((m) => Inspection.fromMap(m)).toList();
  }

  /// 5) Lecture par id
  Future<Inspection?> getById(int id) async {
    final db = await _db;
    final maps = await db.query('inspections', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) return Inspection.fromMap(maps.first);
    return null;
  }

  /// 6) Suppression
  Future<void> deleteById(int id) async {
    final db = await _db;
    await db.delete('inspections', where: 'id = ?', whereArgs: [id]);
  }

  /// 7) Truncate
  Future<void> clearTable() async {
    final db = await _db;
    await db.delete('inspections');
  }
}
