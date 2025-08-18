import 'package:test_app_divkit/me/controllers/activites_navires_controller.dart';
import 'package:test_app_divkit/me/controllers/pays_controller.dart';
import 'package:test_app_divkit/me/controllers/ports_controller.dart';
import 'package:test_app_divkit/me/controllers/sync_controller.dart';
import 'package:test_app_divkit/me/controllers/typenavires_controller.dart';
import 'package:test_app_divkit/me/models/activites_navires_model.dart';
import 'package:test_app_divkit/me/models/pays_model.dart';
import 'package:test_app_divkit/me/models/ports_model.dart';
import 'package:test_app_divkit/me/models/typenavires_model.dart';

class StepOneController {
  StepOneController();

  final SyncController _syncController = SyncController.instance;

  late List<Ports> portsList;
  late List<Typenavires> typesNavireList;
  late List<Pays> paysList;
  late List<ActivitesNavires> activitesNaviresList;

  Future<void> loadData() async {
    await _syncController.loadAll();

    portsList =
        ((_syncController.getController(ControllerKey.ports) as PortsController)
                .items
            as List<Ports>?) ??
        [];
    typesNavireList =
        ((_syncController.getController(ControllerKey.typesNavire)
                    as TypenaviresController)
                .items
            as List<Typenavires>?) ??
        [];
    paysList =
        ((_syncController.getController(ControllerKey.pays) as PaysController)
                .pays
            as List<Pays>?) ??
        [];
    activitesNaviresList =
        ((_syncController.getController(ControllerKey.activitesNavires)
                    as ActivitesNaviresController)
                .items
            as List<ActivitesNavires>?) ??
        [];
  }
}
