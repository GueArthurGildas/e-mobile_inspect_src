import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:test_app_divkit/me/config/api_constants.dart';
import 'package:test_app_divkit/me/models/inspection_model.dart';
import 'package:test_app_divkit/me/services/database_service.dart';

class InspectionService {
  Future<Database> get _db async => await DatabaseHelper.database;

  /// 🔹 1. Récupération des inspections depuis l’API
  Future<List<Inspection>> fetchFromApi() async {
    final response = await http.get(Uri.parse(base_url_api + 'inspections'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Inspection.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API inspections');
    }
  }

  /// 🔹 2. Insertion d’une inspection en local SQLite
  Future<void> insert(Inspection inspection) async {
    final db = await _db;
    await db.insert(
      'inspections',
      inspection.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // remplace si déjà existant
    );
  }

  /// 🔹 3. Synchronisation des données locales depuis l’API
  Future<void> syncToLocal() async {
    final list = await fetchFromApi();
    for (var item in list) {
      await insert(item);
    }
  }

  /// 🔹 4. Récupération de toutes les inspections locales
  Future<List<Inspection>> getAll() async {
    final db = await _db;
    final maps = await db.query('inspections');
    return maps.map((map) => Inspection.fromMap(map)).toList();
  }

  /// 🔹 5. Récupération par ID
  Future<Inspection?> getById(int id) async {
    final db = await _db;
    final maps = await db.query('inspections', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Inspection.fromMap(maps.first);
    }
    return null;
  }

  /// 🔹 6. Suppression d’une inspection
  Future<void> deleteById(int id) async {
    final db = await _db;
    await db.delete('inspections', where: 'id = ?', whereArgs: [id]);
  }

  /// 🔹 7. Nettoyage complet de la table inspections
  Future<void> clearTable() async {
    final db = await _db;
    await db.delete('inspections');
  }
}
