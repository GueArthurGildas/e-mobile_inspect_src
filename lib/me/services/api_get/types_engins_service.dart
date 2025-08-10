import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:test_app_divkit/me/config/api_constants.dart';
import 'package:test_app_divkit/me/models/types_engins_model.dart';
import 'package:test_app_divkit/me/services/database_service.dart';


class TypesEnginsService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<TypesEngins>> fetchFromApi() async {
    final response = await http.get(Uri.parse(base_url_api+'types-engins'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TypesEngins.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API types_engins');
    }
  }

  Future<void> insert(TypesEngins item) async {
    final db = await _db;
    await db.insert('types_engins', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> syncToLocal() async {
    final list = await fetchFromApi();
    for (var item in list) {
      await insert(item);
    }
  }

  Future<List<TypesEngins>> getAll() async {
    final db = await _db;
    final maps = await db.query('types_engins');
    return maps.map((e) => TypesEngins.fromMap(e)).toList();
  }
}
