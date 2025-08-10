import 'package:test_app_divkit/me/controllers/agents_shiping_controller.dart';
import 'package:test_app_divkit/me/controllers/consignations_controller.dart';
import 'package:test_app_divkit/me/controllers/etats_engins_controller.dart';
import 'package:test_app_divkit/me/controllers/pavillons_controller.dart';
import 'package:test_app_divkit/me/controllers/pays_controller.dart';
import 'package:test_app_divkit/me/controllers/ports_controller.dart';
import 'package:test_app_divkit/me/controllers/sync_controller.dart';
import 'package:test_app_divkit/me/controllers/typenavires_controller.dart';
import 'package:test_app_divkit/me/controllers/types_engins_controller.dart';

class InspectionController {
  final SyncController _syncController = SyncController(
    controllers: {
      'ports': PortsController(),
      'pavillons': PavillonsController(),
      'typesNavire': TypenaviresController(),
      'pays': PaysController(),
      'consignataires': ConsignationsController(),
      'agents': AgentsShipingController(),
      'etatsEngins': EtatsEnginsController(),
      'typesEngins': TypesEnginsController()
    },
  );

  InspectionController();

  late Map<String, List<dynamic>> data;

  Future<void> loadData() async {
    await _syncController.syncAll();
    data = {
      'ports':
          (_syncController.getController('ports') as PortsController).items,
      'pavillons':
          (_syncController.getController('pavillons') as PavillonsController)
              .items,
      'typesNavire':
          (_syncController.getController('typesNavire')
                  as TypenaviresController)
              .items,
      'etatsEngins': (_syncController.getController('etatsEngins') as EtatsEnginsController).items,
      'typesEngins': (_syncController.getController('typesEngins') as TypesEnginsController).items,
      'pays': (_syncController.getController('pays') as PaysController).pays,
      'consignataires':
          (_syncController.getController('consignataires')
                  as ConsignationsController)
              .items,
      'agents': (_syncController.getController('agents') as AgentsShipingController).items,
    };
  }
}
