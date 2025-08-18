import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/inspection_wizard_ctrl.dart';

class SectionDForm extends StatefulWidget {
  const SectionDForm({super.key});
  @override
  State<SectionDForm> createState() => _SectionDFormState();
}

class _SectionDFormState extends State<SectionDForm> with AutomaticKeepAliveClientMixin {
  final _key = GlobalKey<FormState>();
  late Map<String, dynamic> _local;

  final _docTypes = const [
    {'id': 1, 'label': 'Permis de pêche'},
    {'id': 2, 'label': 'Assurance'},
    {'id': 3, 'label': 'Inspection précédente'},
  ];

  final _binary = const [
    {'id': 0, 'label': 'Non'},
    {'id': 1, 'label': 'Oui'},
  ];

  @override
  void initState() {
    super.initState();
    final initial = context.read<InspectionWizardCtrl>().section('d');
    _local = {
      'docTypeId': initial['docTypeId'] ?? 1,
      'docRef': initial['docRef'] ?? '',
      'hasVms': initial['hasVms'] ?? 0,
      'remarks': initial['remarks'] ?? '',
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
            value: _local['docTypeId'],
            decoration: const InputDecoration(labelText: 'Type de document'),
            items: _docTypes.map((o) => DropdownMenuItem(value: o['id'] as int, child: Text(o['label'] as String))).toList(),
            onChanged: (v) => setState(() => _local['docTypeId'] = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _local['docRef'],
            decoration: const InputDecoration(labelText: 'Référence doc.'),
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            onChanged: (v) => _local['docRef'] = v,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _local['hasVms'],
            decoration: const InputDecoration(labelText: 'Balise VMS'),
            items: _binary.map((o) => DropdownMenuItem(value: o['id'] as int, child: Text(o['label'] as String))).toList(),
            onChanged: (v) => setState(() => _local['hasVms'] = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _local['remarks'],
            decoration: const InputDecoration(labelText: 'Remarques'),
            maxLines: 3,
            onChanged: (v) => _local['remarks'] = v,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Sauvegarder cette section'),
              onPressed: () async {
                if (!_key.currentState!.validate()) return;
                await context.read<InspectionWizardCtrl>().saveSection('d', _local);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Section D sauvegardée.')),
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
