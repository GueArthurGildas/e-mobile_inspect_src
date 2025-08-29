import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/section_e_form.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/validation_screen.dart';
import '../state/inspection_wizard_ctrl.dart';
import 'section_a_form.dart';
import 'section_b_form.dart';
import 'section_c_form.dart';
import 'section_d_form.dart';
import 'package:flutter/material.dart';


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

    final rootCtx = context;


    // 1. Spinner rapide
    final isConfirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Voulez-vous vraiment enregistrer votre inspection ?'),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        actions: [
          TextButton(
            style: _textBackStyle(),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: _filledOrangeStyle(),
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
            child: const Text('Oui, enregistrer'),
          ),
        ],
      ),
    );

// -- Mise à jour du statut *immédiatement après* confirmation
    if (isConfirmed != true) return; // l'utilisateur a annulé
    if (!mounted) return;

    try {
      final ctrl = context.read<InspectionWizardCtrl>();
      final id = ctrl.inspectionId;
      if (id != null) {
        await ctrl.updateInspectionStatus(id, 2); // ⚡ statut = 2
      }
    } catch (e) {
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Erreur'),
          content: Text('Mise à jour du statut impossible : $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    // await Future.delayed(const Duration(milliseconds: 600));
    // if (!mounted) return;
    // Navigator.of(context).pop();

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
            style: _textBackStyle(),
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: _filledOrangeStyle(),
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
        foregroundColor: Colors.white,
        flexibleSpace: Container( // dégradé discret AppBar
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_AppColors.orange, _AppColors.green],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: AnimatedContainer( // léger fond dégradé/animé
        duration: const Duration(milliseconds: 450),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF4EB), Color(0xFFEFFBF4)], // très léger orange -> vert pâle
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Theme( // teint le Stepper sans rien casser
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: _AppColors.orange,
              secondary: _AppColors.green,
              surface: _AppColors.surface,
            ),
          ),
          child: Stepper(
            type: useHorizontal ? StepperType.horizontal : StepperType.vertical,
            currentStep: _current,
            onStepTapped: (i) { if (i <= _current) _goToStepWithSpinner(i); },
            onStepContinue: () { if (_current < 4) _goToStepWithSpinner(_current + 1); },
            onStepCancel: () { if (_current > 0) _goToStepWithSpinner(_current - 1); },

            // ====> Boutons custom (styles + mini anim)
            controlsBuilder: (context, details) {
              final isRtl = Directionality.of(context) == TextDirection.rtl;
              return Row(
                children: [
                  if (_current < 4)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: .98, end: 1),
                      duration: const Duration(milliseconds: 180),
                      builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                      child: FilledButton.icon(
                        style: _filledOrangeStyle(),
                        onPressed: details.onStepContinue,
                        label: const Text('Continuer'),
                        icon: Icon(isRtl ? Icons.arrow_back : Icons.arrow_forward),
                      ),
                    ),
                  if (_current > 0) ...[
                    const SizedBox(width: 12),
                    TextButton.icon(
                      style: _textBackStyle(),
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
        ),
      ),

      // ====> Bouton de soumission gradient (orange -> vert)
      bottomNavigationBar: loading || _current != 4
          ? null
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _GradientButton(
            onPressed: () async {
              final payload = ctrl.globalJson;
              await _submitWizard(payload);
            },
            icon: const Icon(Icons.cloud_upload, color: Colors.white),
            label: const Text('Soumettre le wizard', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );

  }
}

// ---------- THEME HELPERS (palette + styles + bouton gradient) ----------
class _AppColors {
  static const orange = Color(0xFFFF6A00);
  static const orangeDark = Color(0xFFE25F00);
  static const green = Color(0xFF1BB35B);
  static const greenDark = Color(0xFF12924A);
  static const surface = Color(0xFFF9FAFB);
  static const onPrimary = Colors.white;
}

ButtonStyle _filledOrangeStyle() {
  return FilledButton.styleFrom(
    backgroundColor: _AppColors.orange,
    foregroundColor: _AppColors.onPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 3,
  ).copyWith(
    overlayColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) return _AppColors.orangeDark.withOpacity(.2);
      return null;
    }),
  );
}

ButtonStyle _textBackStyle() {
  return TextButton.styleFrom(
    foregroundColor: _AppColors.orange,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );
}

ButtonStyle _outlinedGreenStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: _AppColors.green,
    side: const BorderSide(color: _AppColors.green, width: 1.4),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
  );
}

/// Petit bouton avec dégradé (pour l’action "Soumettre")
class _GradientButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Widget label;
  final bool enabled;
  const _GradientButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.enabled = true,
  });

  @override
  State<_GradientButton> createState() => _GradientButtonState();
}

class _GradientButtonState extends State<_GradientButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      colors: [_AppColors.orange, _AppColors.green],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );

    final child = AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 120),
      child: InkWell(
        onTapDown: (_) => setState(() => _scale = .98),
        onTapCancel: () => setState(() => _scale = 1),
        onTapUp: (_) => setState(() => _scale = 1),
        onTap: widget.enabled ? widget.onPressed : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            gradient: widget.enabled ? gradient : LinearGradient(
              colors: [Colors.grey.shade400, Colors.grey.shade500],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 10, offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                widget.icon, const SizedBox(width: 10), widget.label,
              ],
            ),
          ),
        ),
      ),
    );

    return Material(color: Colors.transparent, child: child);
  }
}


// === Palette
class AppColors {
  static const orange = Color(0xFFFF6A00);
  static const orangeDark = Color(0xFFE25F00);
  static const onPrimary = Colors.white;
}

// === Style FilledButton orange (corrige le bouton blanc)
ButtonStyle filledOrangeStyle() {
  return FilledButton.styleFrom(
    backgroundColor: AppColors.orange,
    foregroundColor: AppColors.onPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    elevation: 2,
  ).copyWith(
    overlayColor: MaterialStateProperty.resolveWith((states) {
      if (states.contains(MaterialState.pressed)) {
        return AppColors.orangeDark.withOpacity(.16);
      }
      return null;
    }),
  );
}

// === Petit “toast/modal” en haut qui auto-disparaît
Future<void> showTopConfirm(BuildContext context, String message, {Duration? duration}) async {
  final overlay = Overlay.of(context);
  if (overlay == null) return;

  final entry = OverlayEntry(
    builder: (_) => _TopToast(message: message),
  );

  overlay.insert(entry);
  await Future.delayed(duration ?? const Duration(seconds: 2));
  entry.remove();
}

// === Widget interne du toast
class _TopToast extends StatefulWidget {
  final String message;
  const _TopToast({required this.message});

  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this, duration: const Duration(milliseconds: 280),
  )..forward();

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 8 + topInset,
      left: 12,
      right: 12,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero)
              .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic)),
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _c, curve: Curves.easeOut),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.orange, Color(0xFF1BB35B)], // orange -> vert léger
                  begin: Alignment.centerLeft, end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(.10),
                  blurRadius: 10, offset: const Offset(0, 6),
                )],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

