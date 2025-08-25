import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_app_divkit/me/services/database_service.dart'; // DatabaseHelper
import 'package:test_app_divkit/me/views/form_managing_test/ui/inspection_detail_screen.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_screen_load.dart';
import '../state/inspection_wizard_ctrl.dart';
import 'wizard_screen.dart';

// Ressources & écrans (on conserve le FAB existant)
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
import 'package:test_app_divkit/me/views/inspection/inspections_test_sync_screen.dart';

class InspectionListScreen extends StatefulWidget {
  const InspectionListScreen({super.key});
  @override
  State<InspectionListScreen> createState() => _InspectionListScreenState();
}

class _InspectionListScreenState extends State<InspectionListScreen> {
  late Future<List<Map<String, dynamic>>> _future;

  // Recherche par ID (champ saisi) + valeur appliquée au clic
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchApplied = '';

  // Filtre statut (0=En attente,1=En cours,2=Terminé, null=Tous)
  int? _statusFilter;

  @override
  void initState() {
    super.initState();
    _future = _getAll();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  // --------- LECTURE DEPUIS LES COLONNES DE LA TABLE -----------
  Future<List<Map<String, dynamic>>> _getAll() async {
    final db = await DatabaseHelper.database;

    final rows = await db.query(
      'inspections',
      columns: [
        'id',
        'created_at',
        'updated_at',
        'date_escale_navire',
        'date_depart_navire',
        'date_arrive_navire',
        'date_fin_inspection',
        'date_deb_inspection',
        'date_prevue_arriv_navi',
        'date_prevue_inspect',
        'titre_inspect',
        'consigne_inspect',
        'navire_id',
        'captaine_id',
        'statut_inspection_id',
        'agent_shiping_id',
        'infraction_id',
        // Optionnel: si tu gardes un JSON annexe
        'json_field',
      ],
      orderBy: 'id DESC',
    );

    return rows.map((r) {
      Map<String, dynamic> parsedJson = {};
      final rawJson = r['json_field'];
      if (rawJson != null) {
        try {
          final decoded = jsonDecode(rawJson as String);
          if (decoded is Map) parsedJson = Map<String, dynamic>.from(decoded);
        } catch (_) {}
      }

      return {
        'id': r['id'] as int,
        'cols': {
          'created_at': r['created_at'],
          'updated_at': r['updated_at'],
          'date_escale_navire': r['date_escale_navire'],
          'date_depart_navire': r['date_depart_navire'],
          'date_arrive_navire': r['date_arrive_navire'],
          'date_fin_inspection': r['date_fin_inspection'],
          'date_deb_inspection': r['date_deb_inspection'],
          'date_prevue_arriv_navi': r['date_prevue_arriv_navi'],
          'date_prevue_inspect': r['date_prevue_inspect'],
          'titre_inspect': r['titre_inspect'],
          'consigne_inspect': r['consigne_inspect'],
          'navire_id': r['navire_id'],
          'captaine_id': r['captaine_id'],
          'statut_inspection_id': r['statut_inspection_id'],
          'agent_shiping_id': r['agent_shiping_id'],
          'infraction_id': r['infraction_id'],
        },
        'data': parsedJson, // compat (ex: a.shipName)
      };
    }).toList();
  }
  // -------------------------------------------------------------

  Future<void> _reload() async => setState(() => _future = _getAll());

  Future<void> _applyFilters() async {
    // ferme le clavier
    FocusScope.of(context).unfocus();

    // Modal loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SearchingDialog(),
    );

    // Ici on pourrait relancer une requête SQL filtrée si tu veux.
    // Pour l’instant on filtre en mémoire → on simule un petit délai d’I/O.
    await Future.delayed(const Duration(milliseconds: 450));

    // Applique le texte courant comme "recherche par ID"
    setState(() {
      _searchApplied = _searchCtrl.text.trim();
      // _statusFilter est déjà dans l’état (choisi via dropdown)
    });

    // Ferme le modal
    if (mounted) Navigator.of(context, rootNavigator: true).pop();
  }

