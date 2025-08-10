import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:test_app_divkit/me/models/consignations_model.dart';
import 'package:test_app_divkit/me/services/database_service.dart';

class ConsignationsService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<Consignations>> fetchFromApi() async {
    final response = await http.get(
      Uri.parse('https://ton-api.com/api/v1/consignations'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Consignations.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API consignations');
    }
  }

  Future<void> insert(Consignations item) async {
    final db = await _db;
    await db.insert(
      'consignations',
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

  Future<List<Consignations>> getAll() async {
    final db = await _db;
    final maps = await db.query('consignations');
    return maps.map((e) => Consignations.fromMap(e)).toList();
  }
}
