import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/services/api_get/agents_shiping_service.dart';
import '../models/agents_shiping_model.dart';

class AgentsShipingController extends ChangeNotifier {
  final String _errorMsg = "Erreur AgentsShiping";
  final AgentsShipingService _service = AgentsShipingService();
  List<AgentsShiping> _items = [];

  List<AgentsShiping> get items => _items;

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
