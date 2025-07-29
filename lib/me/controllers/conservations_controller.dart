import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/services/api_get/conservations_service.dart';
import '../models/conservations_model.dart';

class ConservationsController extends ChangeNotifier {
  final ConservationsService _service = ConservationsService();
  List<Conservations> _items = [];

  List<Conservations> get items => _items;

  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur Conservations : \$e');
    }
  }
}
