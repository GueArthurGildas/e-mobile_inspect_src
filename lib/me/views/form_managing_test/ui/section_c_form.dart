import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/inspection_wizard_ctrl.dart';

class SectionCForm extends StatefulWidget {
  const SectionCForm({super.key});
  @override
  State<SectionCForm> createState() => _SectionCFormState();
}

class _SectionCFormState extends State<SectionCForm> with AutomaticKeepAliveClientMixin {
  final _key = GlobalKey<FormState>();
  late Map<String, dynamic> _local;

  final _engineTypes = const [
    {'id': 1, 'label': 'Diesel'},
    {'id': 2, 'label': 'Essence'},
    {'id': 3, 'label': 'Hybride'},
  ];

  @override
  void initState() {
    super.initState();
    final initial = context.read<InspectionWizardCtrl>().section('c');
    _local = {
      'engineTypeId': initial['engineTypeId'] ?? 1,
      'length': initial['length'] ?? 0,
      'tonnageGt': initial['tonnageGt'] ?? 0,
    };
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Form(
      key: _key,
      child: Column(
        children: [
          DropdownButtonFormField<int>(
            value: _local['engineTypeId'],
            decoration: const InputDecoration(labelText: 'Type moteur'),
            items: _engineTypes.map((o) => DropdownMenuItem(value: o['id'] as int, child: Text(o['label'] as String))).toList(),
            onChanged: (v) => setState(() => _local['engineTypeId'] = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _local['length'].toString(),
            decoration: const InputDecoration(labelText: 'Longueur (m)'),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : (int.tryParse(v) == null ? 'Nombre invalide' : null),
            onChanged: (v) => _local['length'] = int.tryParse(v) ?? 0,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _local['tonnageGt'].toString(),
            decoration: const InputDecoration(labelText: 'Tonnage (GT)'),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : (int.tryParse(v) == null ? 'Nombre invalide' : null),
            onChanged: (v) => _local['tonnageGt'] = int.tryParse(v) ?? 0,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Sauvegarder cette section'),
              onPressed: () async {
                if (!_key.currentState!.validate()) return;
                await context.read<InspectionWizardCtrl>().saveSection('c', _local);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Section C sauvegardée.')),
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
