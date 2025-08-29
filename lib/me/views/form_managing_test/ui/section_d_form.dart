import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/tbl_ref_formD.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/wizard_screen.dart';

import '../state/inspection_wizard_ctrl.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_1/step_one_controller.dart';

// ===============================
// Modèle local d'un engin
// ===============================
class DEnginItem {
  final String typeEnginId;
  final String typeEnginLabel;
  final String etatEnginId;
  final String etatEnginLabel;
  final String? observation;

  DEnginItem({
    required this.typeEnginId,
    required this.typeEnginLabel,
    required this.etatEnginId,
    required this.etatEnginLabel,
    this.observation,
  });

  DEnginItem copyWith({
    String? typeEnginId,
    String? typeEnginLabel,
    String? etatEnginId,
    String? etatEnginLabel,
    String? observation,
  }) {
    return DEnginItem(
      typeEnginId: typeEnginId ?? this.typeEnginId,
      typeEnginLabel: typeEnginLabel ?? this.typeEnginLabel,
      etatEnginId: etatEnginId ?? this.etatEnginId,
      etatEnginLabel: etatEnginLabel ?? this.etatEnginLabel,
      observation: observation ?? this.observation,
    );
  }

  Map<String, dynamic> toMap() => {
    'typeEnginId': typeEnginId,
    'typeEnginLabel': typeEnginLabel,
    'etatEnginId': etatEnginId,
    'etatEnginLabel': etatEnginLabel,
    'observation': observation,
  };

  factory DEnginItem.fromMap(Map<String, dynamic> m) => DEnginItem(
    typeEnginId: (m['typeEnginId'] ?? '').toString(),
    typeEnginLabel: (m['typeEnginLabel'] ?? '').toString(),
    etatEnginId: (m['etatEnginId'] ?? '').toString(),
    etatEnginLabel: (m['etatEnginLabel'] ?? '').toString(),
    observation: (m['observation'] as String?)?.toString(),
  );
}

// ===============================
// Section D (liste + ajout via BottomSheet)
// ===============================
class SectionDForm extends StatefulWidget {
  const SectionDForm({super.key});
  @override
  State<SectionDForm> createState() => _SectionDFormState();
}

