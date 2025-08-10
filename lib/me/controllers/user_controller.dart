// lib/controllers/user_controller.dart

import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/services/api_get/user_api_service.dart';
import '../models/user_model.dart';

class UserController extends ChangeNotifier {
  final UserService _service;
  List<User> users = [];
  bool isLoading = false;

  UserController({UserService? service}) : _service = service ?? UserService();

  Future<void> loadUsers() async {
    isLoading = true;
    notifyListeners();
    try {
      users = await _service.fetchUsers();
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addUser(User user) async {
    isLoading = true;
    notifyListeners();
    try {
      final newUser = await _service.createUser(user);
      users.add(newUser);
    } catch (e) {
      debugPrint('Error adding user: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser(User user) async {
    isLoading = true;
    notifyListeners();
    try {
      final updated = await _service.updateUser(user);
      final index = users.indexWhere((u) => u.id == updated.id);
      if (index != -1) users[index] = updated;
    } catch (e) {
      debugPrint('Error updating user: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteUser(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      await _service.deleteUser(id);
      users.removeWhere((u) => u.id == id);
    } catch (e) {
      debugPrint('Error deleting user: $e');
    }
    isLoading = false;
    notifyListeners();
  }
}
