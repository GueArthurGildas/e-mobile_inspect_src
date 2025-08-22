import 'dart:io';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';                 // ⬅️ nécessaire pour StreamSubscription


const kOrange = Colors.orange;
const kGreen  = Color(0xFF2ECC71);


class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔁 Liste d’images (assets, fichiers ou URLs)
    final images = <String>[
      'assets/me/images/fish1.jpg',
      'assets/me/images/fish2.jpg',
      'assets/images/logo_horizontal.png',
      // Ajoute librement d’autres images dans assets/me/images/
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      // endDrawer: const _UserSideDrawer(), // ⬅️ AJOUT
      drawer: const _UserSideDrawer(),
      // Entête FIXE + contenu qui SCROLLE au milieu
      body: Column(
        children: [
          // ───────── ENTÊTE (inchangée) ─────────
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            child: Container(
              padding: const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
              color: Colors.orange,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne du haut avec logo et profil
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          // CircleAvatar(
                          //   radius: 20,
                          //   backgroundColor: Colors.orange,
                          //   backgroundImage: AssetImage('assets/me/images/myImagCi.png'),
                          // ),
                          SizedBox(width: 10),
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.white,
                                backgroundImage: AssetImage('assets/me/images/MIRAH-BG.png'),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Bienvenue, user",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  _OnlineStatusChip(), // ⬅️ puce auto En ligne / Hors ligne
                                ],
                              ),
                            ],
                          ),

                        ],
                      ),
                      Builder( // ⬅️ important pour récupérer le bon contexte du Scaffold
                        builder: (ctx) => GestureDetector(
                          onTap: () => Scaffold.of(ctx)..openDrawer(),
                          child: const CircleAvatar(
                            backgroundColor: Colors.green,
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ───────── CONTENU CENTRAL SCROLLABLE ─────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 90), // 90 ≈ hauteur BottomBar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🖼️ CARROUSEL D’IMAGES (défilement horizontal)
                  _ImageCarousel(paths: images),

                  // Barre dégradée SOUS l’image
                  const SizedBox(height: 8),
                  const _SeparatorBar(),
                  const SizedBox(height: 14),

                  // Titre principal (pro)
                  const Text(
                    "Centre de Gestion Intégrée Digital",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: kOrange,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Plateforme e-Inspection du MIRAH • CSP ZEE — Côte d’Ivoire. "
                        "Facilitez les inspections des navires de pêche, assurez la traçabilité et conservez un historique complet.",
                    style: TextStyle(fontSize: 14.5, color: Colors.black87, height: 1.35),
                  ),

                  const SizedBox(height: 18),
                  const _SectionTitle("Actions rapides"),
                  const SizedBox(height: 8),

                  // Lignes d’action sobres (pas de cards)
                  _ActionRow(icon: Icons.assignment_add,   label: "Démarrer une inspection", onTap: () {}),
                  _ActionRow(icon: Icons.history,          label: "Consulter l’historique",   onTap: () {}),
                  _ActionRow(icon: Icons.event_available,  label: "Planifier une visite",      onTap: () {}),

                  const SizedBox(height: 14),
                  const _SeparatorBar(), // séparateur entre sections
                  const SizedBox(height: 16),

                  const _SectionTitle("Objectifs de l’application"),
                  const SizedBox(height: 8),
                  const _BulletLine("Faciliter les inspections de navires de pêche par le MIRAH (CSP ZEE)."),
                  const _BulletLine("Assurer la traçabilité : navire, engins, espèces, infractions, documents."),
                  const _BulletLine("Conserver un historique horodaté (photos, rapports, validations)."),
                  const _BulletLine("Fonctionnement hors-ligne avec synchronisation sécurisée."),
                  const _BulletLine("Alignement réglementaire en Côte d’Ivoire."),
                  const _BulletLine("Tableaux de bord et exports pour l’aide à la décision."),

                  const SizedBox(height: 14),
                  const _SeparatorBar(), // autre séparateur
                  const SizedBox(height: 16),

                  const _SectionTitle("Informations utiles"),
                  const SizedBox(height: 8),
                  const Text(
                    "Accédez à vos dossiers, suivez l’avancement des inspections et générez des rapports conformes. "
                        "Les données sont stockées localement en absence de réseau et se synchronisent automatiquement.",
                    style: TextStyle(fontSize: 14.5, color: Colors.black87, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ───────── FAB + BOTTOM BAR (inchangés) ─────────
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          color: kGreen,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.home, color: Colors.white),
          onPressed: () {},
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: Colors.orange,
          child: SizedBox(
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.settings, color: Colors.white),
                SizedBox(width: 40),
                Icon(Icons.history, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ──────────────────────── Carousel d’images ─────────────────────────

class _ImageCarousel extends StatefulWidget {
  final List<String> paths; // assets, fichiers locaux, ou URLs
  const _ImageCarousel({required this.paths});

  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  final _controller = PageController(viewportFraction: 0.9);
  int _index = 0;

  ImageProvider _providerFor(String path) {
    if (path.startsWith('http')) return NetworkImage(path);
    if (path.startsWith('/')) return FileImage(File(path));
    return AssetImage(path);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.paths.isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(color: Colors.grey.shade300),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200, // fixe pour éviter conflits avec le scroll parent
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.paths.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (_, i) {
              final img = widget.paths[i];
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  // léger effet "scale" sur l’item centré
                  double scale = 1.0;
                  if (_controller.position.haveDimensions) {
                    final page = _controller.page ?? _controller.initialPage.toDouble();
                    scale = (1 - (page - i).abs() * 0.08).clamp(0.9, 1.0);
                  }
                  return Center(
                    child: Transform.scale(
                      scale: scale,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          color: Colors.black12,
                          child: Image(
                            image: _providerFor(img),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // Indicateurs (points)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.paths.length, (i) {
            final isActive = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: isActive ? 20 : 6,
              decoration: BoxDecoration(
                color: isActive ? kOrange : Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/// ───────────────────────── Séparateur dégradé ────────────────────────
class _SeparatorBar extends StatelessWidget {
  const _SeparatorBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFF2ECC71)], // orange → vert
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}

/// ─────────────────────── Utilitaires d’UI sobres ─────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 16, color: kOrange),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 16.5, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String text;
  const _BulletLine(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, size: 18, color: kGreen),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13.5, height: 1.35))),
        ],
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionRow({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Container(
              width: 36, height: 36, alignment: Alignment.center,
              decoration: BoxDecoration(
                color: kOrange.withOpacity(.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: kOrange, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600))),
            const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}


class _UserSideDrawer extends StatelessWidget {
  const _UserSideDrawer();

  @override
  Widget build(BuildContext context) {
    // TODO: branche ces valeurs à ton Provider/Controller
    final String userName   = "Inspecteur";
    final String userUnit   = "MIRAH • CSP ZEE";
    final int pendingCount  = 3;  // inspections en attente
    final int doneCount     = 12; // inspections réalisées

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête utilisateur
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 26,
                    backgroundImage: AssetImage('assets/me/images/MIRAH-BG.png'),
                  ),
                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(userName,
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                            )),
                        const SizedBox(height: 2),

                        Text(userUnit,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Colors.black54,
                            )),


                      ],

                    ),
                  ),
                  _OnlineStatusChip(),
                ],
              ),
            ),

            // Petite barre séparatrice (dégradée)
            const _DrawerSeparator(),

            // KPIs (en attente / réalisées)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  Expanded(
                    child: _KPI(
                      icon: Icons.schedule,
                      color: Colors.amber[700]!,
                      label: "En attente",
                      value: pendingCount.toString(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _KPI(
                      icon: Icons.verified_outlined,
                      color: kGreen,
                      label: "Réalisées",
                      value: doneCount.toString(),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),
            const Divider(height: 1),

            // Menu
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: const Text("Profil"),
                    onTap: () {}, // TODO: navigate profil
                  ),
                  ListTile(
                    leading: const Icon(Icons.inbox_outlined),
                    title: const Text("Mes inspections"),
                    subtitle: const Text("Voir toutes les inspections"),
                    onTap: () {}, // TODO
                  ),
                  ListTile(
                    leading: const Icon(Icons.cloud_sync_outlined),
                    title: const Text("Synchroniser"),
                    subtitle: const Text("Envoyer/recevoir les données"),
                    onTap: () {}, // TODO
                  ),
                  ListTile(
                    leading: const Icon(Icons.group_outlined),
                    title: const Text("Groupes & équipes"),
                    onTap: () {}, // TODO
                  ),
                  ListTile(
                    leading: const Icon(Icons.bookmark_border),
                    title: const Text("Enregistrements"),
                    onTap: () {}, // TODO
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text("Paramètres"),
                    onTap: () {}, // TODO
                  ),
                ],
              ),
            ),

            // Bandeau bas (style “promo / aide”)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: kOrange.withOpacity(.10),
              child: Row(
                children: const [
                  Icon(Icons.help_outline, color: kOrange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Aide & support • Documentation",
                      style: TextStyle(fontWeight: FontWeight.w600),
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

class _KPI extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  const _KPI({required this.icon, required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    )),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerSeparator extends StatelessWidget {
  const _DrawerSeparator();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      margin: const EdgeInsets.only(top: 8),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFF2ECC71)], // orange → vert
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
    );
  }
}


