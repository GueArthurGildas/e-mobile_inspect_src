import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:test_app_divkit/me/models/agents_shiping_model.dart';
import 'package:test_app_divkit/me/services/database_service.dart';


class AgentsShipingService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<AgentsShiping>> fetchFromApi() async {
    final response = await http.get(Uri.parse('https://ton-api.com/api/v1/agents-shiping'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AgentsShiping.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API agents_shiping');
    }
  }

  Future<void> insert(AgentsShiping item) async {
    final db = await _db;
    await db.insert('agents_shiping', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> syncToLocal() async {
    final list = await fetchFromApi();
    for (var item in list) {
      await insert(item);
    }
  }

  Future<List<AgentsShiping>> getAll() async {
    final db = await _db;
    final maps = await db.query('agents_shiping');
    return maps.map((e) => AgentsShiping.fromMap(e)).toList();
  }
}
