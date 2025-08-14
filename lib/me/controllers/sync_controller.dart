import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/controllers/agents_shiping_controller.dart';
import 'package:test_app_divkit/me/controllers/conservations_controller.dart';
import 'package:test_app_divkit/me/controllers/consignations_controller.dart';
import 'package:test_app_divkit/me/controllers/etats_engins_controller.dart';
import 'package:test_app_divkit/me/controllers/pays_controller.dart';
import 'package:test_app_divkit/me/controllers/ports_controller.dart';
import 'package:test_app_divkit/me/controllers/presentations_controller.dart';
import 'package:test_app_divkit/me/controllers/typenavires_controller.dart';
import 'package:test_app_divkit/me/controllers/types_documents_controller.dart';
import 'package:test_app_divkit/me/controllers/types_engins_controller.dart';
import 'package:test_app_divkit/me/controllers/zones_capture_controller.dart';

import 'especes_controller.dart';

enum ControllerKey {
  ports,
  // pavillons,
  typesNavire,
  pays,
  consignataires,
  agents,
  etatsEngins,
  typesEngins,
  typesDocuments,
  especes,
  zonesCapture,
  presentationsProduit,
  conservationsProduit,
}

class SyncController extends ChangeNotifier {
  SyncController._();

  final Map<ControllerKey, dynamic> controllers = {
    ControllerKey.ports: PortsController(),
    // ControllerKey.pavillons: PavillonsController(),
    ControllerKey.typesNavire: TypenaviresController(),
    ControllerKey.pays: PaysController(),
    ControllerKey.consignataires: ConsignationsController(),
    ControllerKey.agents: AgentsShipingController(),
    ControllerKey.etatsEngins: EtatsEnginsController(),
    ControllerKey.typesEngins: TypesEnginsController(),
    ControllerKey.typesDocuments: TypesDocumentsController(),
    ControllerKey.especes: EspecesController(),
    ControllerKey.zonesCapture: ZonesCaptureController(),
    ControllerKey.presentationsProduit: PresentationsController(),
    ControllerKey.conservationsProduit: ConservationsController(),
  };

  static final SyncController _instance = SyncController._();
  static SyncController get instance => _instance;

  Future<void> syncAll() async {
    try {
      await Future.wait(
        controllers.values.map((c) async {
          return await c.loadAndSync();
        }),
      );
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadAll() async {
    try {
      await Future.wait(
        controllers.values.map((c) async {
          return await c.loadLocalOnly();
        }),
      );
    } catch (e) {
      print(e);
    } finally {
      notifyListeners();
    }
  }

  T getController<T>(ControllerKey key) => controllers[key] as T;
}
