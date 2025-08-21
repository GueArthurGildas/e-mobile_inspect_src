import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/section_e_form.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/validation_screen.dart';
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

  Future<void> _goToStepWithSpinner(int newIndex) async {
    if (!mounted || newIndex == _current) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Chargement..."),
            ],
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop();
    if (!mounted) return;
    setState(() => _current = newIndex);
  }

  /// ✅ Flux d’animations pour le bouton "Soumettre"
  Future<void> _submitWizard(Map<String, dynamic> payload) async {
    if (!mounted) return;

    // 1. Spinner rapide
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Préparation..."),
            ],
          ),
        ),
      ),
    );
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    Navigator.of(context).pop();

    // 2. Confirmation
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment enregistrer votre inspection ?'),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Oui, enregistrer'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    // 3. Progression simulée
    int progress = 0;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future.doWhile(() async {
              await Future.delayed(const Duration(milliseconds: 200));
              if (progress >= 100) return false;
              progress += 10;
              if (mounted) setState(() {});
              return true;
            });
            return AlertDialog(
              title: const Text('Enregistrement en cours'),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                    maxWidth: MediaQuery.of(context).size.width * 0.8,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('$progress %'),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(value: progress / 100),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pop(); // ferme la progress

    // 4. Validation finale
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Succès'),
        content: const Text('Votre inspection a été enregistrée avec succès 🎉'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    // 👉 Redirection vers un écran de validation
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const ValidationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<InspectionWizardCtrl>();
    final loading = ctrl.inspectionId == null;

    final width = MediaQuery.of(context).size.width;
    final useHorizontal = width >= 560;

    return Scaffold(
      appBar: AppBar(
        title: Text('Wizard Inspection #${ctrl.inspectionId ?? '-'}'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Stepper(
        type: useHorizontal ? StepperType.horizontal : StepperType.vertical,
        currentStep: _current,
        onStepTapped: (i) {
          if (i <= _current) {
            _goToStepWithSpinner(i);
          }
        },
        onStepContinue: () {
          if (_current < 4) {
            _goToStepWithSpinner(_current + 1);
          }
        },
        onStepCancel: () {
          if (_current > 0) {
            _goToStepWithSpinner(_current - 1);
          }
        },
        controlsBuilder: (context, details) {
          final isRtl = Directionality.of(context) == TextDirection.rtl;
          return Row(
            children: [
              if (_current < 4)
                FilledButton.icon(
                  onPressed: details.onStepContinue,
                  label: const Text('Continuer'),
                  icon: Icon(isRtl ? Icons.arrow_back : Icons.arrow_forward),

                ),
              if (_current > 0) ...[
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: details.onStepCancel,
                  icon: Icon(isRtl ? Icons.arrow_forward : Icons.arrow_back),
                  label: const Text('Retour'),
                ),
              ],
            ],
          );
        },
        steps: [
          Step(
            title: const FittedBox(fit: BoxFit.scaleDown, child: Text('Section A')),
            isActive: _current >= 0,
            state: _current > 0 ? StepState.complete : StepState.indexed,
            content: SectionAForm(key: ValueKey('A_${ctrl.inspectionId}')),
          ),
          Step(
            title: const FittedBox(fit: BoxFit.scaleDown, child: Text('Section B')),
            isActive: _current >= 1,
            state: _current > 1 ? StepState.complete : StepState.indexed,
            content: SectionBForm(key: ValueKey('B_${ctrl.inspectionId}')),
          ),
          Step(
            title: const FittedBox(fit: BoxFit.scaleDown, child: Text('Section C')),
            isActive: _current >= 2,
            state: _current > 2 ? StepState.complete : StepState.indexed,
            content: SectionCForm(key: ValueKey('C_${ctrl.inspectionId}')),
          ),
          Step(
            title: const FittedBox(fit: BoxFit.scaleDown, child: Text('Section D')),
            isActive: _current >= 3,
            state: _current > 3 ? StepState.editing : StepState.indexed,
            content: SectionDForm(key: ValueKey('D_${ctrl.inspectionId}')),
          ),
          Step(
            title: const FittedBox(fit: BoxFit.scaleDown, child: Text('Section E')),
            isActive: _current >= 4,
            state: _current == 4 ? StepState.editing : StepState.indexed,
            content: SectionEForm(key: ValueKey('E_${ctrl.inspectionId}')),
          ),

        ],
      ),
      bottomNavigationBar: loading || _current != 4
          ? null
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: () async {
              final payload = ctrl.globalJson;
              await _submitWizard(payload);
            },
            icon: const Icon(Icons.cloud_upload),
            label: const Text('Soumettre le wizard'),
          ),
        ),
      ),
    );
  }
}
