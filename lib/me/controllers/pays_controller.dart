// pays_controller.dart
import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/models/pays_model.dart';
import 'package:test_app_divkit/me/services/api_get/pays_api_services.dart';


class PaysController extends ChangeNotifier {
  final PaysService _service = PaysService();
  List<Pays> _pays = [];

  List<Pays> get pays => _pays;

  Future<void> loadAndSyncPays() async {
    try {
      await _service.syncPaysToLocal();
      _pays = await _service.getLocalPays();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des pays : \$e');
    }
  }
}