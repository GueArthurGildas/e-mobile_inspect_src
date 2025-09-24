import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:e_Inspection_APP/me/config/api_constants.dart';
import 'package:e_Inspection_APP/me/models/typenavires_model.dart';
import 'package:e_Inspection_APP/me/services/database_service.dart';

class TypenaviresService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<Typenavires>> fetchFromApi() async {
    final response = await http.get(Uri.parse(base_url_api + 'typenavires'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Typenavires.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API typenavires');
    }
  }

  Future<void> insert(Typenavires item) async {
    final db = await _db;
    await db.insert(
      'typenavires',
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

  Future<List<Typenavires>> getAll() async {
    final db = await _db;
    final maps = await db.query('typenavires');
    return maps.map((e) => Typenavires.fromMap(e)).toList();
  }
}
