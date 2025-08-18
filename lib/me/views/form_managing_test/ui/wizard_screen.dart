import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/inspection_wizard_ctrl.dart';
import 'section_a_form.dart';
import 'section_b_form.dart';
import 'section_c_form.dart';
import 'section_d_form.dart';

class WizardScreen extends StatefulWidget {
  final int? inspectionId;
  const WizardScreen({super.key, this.inspectionId});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  int _current = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InspectionWizardCtrl>().loadOrCreate(id: widget.inspectionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<InspectionWizardCtrl>();
    final loading = ctrl.inspectionId == null;
    return Scaffold(
      appBar: AppBar(title: Text('Wizard Inspection #${ctrl.inspectionId ?? '-'}')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
              currentStep: _current,
              onStepContinue: () => setState(() => _current = (_current + 1).clamp(0, 3)),
              onStepCancel: () => setState(() => _current = (_current - 1).clamp(0, 3)),
              controlsBuilder: (context, details) {
                return Row(
                  children: [
                    FilledButton(onPressed: details.onStepContinue, child: const Text('Continuer')),
                    const SizedBox(width: 12),
                    TextButton(onPressed: details.onStepCancel, child: const Text('Retour')),
                  ],
                );
              },
              steps: [
                Step(title: const Text('Section A'), content: SectionAForm(key: ValueKey('A_${ctrl.inspectionId}'))),
                Step(title: const Text('Section B'), content: SectionBForm(key: ValueKey('B_${ctrl.inspectionId}'))),
                Step(title: const Text('Section C'), content: SectionCForm(key: ValueKey('C_${ctrl.inspectionId}'))),
                Step(title: const Text('Section D'), content: SectionDForm(key: ValueKey('D_${ctrl.inspectionId}'))),
              ],
            ),
      bottomNavigationBar: loading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: FilledButton.icon(
                  onPressed: () async {
                    final payload = ctrl.globalJson;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Soumis: ${payload.toString()}')),
                    );
                  },
                  icon: const Icon(Icons.cloud_upload),
                  label: const Text('Soumettre le wizard'),
                ),
              ),
            ),
    );
  }
}
