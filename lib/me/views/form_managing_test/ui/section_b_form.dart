import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/my_tble_ref_sect_two.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/wizard_screen.dart';

import '../state/inspection_wizard_ctrl.dart';
import 'package:test_app_divkit/me/views/inspection/section_inspection_form/step_1/step_one_controller.dart';

class SectionBForm extends StatefulWidget {
  const SectionBForm({super.key});
  @override
  State<SectionBForm> createState() => _SectionBFormState();
}

class _SectionBFormState extends State<SectionBForm>
    with AutomaticKeepAliveClientMixin {
  final _key = GlobalKey<FormState>();
  late Map<String, dynamic> _local;

  final MyStepTwoController _stepCtrl = MyStepTwoController();
  bool _loadingRefs = true;

  Color get _orangeColor => const Color(0xFFFF6A00);
  final _dateFmt = DateFormat('yyyy-MM-dd');
  final _dateCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initRefs();
  }

  @override
  void dispose() {
    _dateCtrl.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  // =========================
  // Init listes + _local
  // =========================
  Future<void> _initRefs() async {
    await _stepCtrl.loadData();
    final initial =
        context.read<InspectionWizardCtrl>().section('b') ?? <String, dynamic>{};

    _local = {
      ...initial,

      // ↓↓↓ réfs en String + défaut = premier élément
      'societeConsignataire': initial['societeConsignataire'] ??
          (_stepCtrl.societesConsignation.isNotEmpty
              ? _stepCtrl.societesConsignation.first.id.toString()
              : null),

      'agentShipping': initial['agentShipping'] ??
          (_stepCtrl.agentsShipping.isNotEmpty
              ? _stepCtrl.agentsShipping.first.id.toString()
              : null),

      'nationaliteCapitaine': initial['nationaliteCapitaine'] ??
          (_stepCtrl.pays.isNotEmpty ? _stepCtrl.pays.first.id.toString() : null),

      'nationaliteProprietaire': initial['nationaliteProprietaire'] ??
          (_stepCtrl.pays.isNotEmpty ? _stepCtrl.pays.first.id.toString() : null),

      // text
      'nomCapitaine': initial['nomCapitaine'] ?? '',
      'passeportCapitaine': initial['passeportCapitaine'] ?? '',
      'nomProprietaire': initial['nomProprietaire'] ?? '',

      // date en String (yyyy-MM-dd)
      'dateExpirationPasseport':
      _normalizeDateStored(initial['dateExpirationPasseport']),
    };

    _syncDateFieldFromLocal();
    if (mounted) setState(() => _loadingRefs = false);
  }

  static String? _normalizeDateStored(dynamic raw) {
    if (raw == null) return null;
    if (raw is String && raw.isNotEmpty) {
      final parsed = DateTime.tryParse(raw);
      return parsed != null ? DateFormat('yyyy-MM-dd').format(parsed) : raw;
    }
    if (raw is DateTime) return DateFormat('yyyy-MM-dd').format(raw);
    return raw.toString();
  }

  void _syncDateFieldFromLocal() {
    _dateCtrl.text = (_local['dateExpirationPasseport'] as String?) ?? '';
  }

  // =========================
  // Helpers labels
  // =========================
  String? _labelForSociete(String? id) {
    if (id == null) return null;
    final m = _stepCtrl.societesConsignation
        .where((e) => e.id.toString() == id)
        .toList();
    return m.isEmpty ? null : (m.first.nom_societe ?? '').toString();
  }

  String? _labelForAgent(String? id) {
    if (id == null) return null;
    final m =
    _stepCtrl.agentsShipping.where((e) => e.id.toString() == id).toList();
    return m.isEmpty ? null : (m.first.nom ?? '').toString();
  }

  String? _labelForPays(String? id) {
    if (id == null) return null;
    final m = _stepCtrl.pays.where((e) => e.id.toString() == id).toList();
    return m.isEmpty ? null : (m.first.libelle ?? '').toString();
  }

  // =========================
  // Pickers
  // =========================
  Future<_PickResult<String>?> _openSocietePicker() {
    return showModalBottomSheet<_PickResult<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SimplePickerSheet<dynamic, String>(
        title: "Sélectionner une société de consignation",
        items: _stepCtrl.societesConsignation,
        initialId: _local['societeConsignataire'] as String?,
        idOf: (e) => e.id.toString(),
        labelOf: (e) => (e.nom_societe ?? '').toString(),
      ),
    );
  }

  Future<_PickResult<String>?> _openAgentPicker() {
    return showModalBottomSheet<_PickResult<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SimplePickerSheet<dynamic, String>(
        title: "Sélectionner un agent shipping",
        items: _stepCtrl.agentsShipping,
        initialId: _local['agentShipping'] as String?,
        idOf: (e) => e.id.toString(),
        labelOf: (e) => (e.nom ?? '').toString(),
      ),
    );
  }

  Future<_PickResult<String>?> _openPaysPicker({
    required String fieldKey,
  }) {
    return showModalBottomSheet<_PickResult<String>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => _SimplePickerSheet<dynamic, String>(
        title: "Sélectionner une nationalité",
        items: _stepCtrl.pays,
        initialId: _local[fieldKey] as String?,
        idOf: (e) => e.id.toString(),
        labelOf: (e) => (e.libelle ?? '').toString(),
      ),
    );
  }

  // =========================
  // Date picker
  // =========================
  DateTime _currentDateForPicker(String? s) {
    if (s == null || s.isEmpty) return DateTime.now();
    final parsed = DateTime.tryParse(s);
    return parsed ?? DateTime.now();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial =
    _currentDateForPicker(_local['dateExpirationPasseport'] as String?);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 30),
    );
    if (picked != null) {
      final s = _dateFmt.format(picked);
      setState(() {
        _local['dateExpirationPasseport'] = s;
        _dateCtrl.text = s;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_loadingRefs) return const Center(child: CircularProgressIndicator());

    return Form(
      key: _key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ======================
          // Société / Agent
          // ======================
          Text(
            "Consignation & Agent shipping",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: _orangeColor,
            ),
          ),
          const SizedBox(height: 12),

          // Société de consignation (BottomSheet)
          FormField<String>(
            initialValue: _local['societeConsignataire'] as String?,
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            builder: (state) {
              final selectedLabel =
              _labelForSociete(_local['societeConsignataire'] as String?);
              return _BottomSheetSelector(
                labelText: "Société de consignation",
                valueLabel: selectedLabel,
                enabled: _stepCtrl.societesConsignation.isNotEmpty,
                errorText: state.errorText,
                onTap: () async {
                  if (_stepCtrl.societesConsignation.isEmpty) return;
                  final picked = await _openSocietePicker();
                  if (picked != null) {
                    setState(() => _local['societeConsignataire'] = picked.id);
                    state.didChange(picked.id);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 12),

          // Agent shipping (BottomSheet)
          FormField<String>(
            initialValue: _local['agentShipping'] as String?,
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            builder: (state) {
              final selectedLabel =
              _labelForAgent(_local['agentShipping'] as String?);
              return _BottomSheetSelector(
                labelText: "Agent shipping du navire",
                valueLabel: selectedLabel,
                enabled: _stepCtrl.agentsShipping.isNotEmpty,
                errorText: state.errorText,
                onTap: () async {
                  if (_stepCtrl.agentsShipping.isEmpty) return;
                  final picked = await _openAgentPicker();
                  if (picked != null) {
                    setState(() => _local['agentShipping'] = picked.id);
                    state.didChange(picked.id);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 20),

          // ======================
          // Capitaine
          // ======================
          _SectionLabel(text: "Capitaine du navire"),
          const SizedBox(height: 8),

          TextFormField(
            initialValue: (_local['nomCapitaine'] ?? '').toString(),
            decoration: const InputDecoration(labelText: "Nom du capitaine"),
            textInputAction: TextInputAction.next,
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            onChanged: (v) => _local['nomCapitaine'] = v,
          ),
          const SizedBox(height: 12),

          TextFormField(
            initialValue: (_local['passeportCapitaine'] ?? '').toString(),
            decoration:
            const InputDecoration(labelText: "Passeport du capitaine"),
            textInputAction: TextInputAction.next,
            //validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            onChanged: (v) => _local['passeportCapitaine'] = v,
          ),
          const SizedBox(height: 12),

          // Nationalité (BottomSheet)
          FormField<String>(
            initialValue: _local['nationaliteCapitaine'] as String?,
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            builder: (state) {
              final selectedLabel =
              _labelForPays(_local['nationaliteCapitaine'] as String?);
              return _BottomSheetSelector(
                labelText: "Nationalité",
                valueLabel: selectedLabel,
                enabled: _stepCtrl.pays.isNotEmpty,
                errorText: state.errorText,
                onTap: () async {
                  if (_stepCtrl.pays.isEmpty) return;
                  final picked = await _openPaysPicker(fieldKey: 'nationaliteCapitaine');
                  if (picked != null) {
                    setState(() => _local['nationaliteCapitaine'] = picked.id);
                    state.didChange(picked.id);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 12),

          // Date d’expiration (readOnly + datePicker)
          TextFormField(
            controller: _dateCtrl,
            readOnly: true,
            decoration: InputDecoration(
              labelText: "Date d'expiration du passeport",
              suffixIcon: IconButton(
                onPressed: _pickDate,
                icon: const Icon(Icons.date_range),
                tooltip: 'Choisir une date',
              ),
            ),
            //validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            onTap: _pickDate,
          ),
          const SizedBox(height: 20),

          // ======================
          // Propriétaire
          // ======================
          _SectionLabel(text: "Propriétaire du navire"),
          const SizedBox(height: 8),

          TextFormField(
            initialValue: (_local['nomProprietaire'] ?? '').toString(),
            decoration: const InputDecoration(labelText: "Nom du propriétaire"),
            textInputAction: TextInputAction.next,
            //validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            onChanged: (v) => _local['nomProprietaire'] = v,
          ),
          const SizedBox(height: 12),

          // Nationalité propriétaire (BottomSheet)
          FormField<String>(
            initialValue: _local['nationaliteProprietaire'] as String?,
            //validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            builder: (state) {
              final selectedLabel =
              _labelForPays(_local['nationaliteProprietaire'] as String?);
              return _BottomSheetSelector(
                labelText: "Nationalité",
                valueLabel: selectedLabel,
                enabled: _stepCtrl.pays.isNotEmpty,
                errorText: state.errorText,
                onTap: () async {
                  if (_stepCtrl.pays.isEmpty) return;
                  final picked =
                  await _openPaysPicker(fieldKey: 'nationaliteProprietaire');
                  if (picked != null) {
                    setState(() => _local['nationaliteProprietaire'] = picked.id);
                    state.didChange(picked.id);
                  }
                },
              );
            },
          ),
          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              icon: const Icon(Icons.save),
              style: filledOrangeStyle(),
              label: const Text('Sauvegarder cette section'),
              onPressed: () async {
                if (!_key.currentState!.validate()) return;
                await context.read<InspectionWizardCtrl>().saveSection('b', _local);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.green.shade600, // 🔹 blue to differentiate Section B
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      content: Row(
                        children: const [
                          Icon(Icons.check_circle_outline,
                              color: Colors.white, size: 22),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Section B sauvegardée avec succès.',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),

        ],
      ),
    );
  }
}

// =========================
// Widgets utilitaires
// =========================

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(width: 8),
        const Expanded(child: Divider(thickness: 1)),
      ],
    );
  }
}

/// Affichage InputDecorator cliquable qui ouvre un bottom sheet
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

/// Résultat générique d’un picker
class _PickResult<T> {
  final T id;
  final String label;
  _PickResult({required this.id, required this.label});
}

/// Bottom sheet générique avec recherche
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