class _SectionDFormState extends State<SectionDForm>
    with AutomaticKeepAliveClientMixin {
  final _saveKey = GlobalKey<FormState>();
  final MyStepFourController _stepCtrl = MyStepFourController();
  bool _loading = true;

  late List<DEnginItem> _engins;

  Color get _orange => const Color(0xFFFF6A00);

  @override
  void initState() {
    super.initState();
    _initLoad();
  }

  @override
  bool get wantKeepAlive => true;

  Future<void> _initLoad() async {
    // Doit remplir typesEngins et etatsEngins
    await _stepCtrl.loadData();

    final initial =
        context.read<InspectionWizardCtrl>().section('d') ?? <String, dynamic>{};

    final List raw = (initial['engins'] as List?) ?? <Map<String, dynamic>>[];
    _engins = raw.map((e) => DEnginItem.fromMap(Map<String, dynamic>.from(e))).toList();

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _openEnginSheet({DEnginItem? initial, int? index}) async {
    final result = await showModalBottomSheet<DEnginItem>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _EnginSheet(
        typesEngins: _stepCtrl.typesEngins,   // <- adapte si besoin
        etatsEngins: _stepCtrl.etatsEngins,   // <- adapte si besoin
        initial: initial,
      ),
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          _engins[index] = result;
        } else {
          _engins.add(result);
        }
      });
    }
  }

  Future<void> _saveAll() async {
    final payload = {
      'engins': _engins.map((e) => e.toMap()).toList(),
    };
    await context.read<InspectionWizardCtrl>().saveSection('d', payload);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Section D sauvegardée.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Form(
      key: _saveKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Engins de pêche",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _orange),
          ),
          const SizedBox(height: 8),

          if (_engins.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                "Aucun engin ajouté. Cliquez sur « Ajouter un engin ».",
                style: TextStyle(color: Theme.of(context).hintColor),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _engins.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final e = _engins[i];
                return Material(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    title: Text(
                      "${e.typeEnginLabel} • ${e.etatEnginLabel}",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: (e.observation == null || e.observation!.trim().isEmpty)
                        ? const Text("Observation : —")
                        : Text(
                      "Observation : ${e.observation}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _openEnginSheet(initial: e, index: i),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: "Supprimer",
                      onPressed: () => setState(() => _engins.removeAt(i)),
                    ),
                  ),
                );
              },
            ),

          const SizedBox(height: 16),

          // Actions anti-overflow: Wrap (meilleur sur petits écrans)
          Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              OutlinedButton.icon(
                onPressed: () => _openEnginSheet(),
                icon: const Icon(Icons.add),
                label: const Text("Ajouter un engin"),
              ),
              FilledButton.icon(
                //style: filledOrangeStyle(),
                onPressed: _engins.isEmpty ? null : _saveAll,
                icon: const Icon(Icons.save),
                label: const Text("Enregistrer"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ===============================
// BottomSheet : formulaire d'un engin
// ===============================
class _EnginSheet extends StatefulWidget {
  const _EnginSheet({
    required this.typesEngins,
    required this.etatsEngins,
    this.initial,
  });

  final List<dynamic> typesEngins; // items e.id, e.libelle
  final List<dynamic> etatsEngins; // items e.id, e.libelle
  final DEnginItem? initial;

  @override
  State<_EnginSheet> createState() => _EnginSheetState();
}

class _EnginSheetState extends State<_EnginSheet> {
  final _formKey = GlobalKey<FormState>();

  String? _typeId;
  String _typeLabel = '';
  String? _etatId;
  String _etatLabel = '';
  final _obsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.initial != null) {
      final d = widget.initial!;
      _typeId = d.typeEnginId;
      _typeLabel = d.typeEnginLabel;
      _etatId = d.etatEnginId;
      _etatLabel = d.etatEnginLabel;
      _obsCtrl.text = d.observation ?? '';
    } else {
      if (widget.typesEngins.isNotEmpty) {
        final e = widget.typesEngins.first;
        _typeId = e.id.toString();
        _typeLabel = (e.french_name ?? '').toString();
      }
      if (widget.etatsEngins.isNotEmpty) {
        final e = widget.etatsEngins.first;
        _etatId = e.id.toString();
        _etatLabel = (e.libelle ?? '').toString();
      }
    }
  }

  @override
  void dispose() {
    _obsCtrl.dispose();
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Requis' : null;

  Future<void> _openTypePicker() async {
    final res = await showModalBottomSheet<_PickResult<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SimplePickerSheet<dynamic, String>(
        title: "Sélectionner un type d’engin",
        items: widget.typesEngins,
        initialId: _typeId,
        idOf: (e) => e.id.toString(),
        labelOf: (e) => (e.french_name ?? '').toString(),
      ),
    );
    if (res != null) setState(() { _typeId = res.id; _typeLabel = res.label; });
  }

  Future<void> _openEtatPicker() async {
    final res = await showModalBottomSheet<_PickResult<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SimplePickerSheet<dynamic, String>(
        title: "Sélectionner l’état de l’engin",
        items: widget.etatsEngins,
        initialId: _etatId,
        idOf: (e) => e.id.toString(),
        labelOf: (e) => (e.libelle ?? '').toString(),
      ),
    );
    if (res != null) setState(() { _etatId = res.id; _etatLabel = res.label; });
  }

  void _submit() {
    if (_typeId == null || _etatId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez remplir les champs obligatoires.")),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    final item = DEnginItem(
      typeEnginId: _typeId!,
      typeEnginLabel: _typeLabel,
      etatEnginId: _etatId!,
      etatEnginLabel: _etatLabel,
      observation: _obsCtrl.text.trim().isEmpty ? null : _obsCtrl.text.trim(),
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: DraggableScrollableSheet(
        expand: false,
        minChildSize: 0.25,
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        builder: (ctx, controller) {
          return SingleChildScrollView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                    width: 40, height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.construction_outlined),
                      SizedBox(width: 8),
                      Text("Ajouter / Éditer un engin",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Type d'engin *
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _openTypePicker,
                    child: InputDecorator(
                      isEmpty: _typeLabel.isEmpty,
                      decoration: const InputDecoration(
                        labelText: "Type d'engin *",
                        suffixIcon: Icon(Icons.search),
                      ),
                      child: Text(
                        _typeLabel.isEmpty ? 'Sélectionner…' : _typeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _typeLabel.isEmpty
                              ? Theme.of(context).hintColor
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // État de l'engin *
                  InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _openEtatPicker,
                    child: InputDecorator(
                      isEmpty: _etatLabel.isEmpty,
                      decoration: const InputDecoration(
                        labelText: "État de l'engin *",
                        suffixIcon: Icon(Icons.search),
                      ),
                      child: Text(
                        _etatLabel.isEmpty ? 'Sélectionner…' : _etatLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _etatLabel.isEmpty
                              ? Theme.of(context).hintColor
                              : null,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Observation (option)
                  TextFormField(
                    controller: _obsCtrl,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: "Observation (option)",
                      hintText: "Veuillez ajouter une observation",
                      alignLabelWithHint: true,
                    ),
                    validator: (v) => null, // optionnel
                  ),

                  const SizedBox(height: 16),
                  // Actions (anti-overflow)
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.undo),
                        label: const Text("Fermer"),
                      ),
                      FilledButton.icon(
                        style: filledOrangeStyle(),
                        onPressed: _submit,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text("Enregistrer"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ===============================
// Sélecteur générique réutilisable
// ===============================
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
                    Navigator.of(context).pop(
                      _PickResult<T>(id: widget.idOf(e), label: label),
                    );
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
