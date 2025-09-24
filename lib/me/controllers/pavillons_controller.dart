import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/services/api_get/pavillons_service.dart';
import '../models/pavillons_model.dart';

class PavillonsController extends ChangeNotifier {
  final PavillonsService _service = PavillonsService();
  List<Pavillons> _items = [];

  List<Pavillons> get items => _items;

  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur Pavillons : $e');
    }
  }

  Future<void> loadLocalOnly() async {
    try {
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur Pavillons : $e');
    }
  }
}
