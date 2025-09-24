import 'package:e_Inspection_APP/me/controllers/activites_navires_controller.dart';
import 'package:e_Inspection_APP/me/controllers/pavillons_controller.dart';
import 'package:e_Inspection_APP/me/controllers/pays_controller.dart';
import 'package:e_Inspection_APP/me/controllers/ports_controller.dart';
import 'package:e_Inspection_APP/me/controllers/sync_controller.dart';
import 'package:e_Inspection_APP/me/controllers/typenavires_controller.dart';
import 'package:e_Inspection_APP/me/models/activites_navires_model.dart';
import 'package:e_Inspection_APP/me/models/pavillons_model.dart';
import 'package:e_Inspection_APP/me/models/pays_model.dart';
import 'package:e_Inspection_APP/me/models/ports_model.dart';
import 'package:e_Inspection_APP/me/models/typenavires_model.dart';

class MyStepOneController {
  MyStepOneController();

  final SyncController _syncController = SyncController.instance;

  late List<Ports> portsList;
  // late List<Pavillons> pavillonsList;
  late List<Typenavires> typesNavireList;
  late List<Pays> pays;
  late List<ActivitesNavires> motifsEntreeList;

  Future<void> loadData() async {
    await _syncController.loadAll();

    portsList =
        ((_syncController.getController(ControllerKey.ports) as PortsController)
            .items
        as List<Ports>?) ??
            [];
    // pavillonsList =
    //     ((_syncController.getController(ControllerKey.pays)
    //                 as PavillonsController)
    //             .items
    //         as List<Pavillons>?) ??
    //     [];
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
    motifsEntreeList =  ((_syncController.getController(ControllerKey.motifEntree) as ActivitesNaviresController)
        .items
    as List<ActivitesNavires>?) ??
        [];
  }
}
