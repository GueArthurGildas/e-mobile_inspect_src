import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:test_app_divkit/me/models/zones_capture_model.dart';
import 'package:test_app_divkit/me/services/database_service.dart';


class ZonesCaptureService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<ZonesCapture>> fetchFromApi() async {
    final response = await http.get(Uri.parse('https://ton-api.com/api/v1/zones-capture'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ZonesCapture.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API zones_capture');
    }
  }

  Future<void> insert(ZonesCapture item) async {
    final db = await _db;
    await db.insert('zones_capture', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> syncToLocal() async {
    final list = await fetchFromApi();
    for (var item in list) {
      await insert(item);
    }
  }

  Future<List<ZonesCapture>> getAll() async {
    final db = await _db;
    final maps = await db.query('zones_capture');
    return maps.map((e) => ZonesCapture.fromMap(e)).toList();
  }
}
