import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/inspection_wizard_ctrl.dart';

class SectionBForm extends StatefulWidget {
  const SectionBForm({super.key});
  @override
  State<SectionBForm> createState() => _SectionBFormState();
}

class _SectionBFormState extends State<SectionBForm> with AutomaticKeepAliveClientMixin {
  final _key = GlobalKey<FormState>();
  late Map<String, dynamic> _local;

  final _nations = const [
    {'id': 225, 'label': 'Côte d’Ivoire'},
    {'id': 233, 'label': 'Ghana'},
    {'id': 686, 'label': 'Sénégal'},
  ];

  @override
  void initState() {
    super.initState();
    final initial = context.read<InspectionWizardCtrl>().section('b');
    _local = {
      'captainName': initial['captainName'] ?? '',
      'passport': initial['passport'] ?? '',
      'nationalityId': initial['nationalityId'] ?? 225,
      'crewCount': initial['crewCount'] ?? 0,
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
          TextFormField(
            initialValue: _local['captainName'],
            decoration: const InputDecoration(labelText: 'Nom du capitaine'),
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            onChanged: (v) => _local['captainName'] = v,
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _local['passport'],
            decoration: const InputDecoration(labelText: 'Passeport'),
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            onChanged: (v) => _local['passport'] = v,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _local['nationalityId'],
            decoration: const InputDecoration(labelText: 'Nationalité'),
            items: _nations.map((o) => DropdownMenuItem(value: o['id'] as int, child: Text(o['label'] as String))).toList(),
            onChanged: (v) => setState(() => _local['nationalityId'] = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _local['crewCount'].toString(),
            decoration: const InputDecoration(labelText: 'Équipage (nombre)'),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : (int.tryParse(v) == null ? 'Nombre invalide' : null),
            onChanged: (v) => _local['crewCount'] = int.tryParse(v) ?? 0,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Sauvegarder cette section'),
              onPressed: () async {
                if (!_key.currentState!.validate()) return;
                await context.read<InspectionWizardCtrl>().saveSection('b', _local);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Section B sauvegardée.')),
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
