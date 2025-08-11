import 'package:test_app_divkit/me/controllers/pavillons_controller.dart';
import 'package:test_app_divkit/me/controllers/pays_controller.dart';
import 'package:test_app_divkit/me/controllers/ports_controller.dart';
import 'package:test_app_divkit/me/controllers/sync_controller.dart';
import 'package:test_app_divkit/me/controllers/typenavires_controller.dart';
import 'package:test_app_divkit/me/models/pavillons_model.dart';
import 'package:test_app_divkit/me/models/pays_model.dart';
import 'package:test_app_divkit/me/models/ports_model.dart';
import 'package:test_app_divkit/me/models/typenavires_model.dart';

class StepOneController {
  StepOneController();

  final SyncController _syncController = SyncController.instance;

  late List<Ports> portsList;
  late List<Pavillons> pavillonsList;
  late List<Typenavires> typesNavireList;
  late List<Pays> pays;
  late List<dynamic> motifsEntreeList;

  Future<void> loadData() async {
    await _syncController.loadAll();

    portsList =
        ((_syncController.getController(ControllerKey.ports) as PortsController)
                .items
            as List<Ports>?) ??
        [];
    pavillonsList =
        /*((_syncController.getController(ControllerKey.pavillons)
                    as PavillonsController)
                .items
            as List<Pavillons>?) ?? */
        [];
    typesNavireList =
        ((_syncController.getController(ControllerKey.typesNavire)
                    as TypenaviresController)
                .items
            as List<Typenavires>?) ??
        [];
    pays =
        ((_syncController.getController(ControllerKey.pays) as PaysController)
                .pays
            as List<Pays>?) ??
        [];
    motifsEntreeList = [];
  }
}
