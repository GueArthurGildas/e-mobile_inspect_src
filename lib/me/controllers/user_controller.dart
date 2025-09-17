// lib/controllers/user_controller.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'package:test_app_divkit/me/services/api_get/user_api_service.dart';

class UserController extends ChangeNotifier {
  final UserService _service;
  List<User> _users = [];
  bool _loading = false;

  // Mémo en mémoire (optionnel mais utile pour l'UI)
  User? _currentUser;
  User? get currentUser => _currentUser;

  // 🔑 clés pour SharedPreferences
  static const _kUserIdKey              = 'current_user_id';
  static const _kUserNameKey            = 'current_user_name';
  static const _kUserEmailKey           = 'current_user_email';
  static const _kUserref_metier_codeKey = 'current_user_ref_metier_code';
  static const _kUserRolesKey           = 'current_user_roles_json';
  static const _kUserInspectDoneKey     = 'current_user_inspect_done_json';
  static const _kUserInspectPendingKey  = 'current_user_inspect_pending_json';

  UserController({UserService? service}) : _service = service ?? UserService();

  List<User> get users => _users;
  bool get isLoading => _loading;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  // ---------- Chargements liste ----------
  Future<void> loadAndSync() async {
    try {
      _setLoading(true);
      await _service.syncUsersToLocal();
      _users = await _service.getLocalUsers();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loadAndSync users: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadLocalOnly() async {
    try {
      _setLoading(true);
      _users = await _service.getLocalUsers();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loadLocalOnly users: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUser(User user) async {
    try {
      _setLoading(true);
      final updated = await _service.updateUser(user);
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

  Future<void> deleteUser(int id) async {
    try {
      _setLoading(true);
      await _service.deleteUser(id);
      _users.removeWhere((u) => u.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting user: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ---------- 🔎 LOGIN OFFLINE PAR EMAIL ----------
  Future<User?> findLocalByEmail(String email) async {
    try {
      return await _service.getLocalUserByEmail(email);
    } catch (e) {
      debugPrint('findLocalByEmail error: $e');
      return null;
    }
  }

  // 🔽 helpers rôle à ajouter dans UserController

  String _normalizeRole(String s) =>
      s.toLowerCase().replaceAll(RegExp(r'[\s\-]+'), '_').trim();

  Future<List<String>> _getRoleNamesFromPrefs() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString(_kUserRolesKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded.map((e) {
          if (e is Map && e['name'] != null) return _normalizeRole('${e['name']}');
          if (e is String) return _normalizeRole(e);
          return '';
        }).where((x) => x.isNotEmpty).cast<String>().toList();
      }
    } catch (e) {
      debugPrint('getRoleNames decode error: $e');
    }
    return [];
  }

  /// Vérifie si l'utilisateur courant possède AU MOINS un des rôles autorisés.
  /// Priorise les rôles en mémoire (_currentUser), sinon lit SharedPreferences.
  Future<bool> userHasAnyRole(Set<String> allowed) async {
    final allowedNorm = allowed.map(_normalizeRole).toSet();

    // 1) mémoire
    final mem = _currentUser?.jsonRole
        ?.map((r) => _normalizeRole(r.name ?? ''))
        .where((s) => s.isNotEmpty)
        .toList() ??
        const [];

    final roles = mem.isNotEmpty ? mem : await _getRoleNamesFromPrefs();
    return roles.any(allowedNorm.contains);
  }

  /// Raccourci pour le cas "Continuer inspection"
  Future<bool> canContinueInspection() =>
      userHasAnyRole({'admin', 'chef_equipe', 'chef-equipe', 'chef equipe'});


  // ---------- 💾 SESSION (SharedPreferences) ----------
  Future<void> persistCurrentUser(User u) async {
    final sp = await SharedPreferences.getInstance();

    // Champs simples
    await sp.setInt(_kUserIdKey, u.id ?? -1);
    await sp.setString(_kUserNameKey, (u.name ?? '').trim());
    await sp.setString(_kUserEmailKey, (u.email ?? '').trim());

    // Champs complexes (JSON)
    try {
      final rolesJson = jsonEncode(u.jsonRole.map((r) => r.toJson()).toList());
      await sp.setString(_kUserRolesKey, rolesJson);
    } catch (e) {
      debugPrint('persistCurrentUser roles encode error: $e');
      await sp.remove(_kUserRolesKey);
    }

    try {
      await sp.setString(_kUserInspectDoneKey, jsonEncode(u.fieldJsonInspectDone));
    } catch (e) {
      debugPrint('persistCurrentUser done encode error: $e');
      await sp.remove(_kUserInspectDoneKey);
    }

    try {
      await sp.setString(_kUserInspectPendingKey, jsonEncode(u.fieldJsonInspectPending));
    } catch (e) {
      debugPrint('persistCurrentUser pending encode error: $e');
      await sp.remove(_kUserInspectPendingKey);
    }

    // Mémo en mémoire + notify
    _currentUser = u;
    notifyListeners();
  }

  Future<User?> loadCurrentUser() async {
    final sp = await SharedPreferences.getInstance();

    final id    = sp.getInt(_kUserIdKey);
    final name  = sp.getString(_kUserNameKey);
    final email = sp.getString(_kUserEmailKey);
    if (id == null || (name == null && email == null)) return null;

    // Decode JSON rôles
    List<UserRole> roles = const [];
    final rolesStr = sp.getString(_kUserRolesKey);
    if (rolesStr != null && rolesStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(rolesStr);
        if (decoded is List) {
          roles = decoded
              .whereType<Map<String, dynamic>>()
              .map((m) => UserRole.fromJson(m))
              .toList();
        }
      } catch (e) {
        debugPrint('loadCurrentUser roles decode error: $e');
      }
    }

    // Decode JSON done/pending
    List<dynamic> done = const [];
    final doneStr = sp.getString(_kUserInspectDoneKey);
    if (doneStr != null && doneStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(doneStr);
        if (decoded is List) done = List<dynamic>.from(decoded);
      } catch (e) {
        debugPrint('loadCurrentUser done decode error: $e');
      }
    }

    List<dynamic> pending = const [];
    final pendingStr = sp.getString(_kUserInspectPendingKey);
    if (pendingStr != null && pendingStr.isNotEmpty) {
      try {
        final decoded = jsonDecode(pendingStr);
        if (decoded is List) pending = List<dynamic>.from(decoded);
      } catch (e) {
        debugPrint('loadCurrentUser pending decode error: $e');
      }
    }

    final u = User(
      id: id,
      name: name,
      email: email,
      jsonRole: roles,
      fieldJsonInspectDone: done,
      fieldJsonInspectPending: pending,
    );

    _currentUser = u;
    notifyListeners();
    return u;
  }

  Future<void> clearCurrentUser() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kUserIdKey);
    await sp.remove(_kUserNameKey);
    await sp.remove(_kUserEmailKey);
    await sp.remove(_kUserRolesKey);
    await sp.remove(_kUserInspectDoneKey);
    await sp.remove(_kUserInspectPendingKey);
    _currentUser = null;
    notifyListeners();
  }

  /// Hydrate `currentUser` depuis le disque (à appeler au boot/splash)
  Future<void> hydrateSession() async {
    await loadCurrentUser();
  }

  // ---------- Helpers rapides ----------
  Future<String?> loadCurrentUserName() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(_kUserNameKey);
  }

  Future<List<String>> loadCurrentRoleNames() async {
    final sp = await SharedPreferences.getInstance();
    final rolesStr = sp.getString(_kUserRolesKey);
    if (rolesStr == null || rolesStr.isEmpty) return const [];
    try {
      final decoded = jsonDecode(rolesStr);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map((m) => (m['name'] ?? '').toString())
          .where((s) => s.isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<int> loadNbInspectionsDone() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kUserInspectDoneKey);
    if (s == null || s.isEmpty) return 0;
    try {
      final decoded = jsonDecode(s);
      return decoded is List ? decoded.length : 0;
    } catch (_) {
      return 0;
    }
  }

  Future<int> loadNbInspectionsPending() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_kUserInspectPendingKey);
    if (s == null || s.isEmpty) return 0;
    try {
      final decoded = jsonDecode(s);
      return decoded is List ? decoded.length : 0;
    } catch (_) {
      return 0;
    }
  }

  /// Option pratique : un "logout" unique
  Future<void> logout() async {
    await clearCurrentUser();
    // _users = []; // si tu veux vider le cache liste
    // notifyListeners(); // déjà fait dans clearCurrentUser()
  }
}
