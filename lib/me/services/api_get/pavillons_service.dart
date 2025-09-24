import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:e_Inspection_APP/me/config/api_constants.dart';
import 'package:e_Inspection_APP/me/models/pavillons_model.dart';
import 'package:e_Inspection_APP/me/services/database_service.dart';

class PavillonsService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<Pavillons>> fetchFromApi() async {
    final response = await http.get(
        Uri.parse('${base_url_api}pavillons'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Pavillons.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API pavillons');
    }
  }

  Future<void> insert(Pavillons item) async {
    final db = await _db;
    await db.insert(
      'pavillons',
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

  Future<List<Pavillons>> getAll() async {
    final db = await _db;
    final maps = await db.query('pavillons');
    return maps.map((e) => Pavillons.fromMap(e)).toList();
  }
}
