import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app_divkit/me/services/database_service.dart';
import '../data/db.dart';
import '../state/inspection_wizard_ctrl.dart';
import 'wizard_screen.dart';


import 'package:test_app_divkit/me/views/inspection/inspection_screen_load.dart';
import 'package:test_app_divkit/me/views/inspection/inspections_test_sync_screen.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/model_form_exempl/form_1.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/model_form_exempl/form_2.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/model_form_exempl/form_3.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/section1.dart';
import 'package:test_app_divkit/me/views/inspection/welcome_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/pays.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/activites_navires_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/agents_shiping_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/conservations_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/consignations_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/especes_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/etats_engins_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/pavillons_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/ports_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/presentations_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/typenavires_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/types_documents_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/types_engins_screen.dart';
import 'package:test_app_divkit/me/views/tbl_ref_screen/zones_capture_screen.dart';

class InspectionListScreen extends StatefulWidget {
  const InspectionListScreen({super.key});
  @override
  State<InspectionListScreen> createState() => _InspectionListScreenState();
}

class _InspectionListScreenState extends State<InspectionListScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _getAll();

    //print(_future);
  }

  Future<List<Map<String, dynamic>>> _getAll() async {
    final db = await DatabaseHelper.database;
    final rows = await db.query('inspections');

    return rows.map((r) {

      final raw = jsonDecode(r['json_field'] as String);
      final data = raw is Map ? Map<String, dynamic>.from(raw) : {};

      return {
        'id': r['id'] as int,
        'data': data,
      };
    }).toList();
  }



  Future<void> _reload() async {
    setState(() => _future = _getAll());
  }

  Future<void> _seed() async {
    final db = await AppDb.instance;
    final seeds = [
      {
        "a": {"shipName": "ALPHA", "flagId": 1, "mesh": 60, "sectionVersion": 1},
        "b": {"captainName": "Kouadio", "passport": "CIV12345", "nationalityId": 225, "crewCount": 12, "sectionVersion": 1},
        "c": {"engineTypeId": 2, "length": 20, "tonnageGt": 200, "sectionVersion": 1},
        "d": {"docTypeId": 1, "docRef": "DRV-001", "hasVms": 1, "remarks": "RAS", "sectionVersion": 1}
      },
      {
        "a": {"shipName": "BRAVO", "flagId": 2, "mesh": 40, "sectionVersion": 1},
        "b": {"captainName": "Yao", "passport": "CIV67890", "nationalityId": 225, "crewCount": 10, "sectionVersion": 1},
        "c": {"engineTypeId": 1, "length": 16, "tonnageGt": 120, "sectionVersion": 1},
        "d": {"docTypeId": 2, "docRef": "DRV-002", "hasVms": 0, "remarks": "", "sectionVersion": 1}
      },
      {
        "a": {"shipName": "CHARLIE", "flagId": 3, "mesh": 55, "sectionVersion": 1},
        "b": {"captainName": "Mensah", "passport": "GH123456", "nationalityId": 233, "crewCount": 14, "sectionVersion": 1},
        "c": {"engineTypeId": 3, "length": 24, "tonnageGt": 260, "sectionVersion": 1},
        "d": {"docTypeId": 3, "docRef": "DRV-003", "hasVms": 1, "remarks": "OK", "sectionVersion": 1}
      },
      {
        "a": {"shipName": "DELTA", "flagId": 1, "mesh": 50, "sectionVersion": 1},
        "b": {"captainName": "Diallo", "passport": "SN998877", "nationalityId": 686, "crewCount": 9, "sectionVersion": 1},
        "c": {"engineTypeId": 2, "length": 18, "tonnageGt": 150, "sectionVersion": 1},
        "d": {"docTypeId": 1, "docRef": "DRV-004", "hasVms": 0, "remarks": "", "sectionVersion": 1}
      },
    ];
    final batch = db.batch();
    for (final s in seeds) {
      batch.insert('inspection', {'json_field': jsonEncode(s)});
    }
    await batch.commit(noResult: true);
    await _reload();
  }

  Future<void> _wipe() async {
    final db = await AppDb.instance;
    await db.delete('inspection_bis');
    await _reload();
  }

  final List<Map<String, dynamic>> ressources = [
    {'title': 'Pavillons', 'screen': const PaysScreen()},
    {'title': 'Typenavires', 'screen': const TypenaviresScreen()},
    {'title': 'Ports', 'screen': const PortsScreen()},
    {'title': 'ActivitesNavires', 'screen': const ActivitesNaviresScreen()},
    {'title': 'Consignations', 'screen': const ConsignationsScreen()},
    {'title': 'AgentsShiping', 'screen': const AgentsShipingScreen()},
    {'title': 'TypesDocuments', 'screen': const TypesDocumentsScreen()},
    {'title': 'TypesEngins', 'screen': const TypesEnginsScreen()},
    {'title': 'EtatsEngins', 'screen': const EtatsEnginsScreen()},
    {'title': 'Especes', 'screen': const EspecesScreen()},
    {'title': 'ZonesCapture', 'screen': const ZonesCaptureScreen()},
    {'title': 'Presentations', 'screen': const PresentationsScreen()},
    {'title': 'Conservations', 'screen': const ConservationsScreen()},
    {'title': 'inspection', 'screen': const InspectionsScreen()},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inspections (DB direct)'),
        actions: [
          IconButton(onPressed: _seed, icon: const Icon(Icons.playlist_add), tooltip: 'Seed x4 (test)'),
          IconButton(onPressed: _wipe, icon: const Icon(Icons.delete_forever), tooltip: 'Vider la table'),
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (_, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('Erreur: ${snap.error}'));
          final items = snap.data ?? [];
          if (items.isEmpty) return const Center(child: Text('Aucune inspection.'));

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = items[i];
              final id = r['id'] as int;
              final a = Map<String, dynamic>.from(r['data']?['a'] ?? {});

              final title = a['shipName']?.toString() ?? '(Sans nom)';
              final subtitle = 'ID #$id • flag=${a['flagId'] ?? '-'} • mesh=${a['mesh'] ?? '-'}';
              return ListTile(
                title: Text(title),
                subtitle: Text(subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider<InspectionWizardCtrl>(
                        create: (_) => InspectionWizardCtrl(),
                        child: WizardScreen(inspectionId: id, key: ValueKey('wizard_$id')),
                      )
                    ),
                  );
                  await _reload();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        // onPressed: () async {
        //   final db = await AppDb.instance;
        //   final newId = await db.insert('inspection', {'json_field': jsonEncode({})});
        //   if (!mounted) return;
        //   await Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (_) => ChangeNotifierProvider<InspectionWizardCtrl>(
        //       create: (_) => InspectionWizardCtrl(),
        //         child: WizardScreen(inspectionId: newId, key: ValueKey('wizard_$newId')),
        //       ),
        //     ),
        //   );
        //   await _reload();

        // },

        onPressed:() {

          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ressources[ressources.length-1]['screen']),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle'),
      ),
    );
  }
}
