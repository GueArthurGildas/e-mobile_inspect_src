import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:e_Inspection_APP/me/config/api_constants.dart';
import 'package:e_Inspection_APP/me/models/zones_capture_model.dart';
import 'package:e_Inspection_APP/me/services/database_service.dart';


class ZonesCaptureService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<ZonesCapture>> fetchFromApi() async {
    final response = await http.get(Uri.parse(base_url_api+'zones-capture'));
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
