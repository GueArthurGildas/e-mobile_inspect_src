// lib/services/user_service.dart

import 'package:http/http.dart' as http;
import 'package:test_app_divkit/me/models/user_model.dart';
import 'dart:convert';

class UserService {
  static const String _baseUrl =
      'https://www.mirah-csp.com/api/v1/___T_api_users';
  static const String _baseUrl_create = '';

  final http.Client _client;

  UserService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<User>> fetchUsers() async {
    final resp = await _client.get(Uri.parse(_baseUrl));
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);
      return data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Failed to load users: ${resp.statusCode}');
    }
  }

  Future<User> createUser(User user) async {
    final resp = await _client.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (resp.statusCode == 201) {
      return User.fromJson(jsonDecode(resp.body));
    } else {
      throw Exception('Failed to create user: ${resp.statusCode}');
    }
  }

  Future<User> updateUser(User user) async {
    final url = '$_baseUrl/${user.id}';
    final resp = await _client.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );
    if (resp.statusCode == 200) {
      return User.fromJson(jsonDecode(resp.body));
    } else {
      throw Exception('Failed to update user: ${resp.statusCode}');
    }
  }

  Future<void> deleteUser(int id) async {
    final url = '$_baseUrl/$id';
    final resp = await _client.delete(Uri.parse(url));
    if (resp.statusCode != 204) {
      throw Exception('Failed to delete user: ${resp.statusCode}');
    }
  }
}
