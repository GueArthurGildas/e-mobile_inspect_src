import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/services/api_get/agents_shiping_service.dart';
import '../models/agents_shiping_model.dart';

class AgentsShipingController extends ChangeNotifier {
  final AgentsShipingService _service = AgentsShipingService();
  List<AgentsShiping> _items = [];

  List<AgentsShiping> get items => _items;

  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur AgentsShiping : \$e');
    }
  }
}
