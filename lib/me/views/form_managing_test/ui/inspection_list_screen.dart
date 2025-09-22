import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_app_divkit/me/services/database_service.dart'; // DatabaseHelper
import 'package:test_app_divkit/me/views/form_managing_test/ui/inspection_detail_screen.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_screen_load.dart';
import 'package:test_app_divkit/me/views/users/user_form.dart';
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

import 'package:test_app_divkit/me/controllers/user_controller.dart'; // ⬅️ add


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

  bool _showAlert = true; // contrôle l’affichage de l’alerte

  // Filtre statut (0=En attente,1=En cours,2=Terminé, null=Tous)
  int? _statusFilter;

  @override
  void initState() {
    super.initState();
    //_future = _getAll();
    _future = _getAllWithMinDelay(); // 👈 au lieu de _getAll()
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color get _orange => const Color(0xFFFF6A00);
  Color get _green  => const Color(0xFF27AE60);
  Color get _greyL  => const Color(0xFFEAEAEA);
  Color get _greyM  => const Color(0xFFBDBDBD);

  Future<void> _openPreviewWithLoader(BuildContext context, Map<String, dynamic> item) async {
    // 1) Loader modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 3)),
              SizedBox(width: 16),
              Text('Chargement…', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );

    // Petit délai visuel (optionnel)
    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // ferme le loader

    // 2) Ouvre le BottomSheet
    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _InspectionPreviewSheet(item: item, orange: _orange, green: _green),
    );
  }


  /// Assure au moins ~700ms d’affichage skeleton, même si la DB répond vite.
  Future<List<Map<String, dynamic>>> _getAllWithMinDelay() async {
    final results = await Future.wait([
      _getAll(),
      Future.delayed(const Duration(milliseconds: 3000)), // 1,2 sec minimum
    ]);
    return results.first as List<Map<String, dynamic>>;
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
        'json_field',        // déjà présent
        'navire_json',       // 🔹 AJOUT ICI
        // si tu veux aussi récupérer les champs FAO à titre de fallback :
        'non_navire_fao',
        'ircs_fao',
        'pavillon_navire_fao',
        'imo_num_fao',
      ],
      orderBy: 'id DESC',
    );

    return rows.map((r) {
      // Parse json_field
      Map<String, dynamic> parsedJson = {};
      final rawJson = r['json_field'];
      if (rawJson != null) {
        try {
          final decoded = (rawJson is String) ? jsonDecode(rawJson) : rawJson;
          if (decoded is Map) parsedJson = Map<String, dynamic>.from(decoded);
        } catch (_) {}
      }

      // Parse navire_json
      Map<String, dynamic>? navireJson;
      final rawNavire = r['navire_json'];
      if (rawNavire != null) {
        try {
          final decoded = (rawNavire is String) ? jsonDecode(rawNavire) : rawNavire;
          if (decoded is Map) navireJson = Map<String, dynamic>.from(decoded);
        } catch (_) {}
      }

      // On fusionne proprement dans data
      final data = <String, dynamic>{ ...parsedJson };
      if (navireJson != null) data['navire_json'] = navireJson;

      // (optionnel) on passe aussi quelques champs FAO en fallback dans data
      if (r['non_navire_fao'] != null) data['non_navire_fao'] = r['non_navire_fao'];
      if (r['ircs_fao'] != null) data['ircs_fao'] = r['ircs_fao'];
      if (r['pavillon_navire_fao'] != null) data['pavillon_navire_fao'] = r['pavillon_navire_fao'];
      if (r['imo_num_fao'] != null) data['imo_num_fao'] = r['imo_num_fao'];

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
        'data': data, // ✅ contient maintenant data['navire_json']
      };
    }).toList();
  }

  // -------------------------------------------------------------

  // Future<void> _reload() async => setState(() => _future = _getAll());  // j'ai changé le code par l'element en dessous
    Future<void> _reload() async {
      final result = await _getAll();   // on attend ici
      if (!mounted) return;
      setState(() {
        _future = Future.value(result); // on injecte un Future déjà complété
        _showAlert = true; // ✅ ré-affiche l’alerte après rechargement
      });
    }



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
      _showAlert = true; // ✅ ré-affiche l’alerte à chaque recherche
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
      case 5: return (label: 'En attente', color: Colors.orange);
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
    final createdAt = _fmtDate(cols['created_at']);
    final datePrevArrivNavire = _fmtDate(cols['date_prevue_arriv_navi']);
    final datePrevueInspection = _fmtDate(cols['date_prevue_inspect']);
    final consigne = (cols['consigne_inspect'] ?? '-').toString();

    // Nom navire
    String shipName = '-';
    final navJson = (data['navire_json'] is Map) ? data['navire_json'] as Map<String, dynamic> : null;
    if (navJson != null && (navJson['name']?.toString().trim().isNotEmpty ?? false)) {
      shipName = navJson['name'].toString();
    } else if ((data['non_navire_fao']?.toString().trim().isNotEmpty ?? false)) {
      shipName = data['non_navire_fao'].toString();
    }

    // Statut
    final statutId = int.tryParse('${cols['statut_inspection_id'] ?? ''}');
    final st = _statusInfo(statutId);

    // Code dossier
    final String dossierCode = 'INSP-CSP-025-000$id';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- HEADER dégradé orange → vert ----
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF6A00), Color(0xFF2ECC71)], // orange -> vert
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Code dossier + Navire
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dossierCode,
                      style: const TextStyle(
                        fontFamily: "Audiowide",
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.directions_boat_filled,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          shipName,
                          style: const TextStyle(
                            fontFamily: "Bariol",
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                  ],
                ),

                // Chip statut
                _statusChip(st.label, st.color),
              ],
            ),
          ),

          // ---- BODY ----
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _infoRow(Icons.event_available, 'Créée le', createdAt),
                const SizedBox(height: 8),
                _infoRow(Icons.directions_boat_filled, 'Arrivée prévue', datePrevArrivNavire),
                const SizedBox(height: 8),
                _infoRow(Icons.assignment_turned_in, 'Inspection prévue', datePrevueInspection),
                const SizedBox(height: 8),
                _infoRow(Icons.notes, 'Consigne', consigne),
              ],
            ),
          ),

          // ---- ACTIONS ----
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (statutId != 2)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2ECC71), // vert
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      // ✅ contrôle rôle (admin ou chef_equipe) avant d'exécuter onArrowTap
                      final userCtrl = UserController();
                      final allowed = await userCtrl.canContinueInspection();
                      if (!allowed) {
                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Accès refusé'),
                            content: const Text(
                                "Vous n'avez pas les droits neccessaires !"
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                        return; // ne pas appeler onArrowTap
                      }

                      // 👇 logique existante conservée : on déclenche le callback fourni
                      if (onArrowTap != null) onArrowTap();
                    },
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text("Lancer", style: TextStyle(color: Colors.white)),
                  ),

                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6A00), // orange
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onOpen,
                  icon: const Icon(Icons.remove_red_eye, color: Colors.white),
                  label: const Text("Voir détail", style: TextStyle(color: Colors.white)),
                ),

                const ProSeparator()
              ],
            ),
          ),
        ],
      ),
    );
  }


  // --------------------------------

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Liste des Inspections'),backgroundColor: Colors.orange,),

        // On conserve le FAB et la route via ressources[ressources.length-1]['screen']
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ressources[ressources.length - 2]['screen']),
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
                        DropdownMenuItem(value: 5, child: Text('En attente')),
                        DropdownMenuItem(value: 1, child: Text('En cours')),
                        DropdownMenuItem(value: 2, child: Text('Terminé')),
                      ],
                      onChanged: (v) {
                        setState(() {
                          _statusFilter = (v == null || v == -1) ? null : v;
                          _showAlert = true; // ✅ ré-affiche l’alerte quand on change le filtre
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 3),

                  // Bouton rechercher (affiche un modal loader)
                  // Bouton rechercher (affiche un modal loader)
                  FilledButton.icon(
                    onPressed: _applyFilters,
                    icon: const Icon(Icons.manage_search, color: Colors.white),
                    label: const Text(
                      'Rechercher',
                      style: TextStyle(
                        fontFamily: "Bariol",
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF27AE60), // vert prononcé
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                ],
              ),
            ),

            // ---- ALERT NB D'ÉLÉMENTS TROUVÉS ----
            if (_showAlert)
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (_, snap) {
                  if (snap.connectionState != ConnectionState.done) return const SizedBox.shrink();

                  final all = snap.data ?? [];
                  // Applique les mêmes filtres qu’en bas
                  List<Map<String, dynamic>> items = all;
                  final idSearch = int.tryParse(_searchApplied);
                  if (_searchApplied.isNotEmpty && idSearch != null) {
                    items = items.where((e) => (e['id'] as int) == idSearch).toList();
                  }
                  if (_statusFilter != null) {
                    items = items.where((e) {
                      final cols = e['cols'] as Map<String, dynamic>;
                      final raw = cols['statut_inspection_id'];
                      final st = (raw is int) ? raw : int.tryParse('${raw ?? ''}');
                      return st == _statusFilter;
                    }).toList();
                  }

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Expanded( // ✅ évite l’overflow
                          child: Text(
                            "${items.length} inspection(s) trouvée(s)",
                            style: const TextStyle(
                              fontFamily: "Bariol",
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.green,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Colors.green),
                          onPressed: () => setState(() => _showAlert = false),
                          tooltip: 'Masquer',
                        ),
                      ],
                    ),
                  );
                },
              ),



            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _future,
                builder: (_, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    //return const Center(child: CircularProgressIndicator());
                    return _buildSkeletonList();
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
                            await _openPreviewWithLoader(ctx, r); // 👈 nouveau
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
      ),
    );
  }


  // Couleur utilitaire pour skeleton sombre
  Color get _skBg => const Color(0xFFF2F2F2);   // fond très clair
  Color get _skTile => const Color(0xFFE0E0E0); // blocs clairs
  Color get _skPulse => const Color(0xFFD6D6D6); // pulsation


