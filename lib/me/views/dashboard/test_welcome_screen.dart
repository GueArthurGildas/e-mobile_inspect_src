import 'dart:io';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/message/screen_chat.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/msg_screen.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/upload_doc_insp/upload_all_inspect_services.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:e_Inspection_APP/me/config/api_constants.dart';
import 'package:e_Inspection_APP/me/controllers/user_controller.dart';
import 'package:e_Inspection_APP/me/models/user_model.dart';
import 'package:e_Inspection_APP/me/routes/app_routes.dart';
import 'package:e_Inspection_APP/me/services/database_service.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/Groups_teams_screen.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/Inspection_api_sync.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/auto_moving_icon.dart';
import 'dart:async';

import 'package:e_Inspection_APP/me/views/form_managing_test/ui/inspection_list_screen.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/profile_current.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/side_bar_menu/config_wallet_screen.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/sync_service_inspection.dart';
import 'package:e_Inspection_APP/me/views/form_managing_test/ui/upload_doc_insp/upload_test_doc_inspect.dart';                 // ⬅️ nécessaire pour StreamSubscription


const kOrange = Colors.orange;
const kGreen  = Color(0xFF2ECC71);


class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {

  final UserController _userCtrl = UserController();
  String _displayName = "Utilisateur";
  User? myUser = User();



  Future<void> _loadUser() async {
    final current = await _userCtrl.loadCurrentUser(); // ou getCurrentSession()

    setState(() {
       myUser = current;
      _displayName = current?.name ?? 'Utilisateur';
    });
  }



  initState(){
    _loadUser();
  }

