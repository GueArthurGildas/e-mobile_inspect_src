import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/services/api_get/presentations_service.dart';
import '../models/presentations_model.dart';

class PresentationsController extends ChangeNotifier {
  final PresentationsService _service = PresentationsService();
  List<Presentations> _items = [];

  List<Presentations> get items => _items;

  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur Presentations : $e');
    }
  }

  Future<void> loadLocalOnly() async {
    try {
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur Presentations : $e');
    }
  }
}
