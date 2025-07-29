import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/services/api_get/zones_capture_service.dart';
import '../models/zones_capture_model.dart';

class ZonesCaptureController extends ChangeNotifier {
  final ZonesCaptureService _service = ZonesCaptureService();
  List<ZonesCapture> _items = [];

  List<ZonesCapture> get items => _items;

  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur ZonesCapture : \$e');
    }
  }
}
