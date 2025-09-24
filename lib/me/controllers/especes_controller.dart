import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/services/api_get/especes_service.dart';
import '../models/especes_model.dart';

class EspecesController extends ChangeNotifier {
  final String _errorMsg = "Erreur Especes";
  final EspecesService _service = EspecesService();
  List<Especes> _items = [];

  List<Especes> get items => _items;

  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('$_errorMsg : $e');
    }
  }

  Future<void> loadLocalOnly() async {
    try {
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('$_errorMsg : $e');
    }
  }
}
