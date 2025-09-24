import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:e_Inspection_APP/config/constant.dart';
import 'package:e_Inspection_APP/me/config/app_colors.dart';
import 'package:e_Inspection_APP/me/routes/app_routes.dart';
import 'package:e_Inspection_APP/model/feature/banner_slider_model.dart';
import 'package:e_Inspection_APP/model/feature/category_model.dart';
import 'package:e_Inspection_APP/ui/reusable/cache_image_network.dart';
import 'package:e_Inspection_APP/ui/reusable/global_widget.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeMenuPage extends StatelessWidget {
  const HomeMenuPage({super.key});
  final bool showDetails = true;
  final Color orange = const Color(0xFFFF6A00);
  final Color green = const Color(0xFF2E7D32);
  final Duration animDuration = const Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    final Color myOrangeColor = const Color(0xFFFF6A00);
    final Color myGreenColor = const Color(0xFF43A047); // vert légèrement foncé
    final _globalWidget = GlobalWidget();

    final int enAttente = 5;
    final int assignees = 8;
    final String note = "Vérifiez vos inspections du jour.";

    return Scaffold(
      // appBar: AppBar(
      //   centerTitle: true,
      //   systemOverlayStyle: SystemUiOverlayStyle.light,
      //   title: Image.asset('assets/me/images/MIRAH-BG.png',
      //       height: 24, color: Colors.white),
      //   backgroundColor: myOrangeColor,
      //   leading: IconButton(
      //     icon: const Icon(Icons.help_outline),
      //     onPressed: () {
      //       Fluttertoast.showToast(msg: 'Click about us');
      //     },
      //   ),
      //   actions: <Widget>[
      //     IconButton(
      //         icon: _globalWidget.customNotifIcon(
      //             count: 8, notifColor: Colors.white),
      //         onPressed: () {
      //           Fluttertoast.showToast(msg: 'Click notification');
      //         }),
      //     IconButton(
      //         icon: const Icon(Icons.settings),
      //         onPressed: () {
      //           Fluttertoast.showToast(msg: 'Click setting');
      //         })
      //   ],
      // ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/me/images/fond_screen.png'),
              fit: BoxFit.cover, // couvre tout l’espace sans déformer
            ),
          ),

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTop(myGreenColor),
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  height: 1,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Statistiques
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: myGreenColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: myGreenColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.pendingInspection,
                                );
                                Fluttertoast.showToast(
                                  msg: 'goToPedingInspcetionClick',
                                );
                              },
                              child: _StatItem(
                                label: "En attente",
                                value: enAttente.toString(),
                                color: myOrangeColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: _StatItem(
                              label: "Assignées",
                              value: assignees.toString(),
                              color: myOrangeColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note,
                              style: TextStyle(color: Colors.grey[800]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Boutons
                _MenuButton(
                  icon: Icons.hourglass_top,
                  label: 'Inspections en attente',
                  color: myOrangeColor,
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.pendingInspection);
                  },
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  icon: Icons.assignment_ind,
                  label: 'Inspections assignées',
                  color: myOrangeColor,
                  onTap: () {},
                ),
                const SizedBox(height: 20),
                _MenuButton(
                  icon: Icons.list_alt,
                  label: 'Liste des inspections',
                  color: myOrangeColor,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ),

      // ✅ Boutons fixes en bas
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Premier bouton : prend 1/3 de la largeur
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  /* Action PDF */
                },
                icon: Icon(Icons.picture_as_pdf, color: orange),
                label: Text("Fiche PDF", style: TextStyle(color: orange)),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: orange),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Deuxième bouton : même proportion
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  /* Action PDF */
                },
                icon: Icon(Icons.picture_as_pdf, color: orange),
                label: Text("Fiche PDF", style: TextStyle(color: orange)),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: orange),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Troisième bouton : même proportion
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  /* Action PDF */
                },
                icon: Icon(Icons.picture_as_pdf, color: orange),
                label: Text("Fiche PDF", style: TextStyle(color: orange)),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  side: BorderSide(color: orange),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTop(Color myGreenColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Hero(
            tag: 'profilePicture',
            child: ClipOval(
              child: buildCacheNetworkImage(
                url: '$globalUrl/user/avatar.png',
                width: 50,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gue Arthur',
                    style: TextStyle(
                      color: myGreenColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: myGreenColor, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Administrateur',
                          style: TextStyle(
                            color: myGreenColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          GestureDetector(
            onTap: () {
              Fluttertoast.showToast(msg: 'Click log out in ');
            },
            child: Text(
              'Log Out',
              style: TextStyle(
                color: myGreenColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 16),
            Text(label, style: TextStyle(fontSize: 18, color: color)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}
