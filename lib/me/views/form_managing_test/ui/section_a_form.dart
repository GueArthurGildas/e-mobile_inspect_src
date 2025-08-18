import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/inspection_wizard_ctrl.dart';

class SectionAForm extends StatefulWidget {
  const SectionAForm({super.key});
  @override
  State<SectionAForm> createState() => _SectionAFormState();
}

class _SectionAFormState extends State<SectionAForm> with AutomaticKeepAliveClientMixin {
  final _key = GlobalKey<FormState>();
  late Map<String, dynamic> _local;

  final _flags = const [
    {'id': 1, 'label': 'Côte d’Ivoire'},
    {'id': 2, 'label': 'Ghana'},
    {'id': 3, 'label': 'Sénégal'},
  ];

  @override
  void initState() {
    super.initState();
    final initial = context.read<InspectionWizardCtrl>().section('a');
    _local = {
      'shipName': initial['shipName'] ?? '',
      'flagId': initial['flagId'] ?? 1,
      'mesh': initial['mesh'] ?? 0,
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
            initialValue: _local['shipName'],
            decoration: const InputDecoration(labelText: 'Nom du navire'),
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
            onChanged: (v) => _local['shipName'] = v,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<int>(
            value: _local['flagId'],
            decoration: const InputDecoration(labelText: 'Pavillon'),
            items: _flags.map((o) => DropdownMenuItem(value: o['id'] as int, child: Text(o['label'] as String))).toList(),
            onChanged: (v) => setState(() => _local['flagId'] = v),
          ),
          const SizedBox(height: 12),
          TextFormField(
            initialValue: _local['mesh'].toString(),
            decoration: const InputDecoration(labelText: 'Maillage (mm)'),
            keyboardType: TextInputType.number,
            validator: (v) => (v == null || v.isEmpty) ? 'Requis' : (int.tryParse(v) == null ? 'Nombre invalide' : null),
            onChanged: (v) => _local['mesh'] = int.tryParse(v) ?? 0,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Sauvegarder cette section'),
              onPressed: () async {
                if (!_key.currentState!.validate()) return;
                await context.read<InspectionWizardCtrl>().saveSection('a', _local);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Section A sauvegardée.')),
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
