import 'package:test_app_divkit/me/controllers/sync_controller.dart';
import 'package:test_app_divkit/me/models/conservations_model.dart';
import 'package:test_app_divkit/me/models/especes_model.dart';
import 'package:test_app_divkit/me/models/presentations_model.dart';
import 'package:test_app_divkit/me/models/zones_capture_model.dart';

class StepFiveController {
  StepFiveController();

  final SyncController _syncController = SyncController.instance;

  Future<void> loadData() async {
    await _syncController.loadAll();
  }
}