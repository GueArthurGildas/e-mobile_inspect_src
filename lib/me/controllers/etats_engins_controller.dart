import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/services/api_get/etats_engins_service.dart';
import '../models/etats_engins_model.dart';
class EtatsEnginsController extends ChangeNotifier {
  final EtatsEnginsService _service = EtatsEnginsService();
  List<EtatsEngins> _items = [];

  List<EtatsEngins> get items => _items;

  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur EtatsEngins : \$e');
    }
  }
}