  @override
  Widget build(BuildContext context) {
    // 🔁 Liste d’images (assets, fichiers ou URLs)
    final images = <String>[
      'assets/me/images/fish1.jpg',
      'assets/me/images/fish2.jpg',
      //'assets/images/logo_horizontal.png',
      // Ajoute librement d’autres images dans assets/me/images/
    ];

    final int pending = myUser?.nbInspectionsPending ?? 0;


    return Scaffold(
      backgroundColor: Colors.white,
      // endDrawer: const _UserSideDrawer(), // ⬅️ AJOUT
      drawer: _UserSideDrawer(userName: _displayName, myUser: myUser,),
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
                        children:  [
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
                                children:  [
                                  Text(
                                    "Bienvenue, $_displayName",
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
            child: Stack(
              children: [
                // 1) Fond image (avec errorBuilder pour voir si le chemin est bon)
                Positioned.fill(
                  child: Image.asset(
                    "assets/me/images/fond_screen.png",
                    fit: BoxFit.cover,
                    // Si l’asset est introuvable, on verra un fond rouge:
                    errorBuilder: (_, __, ___) => const ColoredBox(color: Colors.redAccent),
                  ),
                ),

                // 2) (Optionnel) voile. Désactive-le pour vérifier que l’image est bien visible.
                // Positioned.fill(
                //   child: ColoredBox(color: Colors.white.withOpacity(0.85)),
                // ),

                // 3) Ton contenu scrollable par-dessus
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ImageCarousel(paths: images),
                      const SizedBox(height: 8),
                      const _SeparatorBar(),

                      // Barre dégradée SOUS l’image
                      const SizedBox(height: 8),
                      //const _SeparatorBar(),
                      const SizedBox(height: 14),

                      // Titre principal (pro)
                      const Text(
                        "Centre de Gestion ",
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
                      const _SectionTitle("Fonctionnalités clés"),
                      const SizedBox(height: 8),

                      // Lignes d’action sobres (pas de cards)
                      _ActionRow(icon: Icons.assignment_add,   label: "Réaliser une inspection", onTap: () {}),
                      _ActionRow(icon: Icons.history,          label: "Consulter l’historique",   onTap: () {}),
                      _ActionRow(icon: Icons.event_available,  label: "Assigner une inspection",      onTap: () {}),

                      ///// test pour envoyer les images d'une inspection vers laravel ( juste un bouoton test pour voir )


                      //const PushInspection320Button(),


                      //const SendMessageBox(), // <-- Le champ + bouton "Envoyer"

                      const SizedBox(height: 20),
                      ///// for chat

                      FloatingActionButton.extended(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white, // 👈 applique au texte et à l’icône
                        icon: const Icon(Icons.forum),
                        label: const Text("Communiquer"),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ChatScreen()),
                          );
                        },
                      ),


                      /// for synch dossier inspection
                      //SyncAllInspectionsButton(),

                      //////////////

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
              ],
            ),
          )

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
          icon: const AutoMovingIcon(
            icon: Icons.sailing,
            size: 32,          // taille de base de l’icône
            color: Colors.white,
            ampX: 3,           // amplitude horizontale
            ampY: 2,           // amplitude verticale
            duration: Duration(seconds: 2), // vitesse du cycle
            frame: 40,         // cadre stable (évite que ça déborde)
          ),
          onPressed: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => const InspectionListScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(position: offsetAnimation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 450),
              ),
            );
          },
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
              children: [
                // ⚙️ Réglages
                //final int pending = myUser?.nbInspectionsPending ?? 0;

              Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
                  tooltip: "Alert Inspection",
                  onPressed: () {
                    _showInfoSheet(
                      context,
                      title: "Alert",
                      message: "Inspections en attente : $pending",
                      icon: Icons.sd_card_alert,
                      messageColor: pending > 0 ? Colors.red : null, // ⬅️ TEXTE EN ROUGE si > 0
                    );
                  },
                ),

                // Badge clignotant en haut à droite si pending > 0
                if (pending > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: _BlinkingBadge(count: pending),
                  ),
              ],
            ),



            const SizedBox(width: 40), // espace pour l'encoche du FAB

                // // ⏱️ Historique
                // IconButton(
                //   icon: const Icon(Icons.history, color: Colors.white),
                //   onPressed: () => _showInfoSheet(
                //     context,
                //     title: "Historique",
                //     message:
                //     "Consultez les inspections précédentes, exports et journaux d’activité.",
                //     icon: Icons.history,
                //   ),
                //   tooltip: "Historique",
                // ),

                // 🚪 Déconnexion
                // 🚪 Déconnexion avec mini-loader avant le modal
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  tooltip: "Déconnexion",
                  onPressed: () { _logoutFlow(context); },
                ),

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

  final String userName; // propriété immuable
  User? myUser;

   _UserSideDrawer({ required this.userName, required this.myUser});


  @override
  Widget build(BuildContext context) {
    // TODO: branche ces valeurs à ton Provider/Controller
    //final String userName   = "Inspecteur";
    final String userRole   = myUser?.primaryRoleName?? '—';
    final int pendingCount  = myUser?.nbInspectionsPending??0;  // inspections en attente
    final int doneCount     = myUser?.nbInspectionsDone??0;  // inspections réalisées



    ///
    // /               final User user = _controller.users[index];
    //                 final role = user.primaryRoleName ?? '—';
    //                 final done = user.nbInspectionsDone;
    //                 final pending = user.nbInspectionsPending;

    void _showAxenovSheet(BuildContext context) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,                // plein écran si besoin
        useSafeArea: true,
        backgroundColor: Colors.transparent,     // pour arrondis propres
        builder: (_) => const _AxenovBottomSheet(),
      );
    }

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

                        Text(myUser?.name??"",
                            style: const TextStyle(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                            )),
                        const SizedBox(height: 2),

                        Text(userRole,
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
                      onTap: () async {
                        final rootCtx = Navigator.of(context, rootNavigator: true).context;
                        Navigator.pop(context); // ferme le Drawer

                        final pending = myUser?.fieldJsonInspectPending ?? const [];

                        await openModalAfterLoader(
                          rootCtx,
                          PendingInspectionsScreen(items: pending),
                          loader: const Duration(milliseconds: 900),
                          heightFactor: 0.95,
                        );
                      },
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _KPI(
                      icon: Icons.verified_outlined,
                      color: kGreen,
                      label: "Réalisées",
                      value: doneCount.toString(),
                      onTap: () async {
                        final rootCtx = Navigator.of(context, rootNavigator: true).context;
                        Navigator.pop(context); // ferme le Drawer

                        final done = myUser?.fieldJsonInspectDone ?? const [];

                        await openModalAfterLoader(
                          rootCtx,
                          PendingInspectionsScreen(items: done),
                          loader: const Duration(milliseconds: 900),
                          heightFactor: 0.95,
                        );
                      },
                    ),
                  ),
                  // Expanded(
                  //   child: _KPI(
                  //     icon: Icons.verified_outlined,
                  //     color: kGreen,
                  //     label: "Réalisées",
                  //     value: doneCount.toString(),
                  //   ),
                  // ),
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
                    // onTap: () {
                    //   Navigator.pop(context);
                    //   Navigator.pushNamed(context, AppRoutes.profile);
                    // },
                    onTap: () async {
                      final rootCtx = Navigator.of(context, rootNavigator: true).context; // 1) capture
                      Navigator.pop(context);                                             // 2) ferme le Drawer
                      await openModalAfterLoader(                                         // 3) loader -> modal
                        rootCtx,
                        const ProfileScreen(), // mets ton widget cible
                        loader: const Duration(milliseconds: 1100),
                      );
                    },


                  ),



                  // ListTile(
                  //   leading: const Icon(Icons.inbox_outlined),
                  //   title: const Text("Mes inspections"),
                  //   subtitle: const Text("Voir toutes les inspections"),
                  //   onTap: () async {
                  //     final rootCtx = Navigator.of(context, rootNavigator: true).context; // 1) capture
                  //     Navigator.pop(context);                                             // 2) ferme le Drawer
                  //     await openModalAfterLoader(                                         // 3) loader -> modal
                  //       rootCtx,
                  //       const MyInspectionsScreen(), // mets ton widget cible
                  //       loader: const Duration(milliseconds: 1100),
                  //     );
                  //   },
                  //
                  //
                  // ),


                  // ListTile(
                  //   leading: const Icon(Icons.cloud_sync_outlined),
                  //   title: const Text("Synchroniser"),
                  //   subtitle: const Text("Envoyer/recevoir les données"),
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     Navigator.pushNamed(context, AppRoutes.syncro);
                  //   },
                  // ),

                  ListTile(
                    leading: const Icon(Icons.group_outlined),
                    title: const Text("Groupes & équipes"),
                    onTap: () async {
                      final rootCtx = Navigator.of(context, rootNavigator: true).context;
                      Navigator.pop(context); // ferme Drawer

                      await openModalAfterLoader(
                        rootCtx,
                        const GroupsTeamsScreen(), // ton nouvel écran
                        loader: const Duration(milliseconds: 900),
                        heightFactor: 0.95, // occupe presque tout l’écran
                      );
                    },
                  ),


                  // ListTile(
                  //   leading: const Icon(Icons.bookmark_border),
                  //   title: const Text("Enregistrements"),
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //     Navigator.pushNamed(context, AppRoutes.records);
                  //   },
                  //
                  // ),


                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text("Paramètres"),

                    onTap: () async {
                      final rootCtx = Navigator.of(context, rootNavigator: true).context;
                      Navigator.pop(context); // ferme Drawer

                      await openModalAfterLoader(
                        rootCtx,
                        const SettingsScreen(), // ton nouvel écran
                        loader: const Duration(milliseconds: 900),
                        heightFactor: 0.95, // occupe presque tout l’écran
                      );
                    },
                  ),


                  /// ici mon test pour synchroniser les inspection
                  ListTile(
                    leading: const Icon(Icons.cloud_sync_outlined),
                    title: const Text("Centre de synchronisation"),
                    onTap: () async {
                      final rootCtx = Navigator.of(context, rootNavigator: true).context;
                      Navigator.pop(context); // ferme Drawer

                      await openModalAfterLoader(
                        rootCtx,
                        const SyncCenterScreen(), // ton nouvel écran
                        loader: const Duration(milliseconds: 900),
                        heightFactor: 0.95, // occupe presque tout l’écran
                      );
                    },
                  ),

                  const SizedBox(width: 30),

                  // Petite barre séparatrice (dégradée)
                  const _DrawerSeparator(),


                  // Align(
                  //   alignment: Alignment.topRight, // topLeft, bottomCenter, etc.
                  //   child: Image.asset(
                  //     "assets/me/images/ci-fishe.png",
                  //     width: 80,
                  //     height: 80,
                  //     fit: BoxFit.contain,
                  //   ),
                  // )
                  // Padding(
                  //   padding: const EdgeInsets.only(top: 50, left: 10),
                  //   child: Image.asset(
                  //     "assets/me/images/MIRAH-BG.png",
                  //     //width: 60,   // largeur plus petite
                  //     height: 80,  // hauteur plus petite (optionnel)
                  //    // fit: BoxFit.contain, // garde les proportions de l’image
                  //   ),
                  // ),
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 6),

                  // ───── Bandeau rouge défilant
                  Container(
                    height: 26,
                    alignment: Alignment.centerLeft,
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(.06),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const _MarqueeText(
                      text:
                      "⚠️ Synchronisez l’application si vous êtes connecté à Internet pour rester à jour avec les données.",
                      style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600),
                      pixelsPerSecond: 70,
                      pause: Duration(milliseconds: 900),
                      gap: 60,
                    ),
                  ),

                  const Divider(height: 1),

                  //Padding( padding: const EdgeInsets.only(top: 20, left: 10), child: Image.asset( "assets/me/images/MIRAH-BG.png", width: 100, ), )

