import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/services/api_get/activites_navires_service.dart';
import '../models/activites_navires_model.dart';

class ActivitesNaviresController extends ChangeNotifier {
  final ActivitesNaviresService _service = ActivitesNaviresService();
  List<ActivitesNavires> _items = [];

  List<ActivitesNavires> get items => _items;

  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur ActivitesNavires : $e');
    }
  }

  Future<void> loadLocalOnly() async {
    try {
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur ActivitesNavires : $e');
    }
  }
}