class _OnlineStatusChip extends StatefulWidget {
  const _OnlineStatusChip({super.key});

  @override
  State<_OnlineStatusChip> createState() => _OnlineStatusChipState();
}

class _OnlineStatusChipState extends State<_OnlineStatusChip> {
  bool? _isOnline;
  late final StreamSubscription _sub;

  @override
  void initState() {
    super.initState();

    // État initial (au montage)
    Connectivity().checkConnectivity().then((res) {
      final list = res is List<ConnectivityResult> ? res : [res];
      final online = list.isNotEmpty && list.first != ConnectivityResult.none;
      if (mounted) setState(() => _isOnline = online);
    });

    // Mises à jour en temps réel
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final list = results is List<ConnectivityResult> ? results : [results];
      final online = list.isNotEmpty && list.first != ConnectivityResult.none;
      if (mounted) setState(() => _isOnline = online);
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _StatusPill(isOnline: _isOnline);
  }
}

class _StatusPill extends StatelessWidget {
  final bool? isOnline; // null => en cours de détection
  const _StatusPill({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final bool? online = isOnline;

    // Couleurs adaptées au header orange
    Color dotColor;
    String label;
    Color bg;
    Color textColor = Colors.black;

    if (online == null) {
      dotColor = Colors.white70;
      label = "Vérification…";
      bg = Colors.white.withOpacity(.15);
    } else if (online) {
      dotColor = Colors.greenAccent;
      label = "En ligne";
      bg = Colors.white.withOpacity(.18);
    } else {
      dotColor = Colors.redAccent;
      label = "Hors ligne";
      bg = Colors.white.withOpacity(.18);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: textColor, fontSize: 12.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
