import 'package:test_app_divkit/me/controllers/etats_engins_controller.dart';
import 'package:test_app_divkit/me/controllers/sync_controller.dart';
import 'package:test_app_divkit/me/controllers/types_engins_controller.dart';
import 'package:test_app_divkit/me/models/etats_engins_model.dart';
import 'package:test_app_divkit/me/models/types_engins_model.dart';

class MyStepFourController {
  MyStepFourController();

  final SyncController _syncController = SyncController.instance;

  late List<EtatsEngins> etatsEngins;
  late List<TypesEngins> typesEngins;

  Future<void> loadData() async {
    await _syncController.loadAll();

    etatsEngins =
        (_syncController.getController(ControllerKey.etatsEngins)
        as EtatsEnginsController)
            .items
        as List<EtatsEngins>? ??
            [];
    typesEngins =
        (_syncController.getController(ControllerKey.typesEngins)
        as TypesEnginsController)
            .items
        as List<TypesEngins>? ??
            [];
  }
}
