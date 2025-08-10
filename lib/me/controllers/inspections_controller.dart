import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/models/inspection.dart';
import 'package:test_app_divkit/me/models/inspection_model.dart';
import 'package:test_app_divkit/me/services/api_get/inspections_service.dart';

class InspectionController extends ChangeNotifier {
  final InspectionService _service = InspectionService();
  List<Inspection> _items = [];

  List<Inspection> get items => _items;

  /// 🔹 Charge les données depuis l'API et synchronise avec SQLite
  Future<void> loadAndSync() async {
    try {
      // 1️⃣ Synchronisation locale
      await _service.syncToLocal();

      // 2️⃣ Récupération des données depuis SQLite
      _items = await _service.getAll();

      // 3️⃣ Mise à jour de la vue
      notifyListeners();
    } catch (e) {
      print('Erreur Inspection : $e');
    }
  }

  /// 🔹 Rafraîchir seulement depuis la base locale
  Future<void> loadLocalOnly() async {
    try {
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur chargement local Inspection : $e');
    }
  }

  /// 🔹 Récupération par ID
  Inspection? getById(int id) {
    try {
      return _items.firstWhere((inspection) => inspection.id == id);
    } catch (_) {
      return null;
    }
  }
}
