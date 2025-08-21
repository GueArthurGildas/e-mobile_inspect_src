import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/tbl_ref_formE.dart';

import '../state/inspection_wizard_ctrl.dart';



// ======================================================
// SECTION E
// ======================================================
class SectionEForm extends StatefulWidget {
  const SectionEForm({super.key});
  @override
  State<SectionEForm> createState() => _SectionEFormState();
}

class _SectionEFormState extends State<SectionEForm>
    with AutomaticKeepAliveClientMixin {
  final _key = GlobalKey<FormState>();
  late Map<String, List<Map<String, dynamic>>> _local; // état local par catégorie

  final MyStepEController _stepCtrl = MyStepEController();
  bool _loadingRefs = true;

  Color get _orangeColor => const Color(0xFFFF6A00);

  @override
  void initState() {
    super.initState();
    _initRefs();
  }

  @override
  bool get wantKeepAlive => true;

  // =========================
  // Init listes + _local (pattern Section B)
  // =========================
  Future<void> _initRefs() async {
    await _stepCtrl.loadData();

    final initial =
        context.read<InspectionWizardCtrl>().section('e') as Map<String, dynamic>? ??
            <String, dynamic>{};

    // Helpers
    String? firstId(List<dynamic> list, dynamic Function(dynamic) idOf) {
      if (list.isEmpty) return null;
      final id = idOf(list.first);
      return id?.toString();
    }

    String? _numToStr(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toString();
      final s = v.toString().trim();
      return s.isEmpty ? null : s;
    }

    Map<String, dynamic> ensureEntryDefaults(Map<String, dynamic> entry) {
      final e = Map<String, dynamic>.from(entry);

      e['especeId'] = (e['especeId']?.toString().isNotEmpty == true)
          ? e['especeId'].toString()
          : firstId(_stepCtrl.especes, (x) => x.id);

      e['zoneIds'] = (e['zoneIds'] is List)
          ? (e['zoneIds'] as List).map((z) => z.toString()).toList()
          : <String>[];

      e['presentationId'] = (e['presentationId']?.toString().isNotEmpty == true)
          ? e['presentationId'].toString()
          : firstId(_stepCtrl.presentations, (x) => x.id);

      e['conservationId'] = (e['conservationId']?.toString().isNotEmpty == true)
          ? e['conservationId'].toString()
          : firstId(_stepCtrl.conservations, (x) => x.id);

      e['quantiteObservee'] = _numToStr(e['quantiteObservee']) ?? '';
      e['quantiteDeclaree'] = _numToStr(e['quantiteDeclaree']) ?? '';
      e['quantiteRetenue']  = _numToStr(e['quantiteRetenue'])  ?? '';

      e['observations'] = (e['observations'] ?? '').toString();

      // --- Compat + normalisation images ---
      // Accepte soit imagePath (string), soit imagePaths (List<String>)
      final legacy = (e['imagePath'] ?? '').toString().trim();
      final list = e['imagePaths'];
      if (list is List) {
        e['imagePaths'] = list.map((x) => x?.toString() ?? '').where((p) => p.isNotEmpty).toList();
      } else if (legacy.isNotEmpty) {
        e['imagePaths'] = [legacy];
      } else {
        e['imagePaths'] = <String>[];
      }
      e.remove('imagePath');

      e['uuid'] = (e['uuid'] ?? UniqueKey().toString()).toString();
      return e;
    }

    List<Map<String, dynamic>> ensureListDefaults(List? raw) {
      final list = raw ?? const [];
      return list.map<Map<String, dynamic>>((r) {
        final m = (r is Map<String, dynamic>) ? r : Map<String, dynamic>.from(r as Map);
        return ensureEntryDefaults(m);
      }).toList();
    }

    _local = {
      'captureDebarque': ensureListDefaults(initial['captureDebarque'] as List?),
      'captureABord': ensureListDefaults(initial['captureABord'] as List?),
      'captureInterdite': ensureListDefaults(initial['captureInterdite'] as List?),
    };

    if (mounted) setState(() => _loadingRefs = false);
  }

  // =========================
  // Helpers labels
  // =========================
  String? _labelIn(List<dynamic> list, String? id,
      String Function(dynamic) lab, dynamic Function(dynamic) idOf) {
    if (id == null) return null;
    final m = list.where((e) => idOf(e).toString() == id).toList();
    return m.isEmpty ? null : lab(m.first);
  }

  String? _labelEspece(String? id) => _labelIn(
    _stepCtrl.especes, id,
        (e) => (e.libelle ?? e.name ?? '').toString(),
        (e) => e.id,
  );

  String? _labelPresentation(String? id) => _labelIn(
    _stepCtrl.presentations, id,
        (e) => (e.libelle ?? '').toString(),
        (e) => e.id,
  );

  String? _labelConservation(String? id) => _labelIn(
    _stepCtrl.conservations, id,
        (e) => (e.libelle ?? '').toString(),
        (e) => e.id,
  );

  String _labelsZones(List<String> ids) {
    final map = {
      for (final z in _stepCtrl.zonesCapture)
        z.id.toString(): (z.libelle ?? '').toString(),
    };
    return ids.map((id) => map[id] ?? id).join(', ');
  }

  // =========================
  // CRUD lignes
  // =========================
  Future<void> _addOrEditEntry({
    required String categoryKey,
    Map<String, dynamic>? editEntry,
  }) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      useRootNavigator: true, // IMPORTANT
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EntryFormSheet(
        title: categoryKey == 'captureDebarque'
            ? 'Capture débarquée'
            : categoryKey == 'captureABord'
            ? 'Capture à bord'
            : 'Capture interdite',
        stepCtrl: _stepCtrl,
        initial: editEntry,
      ),
    );

    if (result == null) return;

    setState(() {
      if (editEntry == null) {
        _local[categoryKey]!.add(result);
      } else {
        final idx = _local[categoryKey]!.indexWhere(
              (e) => e['uuid'] != null && e['uuid'] == editEntry['uuid'],
        );
        if (idx >= 0) _local[categoryKey]![idx] = result;
      }
    });
  }

  void _deleteEntry(String categoryKey, Map<String, dynamic> entry) {
    setState(() {
      _local[categoryKey]!.removeWhere(
            (e) => e['uuid'] != null && e['uuid'].toString() == entry['uuid'].toString(),
      );
    });
  }

  Future<void> _saveSection() async {
    final total = _local.values.fold<int>(0, (s, l) => s + l.length);
    if (total == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajoutez au moins une capture.')),
      );
      return;
    }
    await context.read<InspectionWizardCtrl>().saveSection('e', _local);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Section E sauvegardée.')),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loadingRefs) return const Center(child: CircularProgressIndicator());

    return Form(
      key: _key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Section E — Captures",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: _orangeColor,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Capture débarquée'),
                onPressed: () => _addOrEditEntry(categoryKey: 'captureDebarque'),
              ),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.add),
                label: const Text('Capture à bord'),
                onPressed: () => _addOrEditEntry(categoryKey: 'captureABord'),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Capture interdite'),
                onPressed: () => _addOrEditEntry(categoryKey: 'captureInterdite'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _CategoryBlock(
            title: "Captures débarquées",
            color: Colors.green.shade600,
            items: _local['captureDebarque']!,
            buildZones: _labelsZones,
            labelEspece: _labelEspece,
            labelPresentation: _labelPresentation,
            labelConservation: _labelConservation,
            onEdit: (e) => _addOrEditEntry(categoryKey: 'captureDebarque', editEntry: e),
            onDelete: (e) => _deleteEntry('captureDebarque', e),
          ),
          const SizedBox(height: 16),

          _CategoryBlock(
            title: "Captures à bord",
            color: Colors.blueGrey,
            items: _local['captureABord']!,
            buildZones: _labelsZones,
            labelEspece: _labelEspece,
            labelPresentation: _labelPresentation,
            labelConservation: _labelConservation,
            onEdit: (e) => _addOrEditEntry(categoryKey: 'captureABord', editEntry: e),
            onDelete: (e) => _deleteEntry('captureABord', e),
          ),
          const SizedBox(height: 16),

          _CategoryBlock(
            title: "Captures interdites",
            color: Colors.red.shade600,
            items: _local['captureInterdite']!,
            buildZones: _labelsZones,
            labelEspece: _labelEspece,
            labelPresentation: _labelPresentation,
            labelConservation: _labelConservation,
            onEdit: (e) => _addOrEditEntry(categoryKey: 'captureInterdite', editEntry: e),
            onDelete: (e) => _deleteEntry('captureInterdite', e),
          ),

          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Sauvegarder cette section'),
              onPressed: _saveSection,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// Listing catégorie (nouvelle présentation de carte)
// =========================
class _CategoryBlock extends StatelessWidget {
  const _CategoryBlock({
    required this.title,
    required this.color,
    required this.items,
    required this.buildZones,
    required this.labelEspece,
    required this.labelPresentation,
    required this.labelConservation,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final Color color;
  final List<Map<String, dynamic>> items;
  final String Function(List<String>) buildZones;
  final String? Function(String?) labelEspece;
  final String? Function(String?) labelPresentation;
  final String? Function(String?) labelConservation;
  final void Function(Map<String, dynamic>) onEdit;
  final void Function(Map<String, dynamic>) onDelete;

  double _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '.')) ?? 0;
  }

  void _openGallery(BuildContext context, List<String> paths, int index) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => _ImageGalleryScreen(paths: paths, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalKg = items.fold<double>(
      0,
          (s, e) =>
      s + _num(e['quantiteObservee']) + _num(e['quantiteDeclaree']) + _num(e['quantiteRetenue']),
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withOpacity(.25)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 10, height: 10,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(child: Text(title,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color))),
              Text("${totalKg.toStringAsFixed(2)} Kg",
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 8),

          if (items.isEmpty)
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Aucune ligne.", style: TextStyle(color: Colors.black54)),
            ),

          ...items.map((e) {
            final zones = (e['zoneIds'] as List?)?.map((x) => x.toString()).toList() ?? <String>[];
            final List<String> imgs =
            (e['imagePaths'] is List) ? (e['imagePaths'] as List).map((x) => x.toString()).toList() : [];

            final especeLabel = labelEspece(e['especeId']?.toString()) ?? '(Espèce inconnue)';
            final presLabel = labelPresentation(e['presentationId']?.toString()) ?? '-';
            final consLabel = labelConservation(e['conservationId']?.toString()) ?? '-';

            final qObs = (e['quantiteObservee'] ?? '-').toString();
            final qDec = (e['quantiteDeclaree'] ?? '-').toString();
            final qRet = (e['quantiteRetenue'] ?? '-').toString();
            final obs = (e['observations'] ?? '').toString();

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ligne titre + menu
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            runSpacing: 8,
                            spacing: 8,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Espèce mise en avant
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(.08),
                                  border: Border.all(color: Colors.orange.withOpacity(.25)),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.add_chart_outlined, size: 16), // nécessite Flutter 3.16+, sinon Icons.set_meal
                                    const SizedBox(width: 6),
                                    Text(
                                      especeLabel,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Présentation
                              Chip(
                                label: Text('Prés: $presLabel'),
                                visualDensity: VisualDensity.compact,
                              ),
                              // Conservation
                              Chip(
                                label: Text('Cons: $consLabel'),
                                visualDensity: VisualDensity.compact,
                              ),
                            ],
                          ),
                        ),
                        PopupMenuButton<String>(
                          onSelected: (v) {
                            if (v == 'edit') onEdit(e);
                            if (v == 'del') onDelete(e);
                          },
                          itemBuilder: (ctx) => const [
                            PopupMenuItem(value: 'edit', child: Text('Modifier')),
                            PopupMenuItem(value: 'del', child: Text('Supprimer')),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Quantités (bandeau)
                    Row(
                      children: [
                        _QtyBadge(label: 'Observée', value: qObs),
                        const SizedBox(width: 8),
                        _QtyBadge(label: 'Déclarée', value: qDec),
                        const SizedBox(width: 8),
                        _QtyBadge(label: 'Retenue', value: qRet),
                      ],
                    ),

                    // Zones
                    if (zones.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: -6,
                        children: zones
                            .map((id) => Chip(
                          label: Text(buildZones([id])),
                          visualDensity: VisualDensity.compact,
                        ))
                            .toList(),
                      ),
                    ],

                    // Observations
                    if (obs.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text("Observations : $obs"),
                    ],

                    // Images : mini-galerie horizontale
                    if (imgs.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: imgs.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (ctx, i) {
                            final p = imgs[i];
                            final f = File(p);
                            if (!f.existsSync()) return const SizedBox.shrink();
                            return GestureDetector(
                              onTap: () => _openGallery(context, imgs, i),
                              child: Hero(
                                tag: 'img-$p',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(f, width: 72, height: 72, fit: BoxFit.cover),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _QtyBadge extends StatelessWidget {
  const _QtyBadge({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          Text("$value Kg"),
        ],
      ),
    );
  }
}

// =========================
// Bottom sheet d’édition d’une ligne
// =========================
class _EntryFormSheet extends StatefulWidget {
  const _EntryFormSheet({
    required this.title,
    required this.stepCtrl,
    this.initial,
  });

  final String title;
  final MyStepEController stepCtrl;
  final Map<String, dynamic>? initial;

  @override
  State<_EntryFormSheet> createState() => _EntryFormSheetState();
}

class _EntryFormSheetState extends State<_EntryFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  String? _especeId;
  List<String> _zoneIds = [];
  String? _presentationId;
  String? _conservationId;

  String? _qObs;
  String? _qDec;
  String? _qRet;
  String? _observations;
  List<String> _imagePaths = []; // multi-images

  @override
  void initState() {
    super.initState();
    final i = widget.initial;
    if (i != null) {
      _especeId = i['especeId']?.toString();
      _zoneIds = (i['zoneIds'] as List?)?.map((x) => x.toString()).toList() ?? [];
      _presentationId = i['presentationId']?.toString();
      _conservationId = i['conservationId']?.toString();
      _qObs = i['quantiteObservee']?.toString();
      _qDec = i['quantiteDeclaree']?.toString();
      _qRet = i['quantiteRetenue']?.toString();
      _observations = i['observations']?.toString();

      final p = i['imagePaths'];
      if (p is List) {
        _imagePaths = p.map((x) => x?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      } else {
        final legacy = (i['imagePath'] ?? '').toString();
        _imagePaths = legacy.isEmpty ? [] : [legacy];
      }
    }
  }

  Future<void> _pickFromCamera() async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (x != null && _imagePaths.length < 3) {
      setState(() => _imagePaths = [..._imagePaths, x.path]);
    }
  }

  Future<void> _pickFromGallery() async {
    final xs = await _picker.pickMultiImage(imageQuality: 75);
    if (xs.isNotEmpty) {
      final rest = 3 - _imagePaths.length;
      final toAdd = xs.take(rest).map((f) => f.path);
      setState(() => _imagePaths = [..._imagePaths, ...toAdd]);
    }
  }

  Future<_PickResult<String>?> _openSinglePicker({
    required String title,
    required List<dynamic> items,
    required String? initialId,
    required String Function(dynamic) labelOf,
    required dynamic Function(dynamic) idOf,
  }) {
    return showModalBottomSheet<_PickResult<String>>(
      context: context,
      useRootNavigator: true, // IMPORTANT
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SimplePickerSheet<dynamic, String>(
        title: title,
        items: items,
        initialId: initialId,
        idOf: (e) => idOf(e).toString(),
        labelOf: (e) => labelOf(e),
      ),
    );
  }

  Future<List<String>?> _openMultiZonesPicker() async {
    final res = await showModalBottomSheet<List<String>>(
      context: context,
      useRootNavigator: true, // IMPORTANT
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _MultiPickerSheet<dynamic>(
        title: "Sélectionner des zones de capture",
        items: widget.stepCtrl.zonesCapture,
        initialIds: _zoneIds,
        idOf: (e) => e.id.toString(),
        labelOf: (e) => (e.libelle ?? '').toString(),
      ),
    );
    return res;
  }

  void _openGallery(BuildContext context, List<String> paths, int index) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => _ImageGalleryScreen(paths: paths, initialIndex: index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    String? labelEspece(String? id) {
      if (id == null) return null;
      final m = widget.stepCtrl.especes.where((e) => e.id.toString() == id).toList();
      return m.isEmpty ? null : (m.first.libelle ?? '').toString();
    }

    String zonesText(List<String> ids) {
      final map = {
        for (final z in widget.stepCtrl.zonesCapture)
          z.id.toString(): (z.libelle ?? '').toString(),
      };
      return ids.map((id) => map[id] ?? id).join(', ');
    }

    String? labelPres(String? id) {
      if (id == null) return null;
      final m = widget.stepCtrl.presentations.where((e) => e.id.toString() == id).toList();
      return m.isEmpty ? null : (m.first.libelle ?? '').toString();
    }

    String? labelCons(String? id) {
      if (id == null) return null;
      final m = widget.stepCtrl.conservations.where((e) => e.id.toString() == id).toList();
      return m.isEmpty ? null : (m.first.libelle ?? '').toString();
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.35,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        builder: (ctx, scroll) {
          return ListView(
            controller: scroll,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 12),
              Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Espèces
                    _BottomSheetSelector(
                      labelText: "Espèces",
                      valueLabel: labelEspece(_especeId),
                      enabled: widget.stepCtrl.especes.isNotEmpty,
                      errorText: (_especeId == null) ? 'Requis' : null,
                      onTap: () async {
                        final p = await _openSinglePicker(
                          title: "Sélectionner une espèce",
                          items: widget.stepCtrl.especes,
                          initialId: _especeId,
                          idOf: (e) => e.id,
                          labelOf: (e) => (e.libelle ?? e.name ?? '').toString(),
                        );
                        if (p != null) setState(() => _especeId = p.id);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Zones (multi)
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: widget.stepCtrl.zonesCapture.isEmpty ? null : () async {
                        final picked = await _openMultiZonesPicker();
                        if (picked != null) setState(() => _zoneIds = picked);
                      },
                      child: InputDecorator(
                        isEmpty: _zoneIds.isEmpty,
                        decoration: const InputDecoration(
                          labelText: "Zones de captures",
                          suffixIcon: Icon(Icons.search),
                        ),
                        child: _zoneIds.isEmpty
                            ? Text('Sélectionner…', style: TextStyle(color: Theme.of(context).hintColor))
                            : Wrap(
                          spacing: 6,
                          runSpacing: -6,
                          children: _zoneIds
                              .map((id) => Chip(
                            label: Text(zonesText([id])),
                            visualDensity: VisualDensity.compact,
                          ))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Présentation
                    _BottomSheetSelector(
                      labelText: "Présentation du produit",
                      valueLabel: labelPres(_presentationId),
                      enabled: widget.stepCtrl.presentations.isNotEmpty,
                      errorText: (_presentationId == null) ? 'Requis' : null,
                      onTap: () async {
                        final p = await _openSinglePicker(
                          title: "Sélectionner une présentation",
                          items: widget.stepCtrl.presentations,
                          initialId: _presentationId,
                          idOf: (e) => e.id,
                          labelOf: (e) => (e.libelle ?? '').toString(),
                        );
                        if (p != null) setState(() => _presentationId = p.id);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Conservation
                    _BottomSheetSelector(
                      labelText: "Conservation du produit",
                      valueLabel: labelCons(_conservationId),
                      enabled: widget.stepCtrl.conservations.isNotEmpty,
                      errorText: (_conservationId == null) ? 'Requis' : null,
                      onTap: () async {
                        final p = await _openSinglePicker(
                          title: "Sélectionner une conservation",
                          items: widget.stepCtrl.conservations,
                          initialId: _conservationId,
                          idOf: (e) => e.id,
                          labelOf: (e) => (e.libelle ?? '').toString(),
                        );
                        if (p != null) setState(() => _conservationId = p.id);
                      },
                    ),
                    const SizedBox(height: 12),

                    // Quantités
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: _qObs ?? '',
                            decoration: const InputDecoration(
                                labelText: "Quantité observée", suffixText: "Kg"),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => _qObs = v,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            initialValue: _qDec ?? '',
                            decoration: const InputDecoration(
                                labelText: "Quantité déclarée", suffixText: "Kg"),
                            keyboardType: TextInputType.number,
                            onChanged: (v) => _qDec = v,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _qRet ?? '',
                      decoration: const InputDecoration(
                          labelText: "Quantité retenue à bord", suffixText: "Kg"),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _qRet = v,
                    ),

                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: _observations ?? '',
                      decoration: const InputDecoration(labelText: "Observations"),
                      maxLines: 3,
                      onChanged: (v) => _observations = v,
                    ),

                    const SizedBox(height: 16),

                    // Sélection multi-images + grille
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: _imagePaths.length >= 3 ? null : _pickFromCamera,
                          icon: const Icon(Icons.photo_camera),
                          label: const Text('Prendre photo'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          onPressed: _imagePaths.length >= 3 ? null : _pickFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Galerie'),
                        ),
                        const Spacer(),
                        Text("${_imagePaths.length}/3"),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (_imagePaths.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _imagePaths.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1,
                        ),
                        itemBuilder: (ctx, i) {
                          final p = _imagePaths[i];
                          return GestureDetector(
                            onTap: () => _openGallery(context, _imagePaths, i),
                            onLongPress: () {
                              setState(() => _imagePaths.removeAt(i));
                            },
                            child: Hero(
                              tag: 'img-$p',
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(File(p), fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),

                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        icon: const Icon(Icons.check),
                        label: const Text('Valider'),
                        onPressed: () {
                          if (_especeId == null ||
                              _zoneIds.isEmpty ||
                              _presentationId == null ||
                              _conservationId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Complétez les champs requis.')),
                            );
                            return;
                          }

                          final uuid = widget.initial?['uuid'] ?? UniqueKey().toString();
                          final result = {
                            'uuid': uuid,
                            'especeId': _especeId,
                            'zoneIds': _zoneIds,
                            'presentationId': _presentationId,
                            'conservationId': _conservationId,
                            'quantiteObservee': _qObs,
                            'quantiteDeclaree': _qDec,
                            'quantiteRetenue': _qRet,
                            'observations': _observations,
                            'imagePaths': _imagePaths, // multi
                          };

                          Navigator.of(context, rootNavigator: true).pop(result); // IMPORTANT
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// =========================
// MultiPicker pour zones
// =========================
class _MultiPickerSheet<E> extends StatefulWidget {
  const _MultiPickerSheet({
    required this.title,
    required this.items,
    required this.idOf,
    required this.labelOf,
    required this.initialIds,
  });

  final String title;
  final List<E> items;
  final String Function(E e) idOf;
  final String Function(E e) labelOf;
  final List<String> initialIds;

  @override
  State<_MultiPickerSheet<E>> createState() => _MultiPickerSheetState<E>();
}

class _MultiPickerSheetState<E> extends State<_MultiPickerSheet<E>> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<E> _filtered;
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _filtered = List.of(widget.items);
    _selected = widget.initialIds.toSet();
    _searchCtrl.addListener(_applyFilter);
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.of(widget.items);
      } else {
        _filtered = widget.items.where((e) {
          final label = widget.labelOf(e).toLowerCase();
          final idStr = widget.idOf(e).toString().toLowerCase();
          return label.contains(q) || idStr.contains(q);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.30,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) {
          return Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(_selected.toList()),
                      child: const Text('Valider'),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Rechercher…",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: _filtered.length,
                  itemBuilder: (ctx, i) {
                    final e = _filtered[i];
                    final idStr = widget.idOf(e);
                    final label = widget.labelOf(e);
                    final selected = _selected.contains(idStr);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selected.add(idStr);
                          } else {
                            _selected.remove(idStr);
                          }
                        });
                      },
                      title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

// =========================
// Sélecteur simple (réutilisable)
// =========================
class _BottomSheetSelector extends StatelessWidget {
  final String labelText;
  final String? valueLabel;
  final bool enabled;
  final String? errorText;
  final VoidCallback? onTap;

  const _BottomSheetSelector({
    required this.labelText,
    required this.valueLabel,
    required this.enabled,
    this.errorText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = valueLabel == null || valueLabel!.isEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: enabled ? onTap : null,
      child: InputDecorator(
        isEmpty: isEmpty,
        decoration: InputDecoration(
          labelText: labelText,
          errorText: errorText,
          suffixIcon: const Icon(Icons.search),
          enabled: enabled,
        ),
        child: Text(
          valueLabel ?? 'Sélectionner…',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: isEmpty ? Theme.of(context).hintColor : null,
          ),
        ),
      ),
    );
  }
}

class _PickResult<T> {
  final T id;
  final String label;
  _PickResult({required this.id, required this.label});
}

class _SimplePickerSheet<E, T> extends StatefulWidget {
  const _SimplePickerSheet({
    required this.title,
    required this.items,
    required this.idOf,
    required this.labelOf,
    this.initialId,
  });

  final String title;
  final List<E> items;
  final T Function(E e) idOf;
  final String Function(E e) labelOf;
  final T? initialId;

  @override
  State<_SimplePickerSheet<E, T>> createState() => _SimplePickerSheetState<E, T>();
}

class _SimplePickerSheetState<E, T> extends State<_SimplePickerSheet<E, T>> {
  final TextEditingController _searchCtrl = TextEditingController();
  late List<E> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = List.of(widget.items);
    _searchCtrl.addListener(_applyFilter);
  }

  void _applyFilter() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.of(widget.items);
      } else {
        _filtered = widget.items.where((e) {
          final label = widget.labelOf(e).toLowerCase();
          final idStr = widget.idOf(e).toString().toLowerCase();
          return label.contains(q) || idStr.contains(q);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final initialIdStr = widget.initialId?.toString();

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.30,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _searchCtrl,
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: "Rechercher…",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),

              ..._filtered.map((e) {
                final idStr = widget.idOf(e).toString();
                final label = widget.labelOf(e);
                final selected = initialIdStr == idStr;

                return ListTile(
                  title: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: selected ? const Icon(Icons.check, color: Colors.green) : null,
                  onTap: () {
                    Navigator.of(context, rootNavigator: true).pop(
                      _PickResult<T>(id: widget.idOf(e), label: label),
                    ); // IMPORTANT
                  },
                );
              }).toList(),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}

// =========================
// Plein écran : galerie image (zoom + swipe)
// =========================
class _ImageGalleryScreen extends StatefulWidget {
  const _ImageGalleryScreen({
    required this.paths,
    this.initialIndex = 0,
  });

  final List<String> paths;
  final int initialIndex;

  @override
  State<_ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<_ImageGalleryScreen> {
  late final PageController _pageCtrl;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.paths.length - 1);
    _pageCtrl = PageController(initialPage: _index);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "${_index + 1} / ${widget.paths.length}",
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageCtrl,
        onPageChanged: (i) => setState(() => _index = i),
        itemCount: widget.paths.length,
        itemBuilder: (_, i) {
          final p = widget.paths[i];
          final f = File(p);
          return Center(
            child: Hero(
              tag: 'img-$p',
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: f.existsSync()
                    ? Image.file(f, fit: BoxFit.contain)
                    : const Icon(Icons.broken_image, color: Colors.white70, size: 64),
              ),
            ),
          );
        },
      ),
    );
  }
}
