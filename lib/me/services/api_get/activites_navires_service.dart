import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:test_app_divkit/me/config/api_constants.dart';
import 'package:test_app_divkit/me/models/activites_navires_model.dart';
import 'package:test_app_divkit/me/services/database_service.dart';

class ActivitesNaviresService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<ActivitesNavires>> fetchFromApi() async {
    final response = await http.get(Uri.parse(base_url_api+'activites-navires'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ActivitesNavires.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API activites_navires');
    }
  }

  Future<void> insert(ActivitesNavires item) async {
    final db = await _db;
    await db.insert('activites_navires', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> syncToLocal() async {
    final list = await fetchFromApi();
    for (var item in list) {
      await insert(item);
    }
  }

  Future<List<ActivitesNavires>> getAll() async {
    final db = await _db;
    final maps = await db.query('activites_navires');
    print(maps.isEmpty);
    return maps.map((e) => ActivitesNavires.fromMap(e)).toList();
  }
}
