import 'dart:io';
import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/controllers/user_controller.dart';
import 'package:test_app_divkit/me/models/user_model.dart';

const kOrange = Color(0xFFFFA726);
const kGreen  = Color(0xFF2ECC71);

class GroupsTeamsScreen extends StatefulWidget {
  const GroupsTeamsScreen({super.key});

  @override
  State<GroupsTeamsScreen> createState() => _GroupsTeamsScreenState();
}

class _GroupsTeamsScreenState extends State<GroupsTeamsScreen> {
  final UserController _controller = UserController();

  bool _loading = true;
  String _loadingMessage = "Chargement...";
  String? _error;

  String _query = "";

  @override
  void initState() {
    super.initState();
    _loadLocal();
  }

  // ====== Reprise de ta logique UsersScreen ======
  Future<void> _loadLocal() async {
    setState(() {
      _loading = true;
      _error = null;
      _loadingMessage = "Chargement des utilisateurs depuis la base locale...";
    });
    await _controller.loadLocalOnly();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
      _loadingMessage = "Mise à jour des données locales...";
    });

    try {
      final online = await _hasInternet();
      if (!online) throw const SocketException("No Internet");

      // 1) Sync API -> local
      await _controller.loadAndSync();
    } catch (e) {
      // 2) Message d’erreur visible
      _error = "Pas de connexion internet. Affichage des données locales.";
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pas de connexion internet"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // 3) Toujours recharger le local pour l’affichage
    await _controller.loadLocalOnly();

    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
  // ====== Fin reprise logique ======

  List<User> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _controller.users;
    return _controller.users.where((u) {
      final name = (u.name ?? "").toLowerCase();
      final email = (u.email ?? "").toLowerCase();
      final role = (u.primaryRoleName ?? "").toLowerCase();
      //final team = (u.teamName ?? "").toLowerCase();
      return name.contains(q) || email.contains(q) || role.contains(q) ;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? _LoaderBlock(message: _loadingMessage, error: _error)
        : Column(
      children: [
        if (_error != null)
          _ErrorBanner(message: _error!, onRetry: _refresh),

        // Barre de recherche
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: _SearchBar(
            value: _query,
            onChanged: (v) => setState(() => _query = v),
          ),
        ),

        // KPIs rapides (à partir des champs pending/done)
        _TopKpis(
          totalUsers: _controller.users.length,
          totalPending: _controller.users.fold<int>(0, (s, u) => s + (u.nbInspectionsPending ?? 0)),
          totalDone: _controller.users.fold<int>(0, (s, u) => s + (u.nbInspectionsDone ?? 0)),
        ),

        const SizedBox(height: 6),

        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final User user = _filtered[index];
                final role = user.primaryRoleName ?? '—';
                final done = user.nbInspectionsDone ?? 0;
                final pending = user.nbInspectionsPending ?? 0;
                final idText = "#${user.id ?? '—'}";

                return _UserCardTile(
                  name: user.name ?? "Utilisateur",
                  email: user.email ?? "—",
                  role: role,
                  done: done,
                  pending: pending,
                  idText: idText,
                  //team: user.teamName, // si dispo
                  onTap: () {
                    // TODO: ouvrir le détail utilisateur si tu veux
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Ouvrir le profil de ${user.name ?? ''}")),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groupes & équipes'),
        backgroundColor: kOrange,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: body,

      // Gros bouton flottant "Synchroniser" (beau + pro)
      floatingActionButton: _SyncFab(loading: _loading, onPressed: _refresh),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

/// ===================== UI Blocks =====================

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
      width: double.infinity,
      color: Colors.red.withOpacity(0.08),
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
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

class _SearchBar extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    // contrôleur jetable pour refléter _query sans conserver d'état ici
    final ctrl = TextEditingController(text: value)
      ..selection = TextSelection.collapsed(offset: value.length);

    return TextField(
      controller: ctrl,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "Rechercher un membre, un email, un rôle…",
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
    );
  }
}

class _TopKpis extends StatelessWidget {
  final int totalUsers;
  final int totalPending;
  final int totalDone;
  const _TopKpis({required this.totalUsers, required this.totalPending, required this.totalDone});

  @override
  Widget build(BuildContext context) {
    Widget chip({required IconData icon, required String label, required String value, required Color color}) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(.12), color.withOpacity(.08)]),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(.30)),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 34, height: 34, alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withOpacity(.18), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
          ]),
        ]),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 10, runSpacing: 10, // ⬅️ wrap auto (pas d’overflow en paysage)
        children: [
          chip(icon: Icons.people_alt_outlined, label: "Utilisateurs", value: "$totalUsers", color: kOrange),
          chip(icon: Icons.sd_card_alert, label: "En attente", value: "$totalPending", color: const Color(0xFFFFA000)),
          chip(icon: Icons.verified_outlined, label: "Réalisées", value: "$totalDone", color: kGreen),
        ],
      ),
    );
  }
}

