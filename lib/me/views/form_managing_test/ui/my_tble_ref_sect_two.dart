import 'package:test_app_divkit/me/controllers/agents_shiping_controller.dart';
import 'package:test_app_divkit/me/controllers/consignations_controller.dart';
import 'package:test_app_divkit/me/controllers/pays_controller.dart';
import 'package:test_app_divkit/me/controllers/sync_controller.dart';
import 'package:test_app_divkit/me/models/agents_shiping_model.dart';
import 'package:test_app_divkit/me/models/consignations_model.dart';
import 'package:test_app_divkit/me/models/pays_model.dart';

class MyStepTwoController {
  MyStepTwoController();

  final SyncController _syncController = SyncController.instance;

  late List<Pays> pays;
  late List<Consignations> societesConsignation;
  late List<AgentsShiping> agentsShipping;

  Future<void> loadData() async {
    await _syncController.loadAll();

    pays =
        ((_syncController.getController(ControllerKey.pays) as PaysController)
            .pays
        as List<Pays>?) ??
            [];
    societesConsignation =
        ((_syncController.getController(ControllerKey.consignataires)
        as ConsignationsController)
            .items
        as List<Consignations>?) ??
            [];
    agentsShipping =
        ((_syncController.getController(ControllerKey.agents)
        as AgentsShipingController)
            .items
        as List<AgentsShiping>?) ??
            [];
  }
}
