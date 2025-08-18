import 'package:test_app_divkit/me/controllers/conservations_controller.dart';
import 'package:test_app_divkit/me/controllers/presentations_controller.dart';
import 'package:test_app_divkit/me/controllers/sync_controller.dart';
import 'package:test_app_divkit/me/models/conservations_model.dart';
import 'package:test_app_divkit/me/models/presentations_model.dart';

class StepFiveController {
  StepFiveController();

  final SyncController _syncController = SyncController.instance;

  late List<Presentations> presentationsList;
  late List<Conservations> conservationsList;

  Future<void> loadData() async {
    await _syncController.loadAll();

    presentationsList = (
        _syncController.getController(ControllerKey.presentationsProduit)
        as PresentationsController).items;
    conservationsList = (
        _syncController.getController(ControllerKey.conservationsProduit)
        as ConservationsController).items;
  }
}