// Effet pulse simple (sans package)
  Widget _pulse(Widget child) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (_, val, __) => Opacity(opacity: val, child: child),
      onEnd: () => setState(() {}), // boucle “aller-retour”
    );
  }

// Barre de recherche skeleton
  Widget _buildSearchSkeleton() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Champ
          Expanded(
            child: _pulse(Container(
              height: 48,
              decoration: BoxDecoration(
                color: _skTile,
                borderRadius: BorderRadius.circular(12),
              ),
            )),
          ),
          const SizedBox(width: 8),
          // Dropdown
          _pulse(Container(
            width: 150,
            height: 48,
            decoration: BoxDecoration(
              color: _skTile,
              borderRadius: BorderRadius.circular(12),
            ),
          )),
          const SizedBox(width: 3),
          // Bouton
          _pulse(Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _skTile,
              borderRadius: BorderRadius.circular(12),
            ),
          )),
        ],
      ),
    );
  }

// Une carte skeleton sombre avec header dégradé dark
  Widget _buildSkeletonCard() {
    return _pulse(Container(
      decoration: BoxDecoration(
        color: _skTile,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header sombre
          Container(
            height: 64,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
              gradient: LinearGradient(
                colors: [Color(0xFF2D2D2D), Color(0xFF1F1F1F)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          // Corps : 4 lignes grises
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: List.generate(4, (i) => i).map((_) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: _skPulse,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Footer actions
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: _skBg,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(18)),
            ),
          ),
        ],
      ),
    ));
  }

