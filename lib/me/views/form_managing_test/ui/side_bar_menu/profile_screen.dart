import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/controllers/inspections_controller.dart';
import 'package:test_app_divkit/me/controllers/user_controller.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/side_bar_menu/theme_page_menu.dart';
import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/services/database_service.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/Inspection_api_sync.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/sync_service_inspection.dart';

import 'dart:convert';
import 'dart:async';

import 'package:test_app_divkit/me/views/form_managing_test/ui/inspection_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/services/database_service.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/Inspection_api_sync.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/sync_service_inspection.dart';

// ⬇️ adapte le chemin si ton SyncController est ailleurs
import 'package:test_app_divkit/me/controllers/sync_controller.dart';


import 'package:flutter/material.dart';

// ⬇️ adapte ces imports selon ton arborescence
import 'package:test_app_divkit/me/services/database_service.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/Inspection_api_sync.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/sync_service_inspection.dart';
import 'package:test_app_divkit/me/controllers/sync_controller.dart';
import 'package:test_app_divkit/me/controllers/inspection_controller.dart';




class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: "Profil",
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.person), title: Text("Nom complet")),
          Divider(),
          ListTile(leading: Icon(Icons.badge_outlined), title: Text("Matricule / Rôle")),
          Divider(),
          ListTile(leading: Icon(Icons.email_outlined), title: Text("Email")),
        ],
      ),
    );
  }
}

class MyInspectionsScreen extends StatelessWidget {
  const MyInspectionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: "Mes inspections",
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) => ListTile(
          leading: const Icon(Icons.assignment_outlined),
          title: Text("Inspection #${i + 1}"),
          subtitle: const Text("Navire • Statut • Date"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: ouvrir le détail si besoin
          },
        ),
      ),
    );
  }
}



///// synchro ici
class SyncCenterScreen extends StatefulWidget {
  const SyncCenterScreen({super.key});

  @override
  State<SyncCenterScreen> createState() => _SyncCenterScreenState();
}

class _SyncCenterScreenState extends State<SyncCenterScreen> {
  bool _busyInspection = false;
  bool _busyRefTables = false;
  bool _busyUsers = false;

  // ================================
  // INSPECTIONS : Laravel + Refresh
  // ================================
  Future<void> _syncInspections(BuildContext context) async {
    if (_busyInspection || _busyRefTables || _busyUsers) return;
    setState(() => _busyInspection = true);

    await _showProgressDialogWithStatus(
      context,
      title: 'Synchronisation des inspections',
      initialSubtitle: 'Préparation…',
      task: (status) async {
        String msg = '';
        Color color = Colors.green;

        try {
          // Étape 1/2 — synchro serveur
          status.value = 'Étape 1/2 — Synchronisation serveur (Laravel)…';
          final api = InspectionApi(baseUrl: 'https://www.mirah-csp.com/api/v1');
          final service = SyncService(
            getDb: () => DatabaseHelper.database,
            api: api,
            chunkSize: 100,
          );
          final r = await service.run();
          if (r.error != null) throw Exception(r.error);

          msg =
          'Serveur OK. À envoyer: ${r.totalPending} • Envoyés: ${r.totalSent} • MAJ: ${r.totalUpdated}';

          // Étape 2/2 — refresh local
          status.value = 'Étape 2/2 — Actualisation locale…';
          final inspectController = InspectionController();
          await inspectController.loadAndSync();

          final userController = UserController();
          await userController.loadAndSync();

          msg = 'Synchronisation terminée.\n$msg';
          color = Colors.green;
        } catch (e) {
          msg = 'Échec de la synchronisation : $e';
          color = Colors.orange;
          if (mounted) {
            await _showErrorDialog(
              context,
              title: 'Erreur',
              message:
              'Un problème est survenu pendant la synchro des inspections.\n\nDétail : $e',
            );
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: color),
        );
      },
    );

    if (mounted) setState(() => _busyInspection = false);
  }

