import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:test_app_divkit/me/controllers/user_controller.dart';
import 'package:test_app_divkit/me/models/user_model.dart';

import 'package:test_app_divkit/me/views/form_managing_test/ui/section_a_form.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/section_b_form.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/section_c_form.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/section_d_form.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/section_e_form.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/validation_screen.dart';

import '../state/inspection_wizard_ctrl.dart';

// =======================
//   WizardScreen
// =======================
class WizardScreen extends StatefulWidget {
  final int? inspectionId;
  const WizardScreen({super.key, this.inspectionId});

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  int _current = 0;

  // 👉 Sans Provider pour les users : on instancie le controller ici
  final _userCtrl = UserController();

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

  /// ✅ Soumission avec sélection des participants avant confirmation
  Future<void> _submitWizard(Map<String, dynamic> payload) async {
    if (!mounted) return;

    // 0) 👉 Modal de sélection des participants (affiche chips en temps réel)
    final picked = await showDialog<List<User>>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ParticipantsPickerDialog(
        userController: _userCtrl,
        title: 'Sélection des participants',
        subtitle: 'Choisissez les agents impliqués dans cette inspection.',
      ),
    );

    if (picked == null || picked.isEmpty) return;

// 0.1) Construire ids + meta
    final participantsIds  = picked.map((u) => u.id).whereType<int>().toList();
    final participantsMeta = picked.map((u) => {
      'id'   : u.id,
      'name' : u.name,
      'email': u.email,
    }).toList();

// 0.2) Persister dans la section 'e' pour que ça apparaisse dans le JSON généré
    final ctrl = context.read<InspectionWizardCtrl>();
    await ctrl.saveSection('e', {
      'participants'      : participantsIds,
      'participants_meta' : participantsMeta,
    });

// 0.3) (optionnel mais utile) : merger aussi dans le payload local si tu l’envoies juste après
    payload['e'] = {
      ...(payload['e'] ?? {}),
      'participants'      : participantsIds,
      'participants_meta' : participantsMeta,
    };

    // Annulation si rien choisi
    if (picked == null || picked.isEmpty) {
      // Option: await showTopConfirm(context, 'Aucun participant sélectionné');
      return;
    }

    // 👉 Injection dans le JSON final
    payload['participants'] = picked.map((u) => u.id).toList();
    payload['participants_meta'] = picked.map((u) {
      return {
        'id': u.id,
        'name': u.name,
        'email': u.email,
      };
    }).toList();



    // 1) Première confirmation avec récap visuel des participants
    final isConfirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Confirmation'),
        content: _ParticipantsSummary(names: picked.map((u) => u.name ?? 'User ${u.id ?? ''}').toList()),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
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

    if (isConfirmed != true) return;
    if (!mounted) return;

    // -- Mise à jour du statut après confirmation (inchangé)
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

    // 2) (Ta seconde confirmation existe dans ton code — je la conserve tel quel)
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

    // 3) Progression simulée (inchangé)
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

