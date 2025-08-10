import 'package:flutter/cupertino.dart';
import 'package:test_app_divkit/me/controllers/pays_controller.dart';
import 'package:test_app_divkit/me/controllers/ports_controller.dart';

class SyncController extends ChangeNotifier {
  SyncController({required this.controllers});

  final Map<String, dynamic> controllers;

  Future<void> syncAll() async {
    try {
      await Future.wait(
        controllers.values.map((c) async {
          if (c is PaysController) return await c.loadAndSyncPays();
          if (c is PortsController) return await c.loadAndSync();
        }),
      );
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }

  T getController<T>(String key) => controllers[key] as T;
}
