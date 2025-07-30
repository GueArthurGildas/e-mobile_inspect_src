import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:test_app_divkit/me/config/api_constants.dart';
import 'package:test_app_divkit/me/models/ports_model.dart';
import 'package:test_app_divkit/me/services/database_service.dart';


class PortsService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<Ports>> fetchFromApi() async {
    final response = await http.get(Uri.parse(base_url_api+'ports'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Ports.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API ports');
    }
  }

  Future<void> insert(Ports item) async {
    final db = await _db;
    await db.insert('ports', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> syncToLocal() async {
    final list = await fetchFromApi();
    for (var item in list) {
      await insert(item);
    }
  }

  Future<List<Ports>> getAll() async {
    final db = await _db;
    final maps = await db.query('ports');
    return maps.map((e) => Ports.fromMap(e)).toList();
  }
}
