import 'dart:io';
import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/controllers/user_controller.dart';
import 'package:test_app_divkit/me/models/user_model.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/side_bar_menu/theme_page_menu.dart';

const kOrange = Color(0xFFFF6A00); // charte punchy
const kGreen  = Color(0xFF1E9E5A);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserController _controller = UserController();

  User? _user;
  bool _loading = true;
  String _loadingMessage = "Chargement…";
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    setState(() {
      _loading = true;
      _error = null;
      _loadingMessage = "Récupération du profil depuis la base locale…";
    });
    try {
      final u = await _controller.loadCurrentUser(); // adapte si besoin
      if (!mounted) return;
      setState(() => _user = u);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = "Impossible de charger le profil : $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
      _loadingMessage = "Actualisation du profil…";
    });

    try {
      final online = await _hasInternet();
      if (!online) throw const SocketException("No Internet");
      // Si tu as une route de sync user, appelle-la ici. Sinon on recharge juste le local.
      // await _controller.syncCurrentUser(); // optionnel si dispo
    } catch (_) {
      _error = "Hors ligne : affichage des données locales.";
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Pas de connexion internet"), backgroundColor: Colors.red),
        );
      }
    }

    // Recharge local quoi qu’il arrive
    final u = await _controller.loadCurrentUser();
    if (!mounted) return;
    setState(() {
      _user = u;
      _loading = false;
    });
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? _LoaderBlock(message: _loadingMessage, error: _error)
        : RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          if (_error != null)
            _ErrorBanner(message: _error!, onRetry: _refresh),

          // ─── Header profil
          _ProfileHeaderCard(user: _user),

          const SizedBox(height: 14),

          // ─── KPIs (anti-overflow via Wrap)
          _ProfileKpis(
            pending: _user?.nbInspectionsPending ?? 0,
            done: _user?.nbInspectionsDone ?? 0,
            id: _user?.id?.toString() ?? '—',
          ),

          const SizedBox(height: 14),

          // ─── Informations détaillées
          _InfoSection(user: _user),

          const SizedBox(height: 18),

          // ─── Actions rapides visibles et pro
          // _ActionsSection(
          //   onViewPending: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text("Voir mes inspections en attente")),
          //     );
          //   },
          //   onViewAll: () {
          //     ScaffoldMessenger.of(context).showSnackBar(
          //       const SnackBar(content: Text("Voir toutes mes inspections")),
          //     );
          //   },
          //   onOpenSyncCenter: () {
          //     Navigator.of(context).pushNamed('/sync-center'); // adapte ta route si besoin
          //   },
          //   onSettings: () {
          //     Navigator.of(context).pushNamed('/settings'); // adapte
          //   },
          // ),
        ],
      ),
    );

    return SectionScaffold(
      title: "Profil",
      //trailing: IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
      body: body,
    );

    // Si tu n'as pas SectionScaffold, remplace par :
    // return Scaffold(
    //   appBar: AppBar(title: const Text("Profil"), backgroundColor: kOrange, actions: [
    //     IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
    //   ]),
    //   body: body,
    // );
  }
}

/// ============ UI Widgets ============

class _LoaderBlock extends StatelessWidget {
  final String message;
  final String? error;
  const _LoaderBlock({required this.message, this.error});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 16)),
            if (error != null) ...[
              const SizedBox(height: 12),
              Text(error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.red))),
          TextButton(onPressed: onRetry, child: const Text("Réessayer")),
        ],
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  final User? user;
  const _ProfileHeaderCard({required this.user});

  String _initials(String? name) {
    final n = (name ?? "").trim();
    if (n.isEmpty) return "U";
    final parts = n.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final name = user?.name ?? "Utilisateur";
    final role = user?.primaryRoleName ?? "—";
    final email = user?.email ?? "—";
    final id = user?.id?.toString() ?? "—";
    //final team = (user?.teamName ?? "").trim();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 64, height: 64, alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [kOrange.withOpacity(.15), kGreen.withOpacity(.15)]),
              shape: BoxShape.circle,
            ),
            child: Text(
              _initials(name),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.black87),
            ),
          ),
          const SizedBox(width: 14),
          // Infos principales
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text(role, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54)),
              Text(email, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black87)),

            ]),
          ),
          const SizedBox(width: 8),
          // ID chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.black12),
            ),
            child: Text("#$id", style: const TextStyle(fontSize: 12.5, color: Colors.black87)),
          ),
        ],
      ),
    );
  }
}

class _ProfileKpis extends StatelessWidget {
  final int pending;
  final int done;
  final String id;
  const _ProfileKpis({required this.pending, required this.done, required this.id});

  @override
  Widget build(BuildContext context) {
    Widget chip(IconData icon, String label, String value, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(.12), color.withOpacity(.08)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(.30)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
        ]),
      );
    }

    return Wrap(
      spacing: 10, runSpacing: 10, // anti-overflow
      children: [
        chip(Icons.sd_card_alert, "En attente", "$pending", const Color(0xFFFFA000)),
        chip(Icons.verified_outlined, "Réalisées", "$done", kGreen),
        chip(Icons.badge_outlined, "Identifiant", "#$id", Colors.blueGrey),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final User? user;
  const _InfoSection({required this.user});

  @override
  Widget build(BuildContext context) {
    String val(String? s) => (s == null || s.trim().isEmpty) ? "—" : s.trim();

    Widget row(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(k, style: const TextStyle(color: Colors.black54))),
          const SizedBox(width: 8),
          Expanded(child: Text(v)),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Informations", style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        row("Nom", val(user?.name)),
        row("Email", val(user?.email)),
        row("Rôle", val(user?.primaryRoleName)),
        //if ((user?.teamName ?? "").trim().isNotEmpty) row("Équipe", user!.teamName!.trim()),
      ]),
    );
  }
}

class _ActionsSection extends StatelessWidget {
  final VoidCallback onViewPending;
  final VoidCallback onViewAll;
  final VoidCallback onOpenSyncCenter;
  final VoidCallback onSettings;

  const _ActionsSection({
    required this.onViewPending,
    required this.onViewAll,
    required this.onOpenSyncCenter,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    Widget pill(IconData icon, String label, VoidCallback onTap) {
      return Material(
        color: kOrange.withOpacity(.10),
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, color: kOrange, size: 18),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ]),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Actions", style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10, runSpacing: 10,
          children: [
            pill(Icons.visibility_outlined, "Voir en attente", onViewPending),
            pill(Icons.list_alt_outlined, "Mes inspections", onViewAll),
            pill(Icons.cloud_sync_outlined, "Centre de synchro", onOpenSyncCenter),
            pill(Icons.settings_outlined, "Paramètres", onSettings),
          ],
        ),
      ],
    );
  }
}