class _UserCardTile extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final int done;
  final int pending;
  final String idText;
  final String? team;
  final VoidCallback onTap;

  const _UserCardTile({
    required this.name,
    required this.email,
    required this.role,
    required this.done,
    required this.pending,
    required this.idText,
    required this.onTap,
    this.team,
  });

  @override
  Widget build(BuildContext context) {
    Widget kpi(String label, String value, Color color, IconData icon) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [color.withOpacity(.12), color.withOpacity(.08)]),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withOpacity(.30)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
        ]),
      );
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black12),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3))],
          ),
          child: LayoutBuilder(builder: (ctx, c) {
            // En paysage, on laisse respirer via Wrap/ellipsis
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: kOrange.withOpacity(.12),
                  child: const Icon(Icons.person, color: kOrange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(idText, style: const TextStyle(fontSize: 12.5, color: Colors.black87)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("Email: $email",
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black87)),
                    Text("Rôle: $role",
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.black54)),
                    if (team != null && team!.trim().isNotEmpty)
                      Text("Équipe: ${team!}",
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.black54)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8, runSpacing: 8, // ⬅️ pas d’overflow
                      children: [
                        kpi("En attente", "$pending", const Color(0xFFFFA000), Icons.sd_card_alert),
                        kpi("Réalisées", "$done", kGreen, Icons.verified_outlined),
                      ],
                    ),
                  ]),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}


void _openUserProfile(BuildContext context, User user) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _UserProfileSheet(user: user),
  );
}

class _UserProfileSheet extends StatelessWidget {
  final User user;
  const _UserProfileSheet({required this.user});

  @override
  Widget build(BuildContext context) {
    final role = user.primaryRoleName ?? "—";
    final done = user.nbInspectionsDone ?? 0;
    final pending = user.nbInspectionsPending ?? 0;

    return SafeArea(
      top: false,
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (_, scrollCtrl) {
          return SingleChildScrollView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header gradient
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [kOrange.withOpacity(.15), kGreen.withOpacity(.15)]),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: kOrange.withOpacity(.15),
                        child: Text(
                          (user.name ?? "U").isNotEmpty ? (user.name ?? "U").trim()[0].toUpperCase() : "U",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: kOrange),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(user.name ?? "Utilisateur",
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text(role, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.black54)),
                          if ((user.email ?? "").isNotEmpty)
                            Text(user.email!, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.black87)),
                        ]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // KPIs du profil
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: [
                    _kpiBox("En attente", "$pending", const Color(0xFFFFA000), Icons.sd_card_alert),
                    _kpiBox("Réalisées", "$done", kGreen, Icons.verified_outlined),
                    _kpiBox("ID", "#${user.id ?? '—'}", Colors.blueGrey, Icons.badge_outlined),
                  ],
                ),

                const SizedBox(height: 14),

                // Actions
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: [
                    _pill(icon: Icons.visibility_outlined, label: "Voir en attente", onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Voir en attente (utilisateur)")),
                      );
                    }),
                    _pill(icon: Icons.cloud_sync_outlined, label: "Synchroniser", onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Synchroniser pour l’utilisateur")),
                      );
                    }),
                    if ((user.email ?? "").isNotEmpty)
                      _pill(icon: Icons.email_outlined, label: "Envoyer un email", onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Email: ${user.email}")),
                        );
                      }),
                  ],
                ),

                const SizedBox(height: 14),

                // Infos détaillées
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Informations", style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    _infoRow("Nom", user.name ?? "—"),
                    _infoRow("Email", user.email ?? "—"),
                    _infoRow("Rôle", role),
                    //if ((user.teamName ?? "").isNotEmpty) _infoRow("Équipe", user.teamName!),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _kpiBox(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color.withOpacity(.12), color.withOpacity(.08)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.30)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
      ]),
    );
  }

  Widget _pill({required IconData icon, required String label, required VoidCallback onTap}) {
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

  Widget _infoRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(k, style: const TextStyle(color: Colors.black54))),
          const SizedBox(width: 8),
          Expanded(child: Text(v)),
        ],
      ),
    );
  }
}

class _SyncFab extends StatefulWidget {
  final bool loading;
  final VoidCallback onPressed;
  const _SyncFab({required this.loading, required this.onPressed});

  @override
  State<_SyncFab> createState() => _SyncFabState();
}

class _SyncFabState extends State<_SyncFab> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        final scale = widget.loading ? 1.0 : 1.0 + 0.02 * (1 - (_ctrl.value - .5).abs() * 2);
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 180,
            height: 48,
            child: ElevatedButton(
              onPressed: widget.loading ? null : widget.onPressed,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: Ink(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: widget.loading
                        ? [Colors.grey.shade400, Colors.grey.shade500]
                        : [kOrange, kGreen],
                  ),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))],
                ),
                child: Center(
                  child: widget.loading
                      ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      SizedBox(
                        width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Text("Chargement…", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ],
                  )
                      : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.sync, color: Colors.white),
                      SizedBox(width: 8),
                      Text("Synchroniser", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
