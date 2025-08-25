import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_app_divkit/me/services/database_service.dart'; // DatabaseHelper
import '../state/inspection_wizard_ctrl.dart';
import 'wizard_screen.dart';

class InspectionDetailScreen extends StatefulWidget {
  final int inspectionId;
  const InspectionDetailScreen({super.key, required this.inspectionId});

  @override
  State<InspectionDetailScreen> createState() => _InspectionDetailScreenState();
}

class _InspectionDetailScreenState extends State<InspectionDetailScreen> {
  late Future<Map<String, dynamic>> _future;
  Color get _orange => const Color(0xFFFF6A00);

  // cache libellés {table: {id: label}}
  final Map<String, Map<int, String>> _labelCache = {};

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  // -------- LOAD + LABEL RESOLVER ----------
  Future<Map<String, dynamic>> _load() async {
    final db = await DatabaseHelper.database;
    final rows = await db.query(
      'inspections',
      where: 'id = ?',
      whereArgs: [widget.inspectionId],
      limit: 1,
    );
    if (rows.isEmpty) throw Exception('Inspection introuvable (#${widget.inspectionId})');
    final r = rows.first;

    // toutes les colonnes
    final cols = Map<String, dynamic>.from(r);

    // JSON sections (a..e)
    Map<String, dynamic> data = {};
    if (r['json_field'] != null) {
      try {
        final raw = jsonDecode(r['json_field'] as String);
        if (raw is Map) data = Map<String, dynamic>.from(raw);
      } catch (_) {}
    }

    // Pré-résolutions utiles (best-effort)
    // section A
    await _resolveKeyFromA(db, data, 'portInspection', ['ports', 'ports_inspection', 'port']);
    await _resolveKeyFromA(db, data, 'typeNavire', ['typenavires', 'type_navires', 'type_navire']);
    await _resolveKeyFromA(db, data, 'paysEscale', ['pays', 'countries']);
    await _resolveKeyFromA(db, data, 'portEscale', ['ports', 'ports_escale']);
    // section B
    await _resolveKeyFromB(db, data, 'societeConsignataire', ['consignations', 'societes_consignataires']);
    await _resolveKeyFromB(db, data, 'agentShipping', ['agents_shiping', 'agents_shipping', 'agents_ship']);
    await _resolveKeyFromB(db, data, 'nationaliteCapitaine', ['pays', 'countries']);
    await _resolveKeyFromB(db, data, 'nationaliteProprietaire', ['pays', 'countries']);
    // section E (captures)
    await _warmupTables(db, {
      'especes': ['libelle', 'name'],
      'presentations': ['libelle', 'name'],
      'conservations': ['libelle', 'name'],
      'zones_capture': ['libelle', 'name'],
      'zones': ['libelle', 'name'],
    });

    return {'cols': cols, 'data': data};
  }

  Future<void> _resolveKeyFromA(dynamic db, Map<String, dynamic> data, String key, List<String> tables) async {
    if (data['a'] is! Map) return;
    final v = (data['a'][key])?.toString();
    if (v == null || v.isEmpty) return;
    await _lookupLabelFromTables(db, tables, v);
  }

  Future<void> _resolveKeyFromB(dynamic db, Map<String, dynamic> data, String key, List<String> tables) async {
    if (data['b'] is! Map) return;
    final v = (data['b'][key])?.toString();
    if (v == null || v.isEmpty) return;
    await _lookupLabelFromTables(db, tables, v);
  }

  Future<void> _warmupTables(dynamic db, Map<String, List<String>> tables) async {
    for (final t in tables.keys) {
      _labelCache[t] ??= {};
      // pas besoin de charger toute la table; on résoudra à la demande
    }
  }

  Future<String?> _lookupLabelFromTables(dynamic dbOrFuture, List<String> tables, dynamic id) async {
    // supporte Database ou Future<Database>
    final db = (dbOrFuture is Future) ? await dbOrFuture : dbOrFuture;
    for (final t in tables) {
      final lbl = await _lookupLabel(db, t, id);
      if (lbl != null) return lbl;
    }
    return null;
  }