// Liste de skeletons
  Widget _buildSkeletonList() {
    return Column(
      children: [
        _buildSearchSkeleton(),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: 5, // 5 cartes factices
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => _buildSkeletonCard(),
          ),
        ),
      ],
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
    {'title': 'inspection', 'screen': const UsersScreen()},
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

class _InspectionPreviewSheet extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color orange;
  final Color green;

  const _InspectionPreviewSheet({required this.item, required this.orange, required this.green});

  @override
  Widget build(BuildContext context) {
    final id   = item['id'] as int;
    final cols = Map<String, dynamic>.from(item['cols'] ?? {});
    final data = Map<String, dynamic>.from(item['data'] ?? {});
    final String dossierCode = 'INSP-CSP-025-000$id';

    // Nom navire (depuis navire_json → fallback)
    String shipName = '-';
    final navJson = (data['navire_json'] is Map) ? Map<String, dynamic>.from(data['navire_json']) : null;
    if (navJson != null && (navJson['name']?.toString().trim().isNotEmpty ?? false)) {
      shipName = navJson['name'].toString();
    } else if ((data['non_navire_fao']?.toString().trim().isNotEmpty ?? false)) {
      shipName = data['non_navire_fao'].toString();
    }

    // Dates clés
    String fmt(dynamic v) {
      if (v == null) return '-';
      final s = v.toString();
      return s.length >= 10 ? s.substring(0, 10) : s;
    }
    final createdAt   = fmt(cols['created_at']);
    final prevArrive  = fmt(cols['date_prevue_arriv_navi']);
    final prevInspect = fmt(cols['date_prevue_inspect']);

    // Définition des sections et état (basé sur json_field / data)
    final sectionsDef = [
      {'code':'A','label':'Infos générales','key':'a'},
      {'code':'B','label':'Consignat & Agent Shipping','key':'b'},
      {'code':'C','label':'Contrôle des documents','key':'c'},
      {'code':'D','label':'Engins à bord','key':'d'},
      {'code':'E','label':'Captures','key':'e'},
    ];

    bool isDone(String key) {
      final v = data[key];
      if (v == null) return false;
      if (v is Map) return v.isNotEmpty;
      if (v is List) return v.isNotEmpty;
      if (v is bool) return v;
      if (v is num)  return v != 0;
      if (v is String) return v.trim().isNotEmpty && v.trim().toLowerCase() != 'false';
      return false;
    }

    final steps = sectionsDef.map((s) {
      final done = isDone(s['key'] as String);
      return {
        'code' : s['code'],
        'label': s['label'],
        'done' : done,
      };
    }).toList();

    final doneCount = steps.where((s) => s['done'] == true).length;
    final progress  = steps.isEmpty ? 0.0 : doneCount / steps.length;

    return DraggableScrollableSheet(
      initialChildSize: 0.72,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        // ----- STATUT + ETAT -----
        final rawSt = cols['statut_inspection_id'];
        final int statutId = (rawSt is int) ? rawSt : (int.tryParse('${rawSt ?? ''}') ?? -1);
        final bool isTerminated = (statutId == 2);

        // Action du bouton Continuer
        // Future<void> _onContinue() async {
        //   if (isTerminated) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       const SnackBar(content: Text('Inspection déjà terminée')),
        //     );
        //     return;
        //   }
        //   Navigator.of(context).pop();
        //   await Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (_) => ChangeNotifierProvider<InspectionWizardCtrl>(
        //         create: (_) => InspectionWizardCtrl(),
        //         child: WizardScreen(
        //           inspectionId: id,
        //           key: ValueKey('wizard_$id'),
        //         ),
        //       ),
        //     ),
        //   );
        // }

        Future<void> _onContinue() async {
          if (isTerminated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Inspection déjà terminée')),
            );
            return;
          }

          // ✅ Contrôle rôle avant d'autoriser l'ouverture du wizard
          final userCtrl = UserController();
          final allowed = await userCtrl.canContinueInspection();
          if (!allowed) {
            await showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Accès refusé'),
                content: const Text(
                    "Seuls les rôles 'admin' ou 'chef_equipe' peuvent continuer une inspection."
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
            return;
          }

          // (logique existante conservée)
          Navigator.of(context).pop();
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider<InspectionWizardCtrl>(
                create: (_) => InspectionWizardCtrl(),
                child: WizardScreen(
                  inspectionId: id,
                  key: ValueKey('wizard_$id'),
                ),
              ),
            ),
          );
        }


        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                // poignée
                Container(
                  width: 44, height: 5,
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(100)),
                ),
                const SizedBox(height: 12),

                // ====== CONTENU SCROLLABLE ======
                Expanded(
                  child: SingleChildScrollView(
                    controller: controller, // important pour scroller avec le sheet
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Header (navire + code) ---
                        Row(
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: [orange, green]),
                                boxShadow: [BoxShadow(color: orange.withOpacity(0.3), blurRadius: 8)],
                              ),
                              child: const Icon(Icons.directions_boat_filled, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.folder_open, size: 22, color: Colors.black87),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          dossierCode,
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontFamily: 'Audiowide', fontSize: 16, fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(Icons.sailing, size: 18, color: Colors.black54),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          shipName,
                                          maxLines: 1, overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontFamily: 'Bariol', fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // --- Progress ---
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: Colors.black12,
                            valueColor: AlwaysStoppedAnimation<Color>(green),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Avancement', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                            Text('${(progress * 100).round()}%', style: TextStyle(color: green, fontWeight: FontWeight.w700)),
                          ],
                        ),

                        const SizedBox(height: 14),

                        // --- Quick facts ---
                        _QuickFacts(orange: orange, createdAt: createdAt, prevArrive: prevArrive, prevInspect: prevInspect),

                        const SizedBox(height: 12),

                        // --- Timeline ---
                        ...List.generate(steps.length, (i) {
                          final s = steps[i];
                          return _TimelineTile(
                            index: i,
                            isLast: i == steps.length - 1,
                            code: s['code'] as String,
                            label: s['label'] as String,
                            done: s['done'] as bool,
                            orange: orange,
                            green: green,
                          );
                        }),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ====== FOOTER: 2 BOUTONS ======
                Row(
                  children: [
                    // Détail avancé (orange)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InspectionDetailScreen(inspectionId: id),
                            ),
                          );
                        },
                        icon: const Icon(Icons.list_alt),
                        label: const Text('Détail avancé'),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6A00),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(fontFamily: 'Bariol', fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Continuer l’inspection (vert / grisé si terminé)
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _onContinue, // gère le cas terminé
                        icon: const Icon(Icons.play_circle),
                        label: Text(isTerminated ? 'Déjà terminée' : 'Continuer'),
                        style: FilledButton.styleFrom(
                          backgroundColor: isTerminated ? Colors.grey.shade400 : green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          textStyle: const TextStyle(fontFamily: 'Bariol', fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );


  }
}

