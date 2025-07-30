
// pays_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:test_app_divkit/me/config/api_constants.dart';
import 'package:test_app_divkit/me/models/pays_model.dart';
import 'package:test_app_divkit/me/services/database_service.dart';


class PaysService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<Pays>> fetchPaysFromApi() async {
    final response = await http.get(Uri.parse(base_url_api+'pays'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Pays.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors de la récupération des pays');
    }
  }

  Future<void> insertPays(Pays pays) async {
    final db = await _db;
    await db.insert(
      'pays',
      pays.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> syncPaysToLocal() async {
    final paysList = await fetchPaysFromApi();
    for (var pays in paysList) {
      await insertPays(pays);
    }
  }

  Future<List<Pays>> getLocalPays() async {
    final db = await _db;
    final maps = await db.query('pays');
    return maps.map((e) => Pays.fromMap(e)).toList();
  }
}
