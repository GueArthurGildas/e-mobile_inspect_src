import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/services/api_get/types_engins_service.dart';
import '../models/types_engins_model.dart';

class TypesEnginsController extends ChangeNotifier {
  final TypesEnginsService _service = TypesEnginsService();
  List<TypesEngins> _items = [];

  List<TypesEngins> get items => _items;

  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur TypesEngins : $e');
    }
  }

  Future<void> loadLocalOnly() async {
    try {
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur TypesEngins : $e');
    }
  }
}
