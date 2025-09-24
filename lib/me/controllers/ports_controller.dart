import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/services/api_get/ports_service.dart';
import '../models/ports_model.dart';

class PortsController extends ChangeNotifier {
  final PortsService _service = PortsService();
  List<Ports> _items = [];

  List<Ports> get items => _items;

  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur Ports : $e');
    }
  }

  Future<void> loadLocalOnly() async {
    try {
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur Ports : $e');
    }
  }
}
