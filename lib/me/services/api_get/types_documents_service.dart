import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:test_app_divkit/me/models/types_documents_model.dart';
import 'package:test_app_divkit/me/services/database_service.dart';

class TypesDocumentsService {
  Future<Database> get _db async => await DatabaseHelper.database;

  Future<List<TypesDocuments>> fetchFromApi() async {
    final response = await http.get(
      Uri.parse('https://ton-api.com/api/v1/types-documents'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => TypesDocuments.fromJson(json)).toList();
    } else {
      throw Exception('Erreur API types_documents');
    }
  }

  Future<void> insert(TypesDocuments item) async {
    final db = await _db;
    await db.insert(
      'types_documents',
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

  Future<List<TypesDocuments>> getAll() async {
    final db = await _db;
    final maps = await db.query('types_documents');
    return maps.map((e) => TypesDocuments.fromMap(e)).toList();
  }
}