    // 4) Succès + navigation (inchangé)
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
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ValidationScreen()),
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
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [_AppColors.orange, _AppColors.green],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 450),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFFF4EB), Color(0xFFEFFBF4)],
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
          ),
        ),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Theme(
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
      bottomNavigationBar: loading || _current != 4
          ? null
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: _GradientButton(
            onPressed: () async {
              final ctrl = context.read<InspectionWizardCtrl>();
              final payload = ctrl.globalJson; // ← ton JSON global existant
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

// ---------- THEME HELPERS ----------
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

// ---------- Gradient Button ----------
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

// ========== Petit “toast/modal” auto-disparaît (inchangé) ==========
class AppColors {
  static const orange = Color(0xFFFF6A00);
  static const orangeDark = Color(0xFFE25F00);
  static const onPrimary = Colors.white;
}

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

Future<void> showTopConfirm(BuildContext context, String message, {Duration? duration}) async {
  final overlay = Overlay.of(context);
  if (overlay == null) return;
  final entry = OverlayEntry(builder: (_) => _TopToast(message: message));
  overlay.insert(entry);
  await Future.delayed(duration ?? const Duration(seconds: 2));
  entry.remove();
}

class _TopToast extends StatefulWidget {
  final String message;
  const _TopToast({required this.message});
  @override
  State<_TopToast> createState() => _TopToastState();
}

class _TopToastState extends State<_TopToast> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 280))..forward();
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Positioned(
      top: 8 + topInset, left: 12, right: 12,
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
                  colors: [AppColors.orange, Color(0xFF1BB35B)],
                  begin: Alignment.centerLeft, end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(.10), blurRadius: 10, offset: Offset(0, 6))],
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(child: Text(widget.message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =======================
//   Participants Picker
// =======================
class ParticipantsPickerDialog extends StatefulWidget {
  final UserController userController;
  final String title;
  final String? subtitle;

  const ParticipantsPickerDialog({
    super.key,
    required this.userController,
    required this.title,
    this.subtitle,
  });

  @override
  State<ParticipantsPickerDialog> createState() => _ParticipantsPickerDialogState();
}

class _ParticipantsPickerDialogState extends State<ParticipantsPickerDialog> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Set<int> _selectedIds = {};
  List<User> _all = [];
  List<User> _filtered = [];
  bool _loading = true;
  Timer? _deb;

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _deb?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);
    try {
      await widget.userController.loadLocalOnly();
      final users = widget.userController.users; // ← getter requis dans UserController
      _all = List<User>.from(users);
      _filtered = List<User>.from(_all);
    } catch (e) {
      debugPrint('ParticipantsPickerDialog.loadUsers error: $e');
      _all = [];
      _filtered = [];
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSearchChanged() {
    _deb?.cancel();
    _deb = Timer(const Duration(milliseconds: 180), () {
      final q = _searchCtrl.text.trim().toLowerCase();
      if (q.isEmpty) {
        setState(() => _filtered = List<User>.from(_all));
      } else {
        setState(() {
          _filtered = _all.where((u) {
            final name = (u.name ?? '').toLowerCase();
            final email = (u.email ?? '').toLowerCase();
            return name.contains(q) || email.contains(q);
          }).toList();
        });
      }
    });
  }

  List<User> get _selectedUsers =>
      _all.where((u) => u.id != null && _selectedIds.contains(u.id)).toList();

  void _toggleAll(bool value) {
    setState(() {
      if (value) {
        _selectedIds
          ..clear()
          ..addAll(_filtered.map((u) => u.id!).whereType<int>());
      } else {
        for (final u in _filtered) {
          if (u.id != null) _selectedIds.remove(u.id);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final header = _DialogHeader(title: widget.title, subtitle: widget.subtitle);

    final selectedPreview = _SelectedPreviewChips(
      users: _selectedUsers,
      onRemove: (id) => setState(() => _selectedIds.remove(id)),
    );

    final body = _loading
        ? const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(child: CircularProgressIndicator()),
    )
        : Column(
      children: [
        _SearchField(controller: _searchCtrl),
        const SizedBox(height: 10),
        Row(
          children: [
            Checkbox(
              value: _filtered.isNotEmpty &&
                  _filtered.every((u) => u.id != null && _selectedIds.contains(u.id)),
              onChanged: (v) => _toggleAll(v ?? false),
              side: const BorderSide(color: Color(0xFF1BB35B)),
              activeColor: const Color(0xFF1BB35B),
            ),
            const SizedBox(width: 6),
            const Text('Tout sélectionner'),
            const Spacer(),
            _SelectedBadge(count: _selectedIds.length),
          ],
        ),
        const SizedBox(height: 6),

        // 👉 Aperçu en temps réel des utilisateurs sélectionnés (chips)
        if (_selectedIds.isNotEmpty) selectedPreview,

        const SizedBox(height: 6),
        Expanded(
          child: _filtered.isEmpty
              ? const Center(child: Text('Aucun utilisateur trouvé'))
              : Scrollbar(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final u = _filtered[i];
                final id = u.id;
                final isChecked = id != null && _selectedIds.contains(id);
                return CheckboxListTile(
                  value: isChecked,
                  onChanged: (v) {
                    setState(() {
                      if (id != null) {
                        v == true ? _selectedIds.add(id) : _selectedIds.remove(id);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(
                    u.name ?? 'Utilisateur ${u.id ?? ''}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: (u.email != null && u.email!.isNotEmpty) ? Text(u.email!) : null,
                  secondary: const Icon(Icons.person),
                  activeColor: const Color(0xFF1BB35B),
                );
              },
            ),
          ),
        ),
      ],
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width > 560 ? 520 : 460,
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            const Divider(height: 1),
            Expanded(child: Padding(padding: const EdgeInsets.all(14), child: body)),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.close),
                      label: const Text('Annuler'),
                      onPressed: () => Navigator.of(context, rootNavigator: true).pop(null),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF6A00),
                        side: const BorderSide(color: Color(0xFFFF6A00)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.check),
                      label: const Text('Valider la sélection'),
                      onPressed: _selectedIds.isEmpty
                          ? null
                          : () {
                        final selected = _selectedUsers;
                        Navigator.of(context, rootNavigator: true).pop(selected);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1BB35B),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Sous-composants UI du picker ----------
class _DialogHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _DialogHeader({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6A00), Color(0xFF1BB35B)],
          begin: Alignment.centerLeft, end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.group_add, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Rechercher un utilisateur…',
        filled: true,
        fillColor: const Color(0xFFF4F6F8),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SelectedBadge extends StatelessWidget {
  final int count;
  const _SelectedBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1E6),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFFF6A00)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFFFF6A00)),
          const SizedBox(width: 6),
          Text(
            '$count sélectionné(s)',
            style: const TextStyle(color: Color(0xFFE25F00), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Liste de chips des personnes sélectionnées (live)
class _SelectedPreviewChips extends StatelessWidget {
  final List<User> users;
  final void Function(int id) onRemove;
  const _SelectedPreviewChips({required this.users, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFBFEFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDAEFE3)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: -6,
        children: users.map((u) {
          final id = u.id ?? -1;
          final name = (u.name == null || u.name!.isEmpty) ? 'Utilisateur $id' : u.name!;
          return Chip(
            label: Text(name),
            deleteIcon: const Icon(Icons.close),
            onDeleted: () => onRemove(id),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        }).toList(),
      ),
    );
  }
}

// =======================
//   Récap participants dans la confirmation
// =======================
class _ParticipantsSummary extends StatelessWidget {
  final List<String> names;
  const _ParticipantsSummary({required this.names});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirmez l’enregistrement de l’inspection avec les participants suivants :',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: -6,
              children: names.map((n) => Chip(label: Text(n))).toList(),
            ),
            const SizedBox(height: 12),
            const Text('Voulez-vous vraiment enregistrer votre inspection ?'),
          ],
        ),
      ),
    );
  }
}
