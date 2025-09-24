import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/services/api_get/typenavires_service.dart';
import '../models/typenavires_model.dart';

class TypenaviresController extends ChangeNotifier {
  final TypenaviresService _service = TypenaviresService();
  List<Typenavires> _items = [];

  List<Typenavires> get items => _items;

  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur Typenavires : $e');
    }
  }

  Future<void> loadLocalOnly() async {
    try {
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur Typenavires : $e');
    }
  }
}