// Petite rangée de “faits rapides”
class _QuickFacts extends StatelessWidget {
  final Color orange;
  final String createdAt, prevArrive, prevInspect;
  const _QuickFacts({required this.orange, required this.createdAt, required this.prevArrive, required this.prevInspect});

  @override
  Widget build(BuildContext context) {
    TextStyle vStyle = const TextStyle(fontFamily: 'Bariol', fontWeight: FontWeight.w600);

    Widget chip(IconData ic, String t, String v) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: orange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: orange.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(ic, size: 18, color: orange),
            const SizedBox(width: 8),
            Text('$t: ', style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
            Text(v, style: vStyle),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 10, runSpacing: 10,
      children: [
        chip(Icons.event_available, 'Créée le', createdAt),
        chip(Icons.directions_boat, 'Arrivée prévue', prevArrive),
        chip(Icons.assignment, 'Inspection prévue', prevInspect),
      ],
    );
  }
}

// Une tuile de timeline custom
class _TimelineTile extends StatelessWidget {
  final int index;
  final bool isLast, done;
  final String code, label;
  final Color orange, green;

  const _TimelineTile({
    required this.index,
    required this.isLast,
    required this.done,
    required this.code,
    required this.label,
    required this.orange,
    required this.green,
  });

  @override
  Widget build(BuildContext context) {
    final Color dotColor = done ? green : orange;
    final Color lineColor = done ? green.withOpacity(0.6) : Colors.black12;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rail + Dot
        SizedBox(
          width: 32,
          child: Column(
            children: [
              // Dot
              Container(
                width: 18, height: 18,
                decoration: BoxDecoration(
                  color: done ? green : Colors.white,
                  border: Border.all(color: dotColor, width: 3),
                  shape: BoxShape.circle,
                ),
              ),
              // Ligne verticale
              if (!isLast)
                Container(
                  width: 3,
                  height: 46,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: lineColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
        ),

        // Carte d'étape
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: (done ? green : orange).withOpacity(0.25)),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 3))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: (done ? green : orange).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      fontFamily: 'Audiowide',
                      color: (done ? green : orange),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(fontFamily: 'Bariol', fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                Icon(
                  done ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: done ? green : Colors.black26,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProSeparator extends StatelessWidget {
  final String? label;
  final IconData? icon;
  const ProSeparator({super.key, this.label, this.icon});

  @override
  Widget build(BuildContext context) {
    if (label == null || label!.trim().isEmpty) {
      return Divider(
        height: 24,
        thickness: 1,
        indent: 0,
        endIndent: 0,
        color: Colors.black12.withOpacity(.15),
      );
    }
    return Row(
      children: [
        if (icon != null) Icon(icon, size: 16, color: Colors.black45),
        if (icon != null) const SizedBox(width: 6),
        //Text(label!, style: meta.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: Colors.black12.withOpacity(.15),
          ),
        ),
      ],
    );
  }
}
