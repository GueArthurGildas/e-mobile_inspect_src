import 'package:e_Inspection_APP/me/controllers/sync_controller.dart';
import 'package:e_Inspection_APP/me/models/conservations_model.dart';
import 'package:e_Inspection_APP/me/models/especes_model.dart';
import 'package:e_Inspection_APP/me/models/presentations_model.dart';
import 'package:e_Inspection_APP/me/models/zones_capture_model.dart';

class StepFiveController {
  StepFiveController();

  final SyncController _syncController = SyncController.instance;

  Future<void> loadData() async {
    await _syncController.loadAll();
  }
}