import 'package:test_app_divkit/me/controllers/presentations_controller.dart';
import 'package:test_app_divkit/me/controllers/sync_controller.dart';

// ⚠️ Adapte ces imports aux tiens :
import 'package:test_app_divkit/me/controllers/especes_controller.dart';
import 'package:test_app_divkit/me/controllers/zones_capture_controller.dart';
import 'package:test_app_divkit/me/controllers/conservations_controller.dart';
import 'package:test_app_divkit/me/models/conservations_model.dart';

import 'package:test_app_divkit/me/models/especes_model.dart';
import 'package:test_app_divkit/me/models/presentations_model.dart';
import 'package:test_app_divkit/me/models/zones_capture_model.dart';

// ======================================================
// Petit DTO "normalisé" attendu par SectionEForm
// ======================================================
class RefItem {
  final String id;
  final String libelle; // peut contenir le name si pas de libelle en DB
  RefItem({required this.id, required this.libelle});
}

// ======================================================
// MyStepEController : même esprit que MyStepFourController
// ======================================================
class MyStepEController {
  MyStepEController();

  final SyncController _sync = SyncController.instance;

  late List<RefItem> especes;        // .id, .libelle
  late List<RefItem> zonesCapture;   // .id, .libelle
  late List<RefItem> presentations;  // .id, .libelle
  late List<RefItem> conservations;  // .id, .libelle

  Future<void> loadData() async {
    // 1) s’assurer que tout est bien synchronisé/chargé
    await _sync.loadAll();

    // 2) récupérer chaque controller spécifique via ControllerKey
    // ⚠️ Remplace les ControllerKey.* par tes clés existantes
    final especesCtrl = _sync.getController(ControllerKey.especes)
    as EspecesController?;
    final zonesCtrl = _sync.getController(ControllerKey.zonesCapture)
    as ZonesCaptureController?;
    final presCtrl = _sync.getController(ControllerKey.presentationsProduit)
    as PresentationsController?;
    final consCtrl = _sync.getController(ControllerKey.conservationsProduit)
    as ConservationsController?;

    // 3) sécuriser les .items (fallback = [])
    final List<Especes> rawEspeces =
        (especesCtrl?.items as List<Especes>?) ?? const [];
    final List<ZonesCapture> rawZones =
        (zonesCtrl?.items as List<ZonesCapture>?) ?? const [];
    final List<Presentations> rawPres =
        (presCtrl?.items as List<Presentations>?) ?? const [];
    final List<Conservations> rawCons =
        (consCtrl?.items as List<Conservations>?) ?? const [];

    // 4) normaliser vers RefItem (id:String, libelle:String)
    especes = rawEspeces.map((e) {
      final id = e.id?.toString() ?? '';
      final lib = ( e.name ?? '').toString();
      return RefItem(id: id, libelle: lib);
    }).where((x) => x.id.isNotEmpty).toList();

    zonesCapture = rawZones.map((z) {
      final id = z.id?.toString() ?? '';
      final lib = (z.libelle ?? '').toString();
      return RefItem(id: id, libelle: lib);
    }).where((x) => x.id.isNotEmpty).toList();

    presentations = rawPres.map((p) {
      final id = p.id?.toString() ?? '';
      final lib = (p.libelle ?? '').toString();
      return RefItem(id: id, libelle: lib);
    }).where((x) => x.id.isNotEmpty).toList();

    conservations = rawCons.map((c) {
      final id = c.id?.toString() ?? '';
      final lib = (c.libelle ?? '').toString();
      return RefItem(id: id, libelle: lib);
    }).where((x) => x.id.isNotEmpty).toList();
  }
}