  // ==========================================
  // TABLES DE RÉFÉRENCE : nécessite un code "ok123"
  // ==========================================
  Future<void> _syncRefTables(BuildContext context) async {
    if (_busyInspection || _busyRefTables || _busyUsers) return;

    // Demande un code avant de lancer
    final code = await _askForCode(context);
    if (code != "ok123") {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Code invalide, synchronisation annulée."),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() => _busyRefTables = true);

    await _showProgressDialogWithStatus(
      context,
      title: 'Mise à jour des tables de référence',
      initialSubtitle: 'Téléchargement et actualisation…',
      task: (status) async {
        String msg;
        Color color;

        try {
          status.value = 'Connexion au serveur…';
          final sync = SyncController.instance;
          await sync.syncAll();

          msg = 'Tables de référence synchronisées avec succès.';
          color = Colors.green;
        } catch (e) {
          msg = 'Échec de la synchro des tables de référence : $e';
          color = Colors.red;
          if (mounted) {
            await _showErrorDialog(
              context,
              title: 'Erreur',
              message:
              'Une erreur est survenue pendant la mise à jour des tables de référence.\n\nDétail : $e',
            );
          }
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), backgroundColor: color),
        );
      },
    );

    if (mounted) setState(() => _busyRefTables = false);
  }

  // ==========================
  // USERS : placeholder
  // ==========================
  Future<void> _syncUsers(BuildContext context) async {
    if (_busyInspection || _busyRefTables || _busyUsers) return;
    setState(() => _busyUsers = true);

    await _showProgressDialogWithStatus(
      context,
      title: 'Synchronisation des utilisateurs',
      initialSubtitle: 'En cours…',
      task: (status) async {
        status.value = 'Préparation…';
        await Future.delayed(const Duration(milliseconds: 500));
        status.value = 'Pas encore implémenté…';
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User synchro pas encore implémenté')),
        );
      },
    );

    if (mounted) setState(() => _busyUsers = false);
  }

  // ===== UI =====
  @override
  Widget build(BuildContext context) {
    final anyBusy = _busyInspection || _busyRefTables || _busyUsers;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Centre de synchronisation"),
        backgroundColor: Colors.orange, // rouge frappant
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildBigRedButton(
              icon: Icons.person,
              label: "User synchro",
              onPressed: anyBusy ? null : () => _syncUsers(context),
            ),
            const SizedBox(height: 20),
            _buildBigRedButton(
              icon: Icons.assignment,
              label: "Inspection synchro",
              onPressed: anyBusy ? null : () => _syncInspections(context),
            ),
            const SizedBox(height: 20),
            _buildBigRedButton(
              icon: Icons.table_chart,
              label: "Table ref synchro",
              onPressed: anyBusy ? null : () => _syncRefTables(context),
            ),
          ],
        ),
      ),
    );
  }

  // ======= Widgets / Helpers =======
  Widget _buildBigRedButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          textStyle:
          const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: Icon(icon, size: 28),
        label: Text(label),
        onPressed: onPressed,
      ),
    );
  }

  Future<String?> _askForCode(BuildContext context) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Code requis"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: "Entrez le code",
            hintText: "Ex: ok123",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.of(context).pop(controller.text.trim()),
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }

  Future<void> _showProgressDialogWithStatus(
      BuildContext context, {
        required String title,
        required String initialSubtitle,
        required Future<void> Function(ValueNotifier<String> status) task,
      }) async {
    final status = ValueNotifier<String>(initialSubtitle);
    final progress = ValueNotifier<double>(0.0);

    // Ouvre le dialog animé (rotation + pourcentage + textes qui défilent)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _FancyProgressDialog(
        title: title,
        status: status,
        progress: progress,
      ),
    );

    try {
      // Lance la tâche en laissant la barre fictive avancer toute seule
      await task(status);
    } finally {
      // Passe le pourcentage à 100% avant de fermer (effet "terminé")
      progress.value = 1.0;
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      status.dispose();
      progress.dispose();
    }
  }




  Future<void> _showErrorDialog(
      BuildContext context, {
        required String title,
        required String message,
      }) {
    return showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// ===== Widget du loader parlant =====
class _StatusProgressDialog extends StatelessWidget {
  final String title;
  final ValueNotifier<String> status;

  const _StatusProgressDialog({required this.title, required this.status});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.sync, color: Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            ValueListenableBuilder<String>(
              valueListenable: status,
              builder: (_, text, __) =>
                  Text(text, style: const TextStyle(fontSize: 14.5)),
            ),
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            const Text(
              'Ne fermez pas l’application pendant l’opération.',
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}


class _FancyProgressDialog extends StatefulWidget {
  final String title;
  final ValueNotifier<String> status;
  final ValueNotifier<double> progress;

  const _FancyProgressDialog({
    required this.title,
    required this.status,
    required this.progress,
  });

  @override
  State<_FancyProgressDialog> createState() => _FancyProgressDialogState();
}

class _FancyProgressDialogState extends State<_FancyProgressDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rot;
  late Timer _percentTimer;
  late Timer _hintTimer;

  // index du texte "qui défile"
  int _hintIndex = 0;
  List<String> _hints = const [
    'Préparation…',
    'Vérification de l’intégrité…',
    'Optimisation des paquets…',
    'Compression des charges…',
  ];

  @override
  void initState() {
    super.initState();

    // Rotation infinie de l’icône
    _rot = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat();

    // Avancement fictif (ne dépasse pas 0.98 tant que la tâche n’a pas fini)
    _percentTimer = Timer.periodic(const Duration(milliseconds: 120), (_) {
      final v = widget.progress.value;
      if (v < 0.98) {
        widget.progress.value = (v + 0.01).clamp(0.0, 0.98);
      }
    });

    // Changement de "hints" (textes qui défilent) toutes les 900ms
    _hintTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      setState(() {
        _hintIndex = (_hintIndex + 1) % _hints.length;
      });
    });

    // Adapte les hints selon l’étape (connexion / synchro locale, etc.)
    widget.status.addListener(() {
      final s = widget.status.value.toLowerCase();
      if (s.contains('serveur') || s.contains('connexion')) {
        setState(() {
          _hints = const [
            'Connexion au serveur…',
            'Négociation TLS…',
            'Vérification des jetons…',
            'Serveur joignable ✓',
          ];
          _hintIndex = 0;
        });
      } else if (s.contains('télécharg') ||
          s.contains('synchronisation') ||
          s.contains('actualisation') ||
          s.contains('locale')) {
        setState(() {
          _hints = const [
            'Synchronisation en cours…',
            'Écriture base locale…',
            'Indexation…',
            'Nettoyage des caches…',
          ];
          _hintIndex = 0;
        });
      } else {
        setState(() {
          _hints = const [
            'Préparation…',
            'Vérification de l’intégrité…',
            'Optimisation des paquets…',
            'Compression des charges…',
          ];
          _hintIndex = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _rot.dispose();
    _percentTimer.cancel();
    _hintTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre + icône tournante
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: RotationTransition(
                    turns: _rot,
                    child: const Icon(Icons.sync, color: Colors.red, size: 24),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Ligne de statut principale (mise à jour par status.value)
            ValueListenableBuilder<String>(
              valueListenable: widget.status,
              builder: (_, text, __) =>
                  Text(text, style: const TextStyle(fontSize: 14.5)),
            ),

            const SizedBox(height: 8),

            // Texte "qui défile" (hints) avec animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  FadeTransition(opacity: anim, child: child),
              child: Text(
                _hints[_hintIndex],
                key: ValueKey(_hintIndex),
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),

            const SizedBox(height: 16),

            // Barre de progression + pourcentage
            ValueListenableBuilder<double>(
              valueListenable: widget.progress,
              builder: (_, v, __) {
                final pct = (v * 100).clamp(0, 100).toInt();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(value: v == 0 ? null : v),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Veuillez patienter…',
                            style: TextStyle(fontSize: 12.5, color: Colors.black54)),
                        Text('$pct%',
                            style: const TextStyle(
                                fontSize: 12.5, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 8),
            const Text(
              'Ne fermez pas l’application pendant l’opération.',
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}


class PendingInspectionsScreen extends StatelessWidget {
  final List<dynamic> items;
  const PendingInspectionsScreen({super.key, required this.items});


  Future<void> _openInspectionDetail(BuildContext context, String idStr) async {
    final id = int.tryParse(idStr);
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ID d’inspection invalide")),
      );
      return;
    }

    // Capture un root context STABLE AVANT de fermer le modal
    final rootCtx = Navigator.of(context, rootNavigator: true).context;

    // 1) fermer le bottom-sheet (la liste des pending)
    Navigator.of(context).pop();

    // 2) pousser l’écran de détail depuis le root navigator
    await Navigator.of(rootCtx).push(
      MaterialPageRoute(
        builder: (_) => InspectionDetailScreen(inspectionId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Inspections en attente (${items.length})'),
      ),
      body: items.isEmpty
          ? const _EmptyState()
          : ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (ctx, i) {
          final m = _asMap(items[i]);

          // Fonction pour prendre un champ s’il existe
          String pick(List keys) {
            for (final k in keys) {
              final v = m[k];
              if (v != null && '$v'.trim().isNotEmpty) return '$v';
            }
            return '';
          }

          final idStr    = pick(['id','inspection_id']);
          final titre    = pick(['titre','titre_inspect','title']);
          final navire   = pick(['navire','navire_name','ship_name']);
          final datePrev = pick(['date_prevue_inspect','date','planned_at']);
          final statut   = pick(['statut','status','statut_inspection_id']);
          final port     = pick(['port','port_inspection','port_name']);

          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: CircleAvatar(
                backgroundColor: Colors.orange.withOpacity(.15),
                child: const Icon(Icons.assignment, color: Colors.orange),
              ),
              title: Text(
                titre.isNotEmpty ? titre : 'Inspection #$idStr',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (navire.isNotEmpty) Text('Navire : $navire'),
                  if (port.isNotEmpty) Text('Port : $port'),
                  if (datePrev.isNotEmpty) Text('Prévue : $datePrev'),
                  if (statut.isNotEmpty) Text('Statut : $statut'),
                ],
              ),
              //onTap: () => _openInspectionDetail(context, idStr),
              trailing: TextButton.icon(
                icon: const Icon(Icons.open_in_new),
                label: const Text("Ouvrir"),
                onPressed: () => _openInspectionDetail(context, idStr),
              ),


            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic> _asMap(dynamic x) {
    if (x is Map<String, dynamic>) return x;
    if (x is Map) return Map<String, dynamic>.from(x);
    try {
      return Map<String, dynamic>.from(jsonDecode(jsonEncode(x)));
    } catch (_) {
      return <String, dynamic>{};
    }
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.inbox_outlined, size: 48, color: Colors.black38),
            SizedBox(height: 12),
            Text("Aucune inspection en attente", style: TextStyle(fontSize: 16, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}




class GroupsTeamsScreen extends StatelessWidget {
  const GroupsTeamsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: "Groupes & équipes",
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.group_outlined), title: Text("Équipe Contrôles")),
          ListTile(leading: Icon(Icons.group_outlined), title: Text("Équipe Conformité")),
          ListTile(leading: Icon(Icons.group_outlined), title: Text("Équipe Statistiques")),
        ],
      ),
    );
  }
}

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: "Enregistrements",
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.bookmark_border), title: Text("Brouillons")),
          ListTile(leading: Icon(Icons.save_alt_outlined), title: Text("Exports générés")),
          ListTile(leading: Icon(Icons.history), title: Text("Historique d’actions")),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: "Paramètres",
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SwitchListTile(
            value: true,
            onChanged: null, // TODO: binder
            title: Text("Thème sombre"),
          ),
          ListTile(leading: Icon(Icons.notifications_outlined), title: Text("Notifications")),
          ListTile(leading: Icon(Icons.security_outlined), title: Text("Sécurité")),
        ],
      ),
    );
  }
}
