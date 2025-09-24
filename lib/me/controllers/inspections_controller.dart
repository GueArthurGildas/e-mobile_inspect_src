import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/models/inspection.dart';
import 'package:e_Inspection_APP/me/models/inspection_model.dart';
import 'package:e_Inspection_APP/me/services/api_get/inspections_service.dart';

class InspectionController extends ChangeNotifier {
  final InspectionService _service = InspectionService();

  List<Inspection> _items = [];

  List<Inspection> get items => _items;

  /// 🔹 Charge les données depuis l'API et synchronise avec SQLite
  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur Inspection : $e');
    }
  }

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
