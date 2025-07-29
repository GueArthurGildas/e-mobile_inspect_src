import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/services/api_get/especes_service.dart';
import '../models/especes_model.dart';

class EspecesController extends ChangeNotifier {
  final EspecesService _service = EspecesService();
  List<Especes> _items = [];

  List<Especes> get items => _items;

  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur Especes : \$e');
    }
  }
}
