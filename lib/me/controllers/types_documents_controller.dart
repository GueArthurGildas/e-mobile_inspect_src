import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/services/api_get/types_documents_service.dart';
import '../models/types_documents_model.dart';

class TypesDocumentsController extends ChangeNotifier {
  final TypesDocumentsService _service = TypesDocumentsService();
  List<TypesDocuments> _items = [];

  List<TypesDocuments> get items => _items;

  Future<void> loadAndSync() async {
    try {
      await _service.syncToLocal();
      _items = await _service.getAll();
      notifyListeners();
    } catch (e) {
      print('Erreur TypesDocuments : \$e');
    }
  }
}
