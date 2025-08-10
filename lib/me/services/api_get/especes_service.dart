import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:test_app_divkit/me/config/api_constants.dart';
import 'package:test_app_divkit/me/models/especes_model.dart';
import 'package:test_app_divkit/me/services/database_service.dart';

class EspecesService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<Especes>> fetchFromApi() async {
    final response = await http.get(Uri.parse(base_url_api + 'especes'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Especes.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API especes');
    }
  }

  Future<void> insert(Especes item) async {
    final db = await _db;
    await db.insert(
      'especes',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> syncToLocal() async {
    final list = await fetchFromApi();
    for (var item in list) {
      await insert(item);
    }
  }

  Future<List<Especes>> getAll() async {
    final db = await _db;
    final maps = await db.query('especes');
    return maps.map((e) => Especes.fromMap(e)).toList();
  }
}