// ───── Conseils
                  const Text("Conseils", style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  const _TipLine(text: "Activez le Wi-Fi avant de lancer la synchronisation."),
                  const _TipLine(text: "Gardez l’application ouverte jusqu’à la fin du processus."),



                ],
              ),
            ),

            // Bandeau bas (style “promo / aide”)
            // Container(
            //   width: double.infinity,
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            //   color: kOrange.withOpacity(.10),
            //   child: Row(
            //     children: const [
            //       Icon(Icons.help_outline, color: kOrange),
            //       SizedBox(width: 10),
            //       Expanded(
            //         child: Text(
            //           "Aide & support • Documentation",
            //           style: TextStyle(fontWeight: FontWeight.w600),
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // 1) Le "tile" cliquable
            InkWell(
              borderRadius: BorderRadius.circular(12),
              splashColor: kOrange.withOpacity(.12),
              onTap: () => _showAxenovSheet(context),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: kOrange.withOpacity(.10),
                child: const Row(
                  children: [
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
  final VoidCallback? onTap; // <- ajouté

  const _KPI({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
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
                Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );

    return onTap == null
        ? content
        : InkWell(onTap: onTap, borderRadius: BorderRadius.circular(10), child: content);
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


// ✅ Ajoute 2 params optionnels (facultatifs) pour les KPI
void _showInfoSheet(
    BuildContext context, {
      required String title,
      required String message,
      required IconData icon,
      Color? messageColor,
      int? pendingCount,   // ⬅️ optionnel
      int? doneCount,      // ⬅️ optionnel
    }) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      final viewInsets = MediaQuery.of(ctx).viewInsets.bottom;

      return SafeArea(
        top: false,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.95,
          builder: (_, scrollCtrl) {
            return StatefulBuilder(
              builder: (context, setLocal) {
                bool syncing = false;

                Future<void> _onSync() async {
                  if (syncing) return;
                  setLocal(() => syncing = true);
                  try {
                    // 👉 Place ici ton appel réel de synchronisation
                    await Future.delayed(const Duration(seconds: 2));
                  } finally {
                    if (context.mounted) setLocal(() => syncing = false);
                  }
                }

                return SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ───── Header pro
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(.10),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                              ],
                            ),
                            child: Icon(icon, color: Colors.orange, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("Centre d’alertes & synchronisation",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                                SizedBox(height: 4),
                                Text(
                                  "Gardez vos données à jour et suivez vos inspections en un coup d’œil.",
                                  style: TextStyle(fontSize: 13.5, color: Colors.black54, height: 1.25),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Titre original + message
                      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        style: TextStyle(fontSize: 14.5, height: 1.35, color: messageColor ?? Colors.black87),
                      ),

                      const SizedBox(height: 14),

                      // ───── Bandeau rouge défilant
                      Container(
                        height: 26,
                        alignment: Alignment.centerLeft,
                        clipBehavior: Clip.hardEdge,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(.06),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const _MarqueeText(
                          text:
                          "⚠️ Synchronisez l’application si vous êtes connecté à Internet pour rester à jour avec les données.",
                          style: TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w600),
                          pixelsPerSecond: 70,
                          pause: Duration(milliseconds: 900),
                          gap: 60,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ───── KPI card (si fourni)
                      if (pendingCount != null || doneCount != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border.all(color: Colors.black12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              if (pendingCount != null)
                                Expanded(
                                  child: _MetricChip(
                                    icon: Icons.sd_card_alert,
                                    label: "En attente",
                                    value: pendingCount.toString(),
                                    color: Colors.amber[700]!,
                                  ),
                                ),
                              if (pendingCount != null && doneCount != null) const SizedBox(width: 10),
                              if (doneCount != null)
                                Expanded(
                                  child: _MetricChip(
                                    icon: Icons.verified_outlined,
                                    label: "Réalisées",
                                    value: doneCount.toString(),
                                    color: const Color(0xFF2ECC71),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ───── Conseils
                      const Text("Conseils", style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      const _TipLine(text: "Activez le Wi-Fi avant de lancer la synchronisation."),
                      const _TipLine(text: "Gardez l’application ouverte jusqu’à la fin du processus."),
                      const _TipLine(text: "Vérifiez l’heure/horloge du téléphone (utile pour les horodatages)."),

                      const SizedBox(height: 16),

                      // ───── Actions rapides
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _PillAction(
                            icon: Icons.visibility_outlined,
                            label: "Voir les en attente",
                            onTap: () => Navigator.of(context).pop(), // remplace par ton action
                          ),
                          _PillAction(
                            icon: Icons.history,
                            label: "Historique",
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          _PillAction(
                            icon: Icons.settings_outlined,
                            label: "Paramètres",
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // ───── CTA principal : Synchroniser maintenant
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:() async {
                            final rootCtx = Navigator.of(context, rootNavigator: true).context;
                            Navigator.pop(context); // ferme Drawer

                            await openModalAfterLoader(
                              rootCtx,
                              const SyncCenterScreen(), // ton nouvel écran
                              loader: const Duration(milliseconds: 900),
                              heightFactor: 0.95, // occupe presque tout l’écran
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Ink(

                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                colors: syncing
                                    ? [Colors.grey.shade400, Colors.grey.shade500]
                                    : [const Color(0xFFFFA726), const Color(0xFF2ECC71)], // orange → vert
                              ),
                            ),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                child: syncing
                                    ? Row(
                                  key: const ValueKey('loading'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    ),
                                    SizedBox(width: 10),
                                    Text("Synchronisation…",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                  ],
                                )
                                    : Row(
                                  key: const ValueKey('ready'),
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.sync, color: Colors.white),
                                    SizedBox(width: 10),
                                    Text("Synchroniser maintenant",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text("Fermer"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      );
    },
  );
}


class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _MetricChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 34, height: 34, alignment: Alignment.center,
            decoration: BoxDecoration(color: color.withOpacity(.15), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.black54)),
          ]),
        ],
      ),
    );
  }
}

class _PillAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PillAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.orange.withOpacity(.10),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}




class _BlinkingBadge extends StatefulWidget {
  final int count;
  const _BlinkingBadge({required this.count});

  @override
  State<_BlinkingBadge> createState() => _BlinkingBadgeState();
}

class _BlinkingBadgeState extends State<_BlinkingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.35,
      upperBound: 1.0,
    )..repeat(reverse: true);
    _opacity = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txt = widget.count > 99 ? '99+' : '${widget.count}';
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
        ),
        constraints: const BoxConstraints(minWidth: 20, minHeight: 18),
        child: Text(
          txt,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

Future<void> _logoutFlow(BuildContext context) async {
  // 1) mini-loader (non dismissible) pendant ~600ms
  await _showTinyLoader(context, const Duration(milliseconds: 600));

  // 2) puis modal de confirmation
  final shouldLogout = await _confirmLogout(context);
  if (shouldLogout != true) return;

  // 3) TODO: effacer la session (SharedPreferences / cache / provider)
  // final prefs = await SharedPreferences.getInstance();
  // await prefs.remove("auth_token");
  // await prefs.clear(); // si tu veux tout vider

  // 4) redirection dure vers Login (on nettoie toute la stack)
  if (context.mounted) {


    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }
}

// Mini-loader centré
Future<void> _showTinyLoader(BuildContext context, Duration d) async {
  // Toujours prendre le root navigator (contexte stable)
  final rootCtx = Navigator.of(context, rootNavigator: true).context;

  showDialog(
    context: rootCtx,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (_) => const Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Center(
        child: SizedBox(
          width: 64, height: 64,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
            ),
            child: Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      ),
    ),
  );

  await Future.delayed(d);

  // Fermer le loader via le root navigator (contexte stable)
  final nav = Navigator.of(rootCtx, rootNavigator: true);
  if (nav.canPop()) nav.pop();
}

// Alerte de confirmation => renvoie true/false
Future<bool?> _confirmLogout(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Déconnexion"),
      content: const Text(
          "Voulez-vous vraiment vous déconnecter ?\n"
              "Vos données locales restent sauvegardées."
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Annuler"),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.logout),
          label: const Text("Se déconnecter"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: () async {
            //final userCtrl = context.read<UserController>();
            //var u = userCtrl.currentUser;
            //userCtrl.logout();
            Navigator.of(context).pop(true);  },
        ),
      ],
    ),
  );
}

Future<void> openModalAfterLoader(
    BuildContext context,
    Widget modal, {
      Duration loader = const Duration(milliseconds: 900),
      double heightFactor = 0.92,
    }) async {
  final rootCtx = Navigator.of(context, rootNavigator: true).context;

  await _showTinyLoader(rootCtx, loader);

  await showModalBottomSheet(
    context: rootCtx,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => FractionallySizedBox(
      heightFactor: heightFactor,
      child: modal,
    ),
  );
}

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final double pixelsPerSecond; // vitesse (px/s)
  final Duration pause;         // pause au bout de chaque tour
  final double gap;             // espace virtuel entre deux tours

  const _MarqueeText({
    required this.text,
    this.style,
    this.pixelsPerSecond = 60,
    this.pause = const Duration(milliseconds: 800),
    this.gap = 40,
  });

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText> with TickerProviderStateMixin {
  late AnimationController _ctrl;
  Animation<double>? _anim;

  double _containerW = 0;
  double _textW = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this);
  }

  @override
  void didUpdateWidget(covariant _MarqueeText oldWidget) {
    super.didUpdateWidget(oldWidget);
    // si texte/style/vitesse changent, on recalculera au prochain build
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _recomputeAndRun() async {
    if (!mounted) return;

    // 1) Mesurer la largeur réelle du texte
    final tp = TextPainter(
      text: TextSpan(text: widget.text, style: widget.style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    _textW = tp.width;

    // 2) Si le texte tient dans le conteneur, pas de défilement : on affiche simplement le texte
    if (_textW <= _containerW) {
      _ctrl.stop();
      _anim = null;
      if (mounted) setState(() {});
      return;
    }

    // 3) Sinon, on anime de (containerW) → (-textW), distance = containerW + textW + gap
    final distance = _containerW + _textW + widget.gap;
    final seconds = distance / widget.pixelsPerSecond;
    _ctrl.duration = Duration(milliseconds: (seconds * 1000).round());
    _anim = Tween<double>(begin: _containerW, end: -_textW).animate(_ctrl);

    // 4) Boucle avec pause à chaque fin
    void start() async {
      if (!mounted) return;
      await _ctrl.forward(from: 0);
      if (!mounted) return;
      await Future.delayed(widget.pause);
      if (!mounted) return;
      start(); // relance
    }

    start();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        // mémorise la largeur disponible puis (re)lance l’anim si nécessaire
        final newW = constraints.maxWidth;
        if (newW != _containerW) {
          _containerW = newW;
          // recalcul + relance
          WidgetsBinding.instance.addPostFrameCallback((_) => _recomputeAndRun());
        }

        // Conteneur qui CLIPPE (évite l’overflow en paysage)
        return ClipRect(
          child: _anim == null
              ? Text(
            widget.text,
            maxLines: 1,
            overflow: TextOverflow.clip,
            softWrap: false,
            style: widget.style,
          )
              : AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              final x = _anim!.value;
              return Transform.translate(
                offset: Offset(x, 0),
                child: SizedBox(
                  width: _textW, // largeur exacte du texte
                  child: Text(
                    widget.text,
                    maxLines: 1,
                    overflow: TextOverflow.visible,
                    softWrap: false,
                    style: widget.style,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _TipLine extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;

  const _TipLine({
    required this.text,
    this.icon = Icons.info_outline,
    this.color = const Color(0xFFFFA726), // orange
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13.5, height: 1.35, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}


// 3) Contenu stylé du modal
class _AxenovBottomSheet extends StatelessWidget {
  const _AxenovBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1.0),   // petite montée en douceur
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      builder: (ctx, scale, child) {
        return Transform.scale(
          scale: scale,
          alignment: Alignment.bottomCenter,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 24,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 44,
                height: 5,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: theme.dividerColor,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),

              // En-tête
              Row(
                children: [
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: kOrange,
                    child: Icon(Icons.business, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "AXENOV CONSULTING",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                    "Documentation intégrée et disponible dans la version complète.",
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Infos clés
              _InfoTile(
                icon: Icons.handyman_outlined,
                title: "Mission",
                subtitle: "Conception & développement de l’application",
              ),
              _InfoTile(
                icon: Icons.layers_outlined,
                title: "Stack",
                subtitle: "Mobile (offline-first) • API Intégration • Base de données • NoSQL",
              ),
              _InfoTile(
                icon: Icons.description_outlined,
                title: "Documentation",
                subtitle: "Implémentée dans la version complète de l’application",
              ),
              _InfoTile(
                icon: Icons.contact_mail_outlined,
                title: "Contact",
                subtitle: "info-contact@axenov.ci • +225 07 67 07 19 14",
              ),

              const SizedBox(height: 16),
              // CTA
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.menu_book_outlined),
                  style: ButtonStyle(
                    backgroundColor:
                    WidgetStatePropertyAll(kOrange.withOpacity(.95)),
                  ),
                  label: const Text("Ouvrir la documentation"),
                  onPressed: () {
                    // TODO: Naviguer vers ton écran/URL de doc si disponible
                    Navigator.of(context).maybePop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "La documentation est disponible dans la version complète.",
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                icon: const Icon(Icons.close),
                label: const Text("Fermer"),
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Petit item d’info réutilisable
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kOrange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}












