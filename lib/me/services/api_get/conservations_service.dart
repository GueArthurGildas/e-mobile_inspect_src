import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:e_Inspection_APP/me/config/api_constants.dart';
import 'package:e_Inspection_APP/me/models/conservations_model.dart';
import 'package:e_Inspection_APP/me/services/database_service.dart';

class ConservationsService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<Conservations>> fetchFromApi() async {
    final response = await http.get(Uri.parse(base_url_api + 'conservations'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Conservations.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API conservations');
    }
  }

  Future<void> insert(Conservations item) async {
    final db = await _db;
    await db.insert(
      'conservations',
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

  Future<List<Conservations>> getAll() async {
    final db = await _db;
    final maps = await db.query('conservations');
    return maps.map((e) => Conservations.fromMap(e)).toList();
  }
}
