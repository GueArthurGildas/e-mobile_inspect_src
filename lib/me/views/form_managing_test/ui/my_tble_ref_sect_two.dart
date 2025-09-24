import 'package:e_Inspection_APP/me/controllers/agents_shiping_controller.dart';
import 'package:e_Inspection_APP/me/controllers/consignations_controller.dart';
import 'package:e_Inspection_APP/me/controllers/pays_controller.dart';
import 'package:e_Inspection_APP/me/controllers/sync_controller.dart';
import 'package:e_Inspection_APP/me/models/agents_shiping_model.dart';
import 'package:e_Inspection_APP/me/models/consignations_model.dart';
import 'package:e_Inspection_APP/me/models/pays_model.dart';

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
