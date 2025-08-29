// lib/controllers/user_controller.dart
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'package:test_app_divkit/me/services/api_get/user_api_service.dart';

class UserController extends ChangeNotifier {
  final UserService _service;
  List<User> _users = [];
  bool _loading = false;

  UserController({UserService? service}) : _service = service ?? UserService();

  // --- Getters publics (lecture seule depuis l'extérieur)
  List<User> get users => _users;
  bool get isLoading => _loading;

  // --- Utilitaire interne pour MAJ du loader
  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  /// Sync API -> Local, puis charge depuis la base locale (offline-first)
  Future<void> loadAndSync() async {
    try {
      _setLoading(true);
      await _service.syncUsersToLocal();     // <- à implémenter côté service (comme pays)
      _users = await _service.getLocalUsers(); // <- idem
      notifyListeners();
    } catch (e) {
      debugPrint('Error loadAndSync users: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Charge UNIQUEMENT depuis le local (utile hors-ligne)
  Future<void> loadLocalOnly() async {
    try {
      _setLoading(true);
      _users = await _service.getLocalUsers(); // <- idem
      notifyListeners();
    } catch (e) {
      debugPrint('Error loadLocalOnly users: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Création (tu peux garder online-first ou basculer en local-then-sync selon ton service)
  // Future<void> addUser(User user) async {
  //   try {
  //     _setLoading(true);
  //     final newUser = await _service.createUser(user); // ou createUserLocal(...) selon stratégie
  //     _users.add(newUser);
  //     notifyListeners();
  //   } catch (e) {
  //     debugPrint('Error adding user: $e');
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  /// Mise à jour
  Future<void> updateUser(User user) async {
    try {
      _setLoading(true);
      final updated = await _service.updateUser(user); // ou updateUserLocal(...)
      final idx = _users.indexWhere((u) => u.id == updated.id);
      if (idx != -1) {
        _users[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating user: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Suppression
  Future<void> deleteUser(int id) async {
    try {
      _setLoading(true);
      await _service.deleteUser(id); // ou deleteUserLocal(...)
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting user: $e');
    } finally {
      _setLoading(false);
    }
  }
}