  // ---------- Helpers UI ----------
  String _fmtDate(dynamic v) {
    if (v == null) return '-';
    final s = v.toString();
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  ({String label, Color color}) _statusInfo(int? id) {
    switch (id) {
      case 0: return (label: 'En attente', color: Colors.orange);
      case 1: return (label: 'En cours',  color: Colors.blue);
      case 2: return (label: 'Terminé',   color: Colors.green);
      default: return (label: 'Inconnu',  color: Colors.grey);
    }
  }

  Widget _statusChip(String label, Color color) {
    return Chip(
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      backgroundColor: color.withOpacity(0.12),
      shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.35))),
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _infoRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87, height: 1.3),
              children: [
                TextSpan(text: '$title: ', style: const TextStyle(fontWeight: FontWeight.w600)),
                TextSpan(text: (value.isEmpty ? '-' : value)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _inspectionCard({
    required BuildContext context,
    required int id,
    required Map<String, dynamic> cols,
    required Map<String, dynamic> data,
    required VoidCallback onOpen,
    VoidCallback? onArrowTap,
  }) {
    // Titre prioritaire: depuis la colonne titre_inspect
    String title = (cols['titre_inspect']?.toString().trim().isNotEmpty ?? false)
        ? cols['titre_inspect'].toString()
        : '(Inspection)';
    // fallback optionnel sur data['a'].shipName (JSON annexe)
    if (title == '(Inspection)' && data.isNotEmpty) {
      final a = data['a'];
      if (a is Map) {
        final shipName = a['shipName'];
        if (shipName != null && shipName.toString().trim().isNotEmpty) {
          title = shipName.toString();
        }
      }
    }

    final createdAt            = _fmtDate(cols['created_at']);
    final datePrevArrivNavire  = _fmtDate(cols['date_prevue_arriv_navi']);
    final datePrevueInspection = _fmtDate(cols['date_prevue_inspect']);
    final consigne             = (cols['consigne_inspect'] ?? '-').toString();

    final statutId = (cols['statut_inspection_id'] is int)
        ? cols['statut_inspection_id'] as int
        : int.tryParse('${cols['statut_inspection_id'] ?? ''}');
    final st = _statusInfo(statutId);

    // Code dossier demandé
    final String dossierCode = 'INSP-CSP-025-000$id';

    return Card(
      elevation: 3,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header dégradé orange
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    const Color(0xFFFF6A00).withOpacity(0.95),
                    const Color(0xFFFF6A00).withOpacity(0.75),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.folder_open, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          dossierCode,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  // Expanded(
                  //   child: Text(
                  //     title,
                  //     maxLines: 1,
                  //     overflow: TextOverflow.ellipsis,
                  //     style: const TextStyle(
                  //       color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(width: 8),
                  _statusChip(st.label, st.color),
                  const SizedBox(width: 8),

                ],
              ),
            ),

            // Corps (informations issues des colonnes)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                children: [
                  _infoRow(Icons.event_available, 'Créée le', createdAt),
                  const SizedBox(height: 6),
                  _infoRow(Icons.directions_boat, 'Arrivée prévue', datePrevArrivNavire),
                  const SizedBox(height: 6),
                  _infoRow(Icons.assignment_turned_in, 'Inspection prévue', datePrevueInspection),
                  const SizedBox(height: 6),
                  _infoRow(Icons.notes, 'Consigne', consigne),
                ],
              ),
            ),

            // Actions
            // Actions
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Flèche — visible seulement si statut != 2
                  if (statutId != 2)
                    IconButton.filledTonal(
                      tooltip: 'Lancer l’inspection',
                      onPressed: onArrowTap, // -> lance le Wizard (inchangé côté appelant)
                      icon: const Icon(Icons.north_east),
                    ),
                  const SizedBox(width: 8),
                  // Œil — ouvre le détail
                  IconButton.filled(
                    tooltip: 'Voir le détail',
                    onPressed: onOpen, // -> ouvre l’écran de détail (voir appel ci-dessous)
                    icon: const Icon(Icons.remove_red_eye),
                  ),
                ],
              ),
            ),

          ],
        ),
      ),
    );
  }

  // --------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspections (DB direct)')),

      // On conserve le FAB et la route via ressources[ressources.length-1]['screen']
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ressources[ressources.length - 1]['screen']),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle'),
      ),

      body: Column(
        children: [
          // Barre de recherche + filtre statut + bouton Rechercher
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                // Champ ID
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      hintText: 'Rechercher une inspection par ID…',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    // onChanged: (v) => setState(() {}), // si tu veux filtrer en live
                  ),
                ),
                const SizedBox(width: 8),

                // Filtre statut
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<int>(
                    value: _statusFilter ?? -1, // -1 => Tous
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    items: const [
                      DropdownMenuItem(value: -1, child: Text('Tous les statuts')),
                      DropdownMenuItem(value: 0, child: Text('En attente')),
                      DropdownMenuItem(value: 1, child: Text('En cours')),
                      DropdownMenuItem(value: 2, child: Text('Terminé')),
                    ],
                    onChanged: (v) {
                      setState(() {
                        _statusFilter = (v == null || v == -1) ? null : v;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 3),

                // Bouton rechercher (affiche un modal loader)
                FilledButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.manage_search),
                  label: const Text(''),
                ),
              ],
            ),
          ),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (_, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Erreur: ${snap.error}'));
                }
                final all = snap.data ?? [];

                // Filtre ID (appliqué au clic sur Rechercher)
                List<Map<String, dynamic>> items = all;
                final idSearch = int.tryParse(_searchApplied);
                if (_searchApplied.isNotEmpty && idSearch != null) {
                  items = items.where((e) => (e['id'] as int) == idSearch).toList();
                }

                // Filtre statut (si sélectionné)
                if (_statusFilter != null) {
                  items = items.where((e) {
                    final cols = e['cols'] as Map<String, dynamic>;
                    final raw = cols['statut_inspection_id'];
                    final st = (raw is int) ? raw : int.tryParse('${raw ?? ''}');
                    return st == _statusFilter;
                  }).toList();
                }

                if (items.isEmpty) {
                  return const Center(child: Text('Aucune inspection.'));
                }

                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final r = items[i];
                      final id = r['id'] as int;
                      final cols = Map<String, dynamic>.from(r['cols'] ?? {});
                      final data = Map<String, dynamic>.from(r['data'] ?? {});

                      return  _inspectionCard(
                        context: ctx,
                        id: id,
                        cols: cols,
                        data: data,
                        // OUVRIR LE DÉTAIL (œil + tap sur la card)
                        onOpen: () async {
                          await Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => InspectionDetailScreen(inspectionId: id),
                            ),
                          );
                          await _reload();
                        },
                        // LANCER L’INSPECTION (flèche)
                        onArrowTap: () async {
                          await Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => ChangeNotifierProvider<InspectionWizardCtrl>(
                                create: (_) => InspectionWizardCtrl(),
                                child: WizardScreen(inspectionId: id, key: ValueKey('wizard_$id')),
                              ),
                            ),
                          );
                          await _reload();
                        },
                      );

                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- Ressources (gardées telles quelles pour le FAB) ---
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
}

// --- Petit dialog de chargement pour la recherche ---
class _SearchingDialog extends StatelessWidget {
  const _SearchingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3)),
            SizedBox(width: 16),
            Text('Recherche en cours…', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
