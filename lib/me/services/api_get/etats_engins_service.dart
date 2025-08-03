import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:test_app_divkit/me/config/api_constants.dart';
import 'package:test_app_divkit/me/models/etats_engins_model.dart';
import 'package:test_app_divkit/me/services/database_service.dart';


class EtatsEnginsService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<EtatsEngins>> fetchFromApi() async {
    final response = await http.get(Uri.parse(base_url_api+'etats-engins'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => EtatsEngins.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API etats_engins');
    }
  }

  Future<void> insert(EtatsEngins item) async {
    final db = await _db;
    await db.insert('etats_engins', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> syncToLocal() async {
    final list = await fetchFromApi();
    for (var item in list) {
      await insert(item);
    }
  }

  Future<List<EtatsEngins>> getAll() async {
    final db = await _db;
    final maps = await db.query('etats_engins');
    return maps.map((e) => EtatsEngins.fromMap(e)).toList();
  }
}