  Future<String?> _lookupLabel(dynamic dbOrFuture, String table, dynamic id) async {
    // supporte Database ou Future<Database>
    final db = (dbOrFuture is Future) ? await dbOrFuture : dbOrFuture;

    final intId = int.tryParse(id.toString());
    if (intId == null) return null;

    final tableCache = _labelCache.putIfAbsent(table, () => {});
    if (tableCache.containsKey(intId)) return tableCache[intId];

    const candidates = ['libelle', 'label', 'name', 'nom', 'title', 'designation'];
    try {
      final row = await db.query(table, where: 'id = ?', whereArgs: [intId], limit: 1);
      if (row.isEmpty) return null;
      final m = row.first;

      for (final c in candidates) {
        if (m.containsKey(c) && m[c] != null && m[c].toString().trim().isNotEmpty) {
          tableCache[intId] = m[c].toString();
          return tableCache[intId];
        }
      }
      for (final e in m.entries) {
        if (e.key != 'id' && e.value != null && e.value.toString().trim().isNotEmpty) {
          tableCache[intId] = e.value.toString();
          return tableCache[intId];
        }
      }
    } catch (_) {
      // ignore
    }
    return null;
  }

  Future<List<String>> _lookupLabels(dynamic dbOrFuture, List<String> tables, List ids) async {
    // supporte Database ou Future<Database>
    final db = (dbOrFuture is Future) ? await dbOrFuture : dbOrFuture;

    final labels = <String>[];
    for (final raw in ids) {
      final lbl = await _lookupLabelFromTables(db, tables, raw);
      labels.add(lbl ?? raw.toString());
    }
    return labels;
  }
  // -----------------------------------------



  // ---------- Utils ----------
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

  bool _notBlank(Object? x) =>
      x != null && x.toString().trim().isNotEmpty && x.toString().toLowerCase() != 'null';

  // Progress calc → (done, total, pct) — plus précis
  ({int done, int total, double pct}) _progressA(Map<String, dynamic>? a) {
    if (a == null) return (done: 0, total: 16, pct: 0);
    final keys = [
      'dateArriveeEffective','dateDebutInspection','dateEscaleNavire','portInspection','typeNavire',
      'paysEscale','portEscale','objet','maillage','dimensionsCales','marquageNavire','baliseVMS',
      'observation','demandePrealablePort'
    ];
    int done = keys.where((k) => _notBlank(a[k])).length;
    // objets (liste)
    if ((a['objets'] is List) && (a['objets'] as List).isNotEmpty) done++;
    // observateurEmbarque (bloc)
    if (a['observateurEmbarque'] is Map) {
      final ob = a['observateurEmbarque'] as Map;
      final subKeys = ['present','nom','prenom','fonction','entreprise','numeroDoc'];
      final any = subKeys.any((k) => _notBlank(ob[k]));
      if (any) done++;
    }
    final total = keys.length + 2;
    return (done: done, total: total, pct: total == 0 ? 0 : done / total);
  }

  ({int done, int total, double pct}) _progressB(Map<String, dynamic>? b) {
    if (b == null) return (done: 0, total: 8, pct: 0);
    final keys = [
      'societeConsignataire','agentShipping','nationaliteCapitaine','nomCapitaine',
      'passeportCapitaine','nationaliteProprietaire','nomProprietaire','dateExpirationPasseport'
    ];
    final done = keys.where((k) => _notBlank(b[k])).length;
    final total = keys.length;
    return (done: done, total: total, pct: total == 0 ? 0 : done / total);
  }

  ({int done, int total, double pct}) _progressC(Map<String, dynamic>? c) {
    if (c == null) return (done: 0, total: 1, pct: 0);
    final docs = (c['documents'] is List) ? (c['documents'] as List) : const [];
    final done = docs.isEmpty ? 0 : 1;
    return (done: done, total: 1, pct: done.toDouble());
  }

  ({int done, int total, double pct}) _progressD(Map<String, dynamic>? d) {
    if (d == null) return (done: 0, total: 1, pct: 0);
    final engins = (d['engins'] is List) ? (d['engins'] as List) : const [];
    final done = engins.isEmpty ? 0 : 1;
    return (done: done, total: 1, pct: done.toDouble());
  }

