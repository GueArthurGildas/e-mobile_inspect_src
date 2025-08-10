import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/services/api_get/consignations_service.dart';
import '../models/consignations_model.dart';

class ConsignationsController extends ChangeNotifier {
  final String _errorMsg = "Erreur Consignations";
  final ConsignationsService _service = ConsignationsService();
  List<Consignations> _items = [];

  List<Consignations> get items => _items;

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
