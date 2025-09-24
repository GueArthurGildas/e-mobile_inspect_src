import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:e_Inspection_APP/me/config/api_constants.dart';
import 'package:e_Inspection_APP/me/models/presentations_model.dart';
import 'package:e_Inspection_APP/me/services/database_service.dart';


class PresentationsService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<Presentations>> fetchFromApi() async {
    final response = await http.get(Uri.parse( base_url_api+'presentations'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Presentations.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API presentations');
    }
  }

  Future<void> insert(Presentations item) async {
    final db = await _db;
    await db.insert('presentation_produit', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> syncToLocal() async {
    final list = await fetchFromApi();
    for (var item in list) {
      await insert(item);
    }
  }

  Future<List<Presentations>> getAll() async {
    final db = await _db;
    final maps = await db.query('presentation_produit');
    return maps.map((e) => Presentations.fromMap(e)).toList();
  }
}