  ({int done, int total, double pct}) _progressE(Map<String, dynamic>? e) {
    if (e == null) return (done: 0, total: 6, pct: 0);

    final all = <Map<String, dynamic>>[];
    for (final k in ['captureDebarque','captureABord','captureInterdite']) {
      final rawList = e[k];
      if (rawList is List) {
        all.addAll(
          rawList
              .whereType<Map>()                                  // garde seulement les Map
              .map<Map<String, dynamic>>((m) => Map<String, dynamic>.from(m)), // re-typage fort
        );
      }
    }

    if (all.isEmpty) return (done: 0, total: 6, pct: 0);

    bool hasEspece = false, hasZone = false, hasPres = false, hasCons = false, hasQObs = false, hasQDec = false;
    for (final m in all) {
      hasEspece |= (m['especeId']?.toString().isNotEmpty ?? false);
      hasZone   |= (m['zoneIds'] is List) && (m['zoneIds'] as List).isNotEmpty;
      hasPres   |= (m['presentationId']?.toString().isNotEmpty ?? false);
      hasCons   |= (m['conservationId']?.toString().isNotEmpty ?? false);
      hasQObs   |= (m['quantiteObservee']?.toString().isNotEmpty ?? false);
      hasQDec   |= (m['quantiteDeclaree']?.toString().isNotEmpty ?? false);
    }
    final flags = [hasEspece, hasZone, hasPres, hasCons, hasQObs, hasQDec];
    final done = flags.where((b) => b).length;
    return (done: done, total: 6, pct: done / 6.0);
  }

