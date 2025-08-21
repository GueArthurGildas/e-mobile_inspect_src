import 'dart:io';
import 'package:flutter/material.dart';

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
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            backgroundImage: AssetImage('assets/me/images/MIRAH-BG.png'),
                          ),
                          SizedBox(width: 10),
                          Text(
                            "Bienvenue, user",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person, color: Colors.white),
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