  // ---------- UI pieces ----------
  Widget _chipStatus(String text, Color color) {
    return Chip(
      label: Text(text, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      backgroundColor: color.withOpacity(0.12),
      shape: StadiumBorder(side: BorderSide(color: color.withOpacity(0.35))),
    );
  }

  Widget _chipInfo(String label, String value) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: Colors.grey.shade100,
      shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
    );
  }

  Widget _kv(IconData icon, String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(key, style: const TextStyle(color: Colors.black54)),
                const SizedBox(height: 2),
                Text(val.isEmpty ? '-' : val, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTile({
    required IconData leading,
    required String title,
    required ({int done, int total, double pct}) progress,
    required Widget content,
    Color? color,
    bool initiallyExpanded = false,
  }) {
    final pct = progress.pct.clamp(0.0, 1.0);
    final barColor = color ?? _orange;
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          leading: Icon(leading, color: barColor),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(value: pct, minHeight: 6, color: barColor),
              ),
              const SizedBox(height: 4),
              Text('${progress.done}/${progress.total} champs • ${(pct * 100).round()}%',
                  style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          children: [content],
        ),
      ),
    );
  }

  Widget _imagesGrid(List<String> paths) {
    if (paths.isEmpty) return const SizedBox.shrink();
    return GridView.builder(
      itemCount: paths.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1,
      ),
      itemBuilder: (_, i) {
        final p = paths[i];
        return GestureDetector(
          onTap: () => _showImage(p),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: File(p).existsSync()
                ? Image.file(File(p), fit: BoxFit.cover)
                : Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.broken_image),
            ),
          ),
        );
      },
    );
  }

  void _showImage(String path) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            InteractiveViewer(
              minScale: 0.5,
              maxScale: 4,
              child: File(path).existsSync()
                  ? Image.file(File(path), fit: BoxFit.contain)
                  : Container(
                color: Colors.grey.shade200,
                width: double.infinity,
                height: 400,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image, size: 48),
              ),
            ),
            Positioned(
              right: 8, top: 8,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            )
          ],
        ),
      ),
    );
  }
  // ------------------------------------------

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snap.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Détail inspection')),
            body: Center(child: Text('Erreur: ${snap.error}')),
          );
        }

        final row = snap.data!;
        final cols = Map<String, dynamic>.from(row['cols']);
        final data = Map<String, dynamic>.from(row['data']);

        final id = cols['id'] as int;
        final dossierCode = 'INSP-CSP-025-000$id';
        final statutId = (cols['statut_inspection_id'] is int)
            ? cols['statut_inspection_id'] as int
            : int.tryParse('${cols['statut_inspection_id'] ?? ''}');
        final st = _statusInfo(statutId);

        final title =
        (cols['titre_inspect']?.toString().trim().isNotEmpty ?? false)
            ? cols['titre_inspect'].toString()
            : (data['a']?['shipName']?.toString() ?? '(Inspection)');

        final createdAt = _fmtDate(cols['created_at']);
        final updatedAt = _fmtDate(cols['updated_at']);
        final prevArrive = _fmtDate(cols['date_prevue_arriv_navi']);
        final prevInspect = _fmtDate(cols['date_prevue_inspect']);
        final consigne = (cols['consigne_inspect'] ?? '-').toString();

        // sections
        final a = (data['a'] is Map) ? Map<String, dynamic>.from(data['a']) : null;
        final b = (data['b'] is Map) ? Map<String, dynamic>.from(data['b']) : null;
        final c = (data['c'] is Map) ? Map<String, dynamic>.from(data['c']) : null;
        final d = (data['d'] is Map) ? Map<String, dynamic>.from(data['d']) : null;
        final e = (data['e'] is Map) ? Map<String, dynamic>.from(data['e']) : null;

        final pA = _progressA(a);
        final pB = _progressB(b);
        final pC = _progressC(c);
        final pD = _progressD(d);
        final pE = _progressE(e);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Détail inspection'),
            actions: [
              if (statutId != 2)
                IconButton(
                  tooltip: 'Lancer l’inspection',
                  icon: const Icon(Icons.north_east),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider<InspectionWizardCtrl>(
                          create: (_) => InspectionWizardCtrl(),
                          child: WizardScreen(inspectionId: id, key: ValueKey('wizard_$id')),
                        ),
                      ),
                    );
                    if (mounted) setState(() => _future = _load());
                  },
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 24),
            children: [
              // Header
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [_orange.withOpacity(0.95), _orange.withOpacity(0.75)],
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.folder_open, size: 16, color: Colors.white),
                                    const SizedBox(width: 6),
                                    Text(dossierCode, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _chipStatus(st.label, st.color),
                              _chipInfo('Créée le', createdAt),
                              _chipInfo('MAJ le', updatedAt),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _kv(Icons.directions_boat, 'Arrivée prévue', prevArrive),
                          _kv(Icons.assignment_turned_in, 'Inspection prévue', prevInspect),
                          _kv(Icons.notes, 'Consigne', consigne),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // SECTION A — TOUS LES CHAMPS
              _sectionTile(
                leading: Icons.info_outline,
                title: 'Section A — Données initiales',
                progress: pA,
                initiallyExpanded: true,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv(Icons.event_available, 'Arrivée effective', _fmtDate(a?['dateArriveeEffective'])),
                    _kv(Icons.event, 'Début inspection', _fmtDate(a?['dateDebutInspection'])),
                    _kv(Icons.event_note, 'Date escale navire', _fmtDate(a?['dateEscaleNavire'])),
                    _kv(Icons.place, 'Port inspection',
                        awaitLabel(a?['portInspection'], ['ports', 'ports_inspection', 'port'])),
                    _kv(Icons.sailing, 'Type navire',
                        awaitLabel(a?['typeNavire'], ['typenavires', 'type_navires', 'type_navire'])),
                    _kv(Icons.flag, 'Pays escale',
                        awaitLabel(a?['paysEscale'], ['pays', 'countries'])),
                    _kv(Icons.anchor, 'Port escale',
                        awaitLabel(a?['portEscale'], ['ports', 'ports_escale'])),
                    _kv(Icons.label_important, 'Objet', (a?['objet']?.toString() ?? '-')),
                    _kv(Icons.local_offer, 'Objets multiples',
                        (a?['objets'] is List) ? (a!['objets'] as List).map((e) => e['libelle']).join(', ') : '-'),
                    _kv(Icons.grid_on, 'Maillage', a?['maillage']?.toString() ?? '-'),
                    _kv(Icons.straighten, 'Dimensions des cales', a?['dimensionsCales']?.toString() ?? '-'),
                    _kv(Icons.directions_boat_filled, 'Marquage navire', a?['marquageNavire']?.toString() ?? '-'),
                    _kv(Icons.satellite_alt, 'Balise VMS', a?['baliseVMS']?.toString() ?? '-'),
                    _kv(Icons.info_outline, 'Observation', a?['observation']?.toString() ?? '-'),
                    _kv(Icons.how_to_vote, 'Demande préalable port',
                        (a?['demandePrealablePort'] == true) ? 'Oui' : 'Non'),
                    const SizedBox(height: 8),
                    const Text('Observateur embarqué', style: TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    _kv(Icons.visibility, 'Présent', (a?['observateurEmbarque']?['present'] == true) ? 'Oui' : 'Non'),
                    _kv(Icons.person, 'Nom', a?['observateurEmbarque']?['nom']?.toString() ?? '-'),
                    _kv(Icons.person_outline, 'Prénom', a?['observateurEmbarque']?['prenom']?.toString() ?? '-'),
                    _kv(Icons.badge, 'Fonction', a?['observateurEmbarque']?['fonction']?.toString() ?? '-'),
                    _kv(Icons.apartment, 'Entreprise', a?['observateurEmbarque']?['entreprise']?.toString() ?? '-'),
                    _kv(Icons.credit_card, 'Numéro doc', a?['observateurEmbarque']?['numeroDoc']?.toString() ?? '-'),
                  ],
                ),
              ),

              // SECTION B
              _sectionTile(
                leading: Icons.groups_2_outlined,
                title: 'Section B — Acteurs & Consignation',
                progress: pB,
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv(Icons.business, 'Société consignataire',
                        awaitLabel(b?['societeConsignataire'], ['consignations', 'societes_consignataires'])),
                    _kv(Icons.badge, 'Agent shipping',
                        awaitLabel(b?['agentShipping'], ['agents_shiping', 'agents_shipping', 'agents_ship'])),
                    _kv(Icons.flag, 'Nationalité capitaine',
                        awaitLabel(b?['nationaliteCapitaine'], ['pays', 'countries'])),
                    _kv(Icons.person, 'Capitaine', b?['nomCapitaine']?.toString() ?? '-'),
                    _kv(Icons.account_box_rounded, 'Passeport', b?['passeportCapitaine']?.toString() ?? '-'),
                    _kv(Icons.flag_outlined, 'Nationalité propriétaire',
                        awaitLabel(b?['nationaliteProprietaire'], ['pays', 'countries'])),
                    _kv(Icons.person_outline, 'Propriétaire', b?['nomProprietaire']?.toString() ?? '-'),
                    _kv(Icons.event, 'Expiration passeport', _fmtDate(b?['dateExpirationPasseport'])),
                  ],
                ),
              ),

              // SECTION C
              _sectionTile(
                leading: Icons.description_outlined,
                title: 'Section C — Documents',
                progress: pC,
                content: _docsList(c),
              ),

              // SECTION D
              _sectionTile(
                leading: Icons.build_outlined,
                title: 'Section D — Engins à bord',
                progress: pD,
                content: _enginsList(d),
              ),

              // SECTION E — DÉTAILS COMPLETS CAPTURES
              _sectionTile(
                leading: Icons.camera_alt_outlined,
                title: 'Section E — Captures & Photos (détails complets)',
                progress: pE,
                content: _capturesDetailed(e),
              ),
            ],
          ),

          // bouton flotant (wizard) caché si Terminé
          floatingActionButton: (statutId == 2)
              ? null
              : FloatingActionButton.extended(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider<InspectionWizardCtrl>(
                    create: (_) => InspectionWizardCtrl(),
                    child: WizardScreen(inspectionId: id, key: ValueKey('wizard_$id')),
                  ),
                ),
              );
              if (mounted) setState(() => _future = _load());
            },
            icon: const Icon(Icons.north_east),
            label: const Text('Lancer l’inspection'),
          ),
        );
      },
    );
  }

  // ---------- Content builders ----------
  Widget _docsList(Map<String, dynamic>? c) {
    final docs = (c?['documents'] is List) ? (c!['documents'] as List) : const [];
    if (docs.isEmpty) return const Text('Aucun document.');
    return Column(
      children: List.generate(docs.length, (i) {
        final d = Map<String, dynamic>.from(docs[i] as Map);
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.article_outlined),
          title: Text(d['typeDocumentLabel']?.toString() ?? 'Document'),
          subtitle: Text('ID: ${d['identifiant'] ?? '-'} • Émis: ${d['dateEmission'] ?? '-'} • Expire: ${d['dateExpiration'] ?? '-'}'),
        );
      }),
    );
  }

  Widget _enginsList(Map<String, dynamic>? d) {
    final engins = (d?['engins'] is List) ? (d!['engins'] as List) : const [];
    if (engins.isEmpty) return const Text('Aucun engin saisi.');
    return Column(
      children: List.generate(engins.length, (i) {
        final e = Map<String, dynamic>.from(engins[i] as Map);
        return ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.settings_input_antenna),
          title: Text(e['typeEnginLabel']?.toString() ?? 'Engin'),
          subtitle: Text('État: ${e['etatEnginLabel'] ?? '-'} • Obs: ${e['observation'] ?? '-'}'),
        );
      }),
    );
  }

  // ------- CAPTURES : DÉTAIL COMPLET -------
  Widget _capturesDetailed(Map<String, dynamic>? e) {
    if (e == null) return const Text('Non commencé.');
    final deb = (e['captureDebarque'] is List) ? (e['captureDebarque'] as List) : const [];
    final bord = (e['captureABord'] is List) ? (e['captureABord'] as List) : const [];
    final inter = (e['captureInterdite'] is List) ? (e['captureInterdite'] as List) : const [];

    if (deb.isEmpty && bord.isEmpty && inter.isEmpty) return const Text('Aucune capture.');

    Widget section(String title, List list) {
      if (list.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Column(
            children: List.generate(list.length, (i) {
              final m = Map<String, dynamic>.from(list[i] as Map);
              final paths = (m['imagePaths'] is List) ? List<String>.from(m['imagePaths']) : <String>[];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8, runSpacing: 8,
                        children: [
                          _miniChip('UUID', m['uuid']?.toString() ?? '-'),
                          FutureBuilder<String?>(
                            future: _lookupLabelFromTables(DatabaseHelper.database, ['especes'], m['especeId']),
                            builder: (_, s) => _miniChip('Espèce', s.data ?? (m['especeId']?.toString() ?? '-')),
                          ),
                          FutureBuilder<List<String>>(
                            future: _lookupLabels(
                              DatabaseHelper.database,
                              ['zones_capture', 'zones'],
                              (m['zoneIds'] is List) ? (m['zoneIds'] as List) : const [],
                            ),
                            builder: (_, s) => _miniChip('Zones', (s.data == null || s.data!.isEmpty) ? '-' : s.data!.join(', ')),
                          ),
                          FutureBuilder<String?>(
                            future: _lookupLabelFromTables(DatabaseHelper.database, ['presentation_produit'], m['presentationId']),
                            builder: (_, s) => _miniChip('Présentation', s.data ?? (m['presentationId']?.toString() ?? '-')),
                          ),
                          FutureBuilder<String?>(
                            future: _lookupLabelFromTables(DatabaseHelper.database, ['conservations'], m['conservationId']),
                            builder: (_, s) => _miniChip('Conservation', s.data ?? (m['conservationId']?.toString() ?? '-')),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _kv(Icons.scale, 'Quantité observée', m['quantiteObservee']?.toString() ?? '-'),
                      _kv(Icons.fact_check, 'Quantité déclarée', m['quantiteDeclaree']?.toString() ?? '-'),
                      _kv(Icons.backup_table, 'Quantité retenue', m['quantiteRetenue']?.toString() ?? '-'),
                      _kv(Icons.notes, 'Observations', m['observations']?.toString() ?? '-'),
                      if (paths.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        _imagesGrid(paths),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        section('Captures débarquées', deb),
        section('Captures à bord', bord),
        section('Captures interdites', inter),
      ],
    );
  }

  Widget _miniChip(String k, String v) {
    return Chip(
      label: Text('$k: $v'),
      backgroundColor: Colors.grey.shade100,
      shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  // --- Helpers de label async pour Section A/B (UI) ---
  String awaitLabel(dynamic id, List<String> tables) {
    // Cette version “affiche vite” l’id; un FutureBuilder détaillé pourrait le remplacer.
    // Pour garder l’UI fluide, on renvoie l’id si pas encore résolu (la plupart des A sont déjà résolus au _load()).
    final intId = int.tryParse(id?.toString() ?? '');
    if (intId == null) return '-';

    for (final t in tables) {
      final cache = _labelCache[t];
      if (cache != null && cache.containsKey(intId)) {
        return cache[intId]!;
      }
    }
    // fallback immédiat
    return intId.toString();
  }
}
