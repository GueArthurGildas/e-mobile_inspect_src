import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app_divkit/me/controllers/inspections_controller.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {



    Color getStatusColor(int statut) {
      switch (statut) {
        case 1: return Colors.orange;                 // En cours
        case 2: return Colors.grey;         // En attente (jaune foncé)
        case 3: return Colors.green;                  // Terminé
        default: return Colors.grey;
      }
    }

    IconData getStatusIcon(int statut) {
      switch (statut) {
        case 1: return Icons.sync;            // En cours
        case 2: return Icons.hourglass_bottom; // En attente
        case 3: return Icons.check_circle;     // Terminé
        default: return Icons.help_outline;
      }
    }

    String getStatusLabel(int statut) {
      switch (statut) {
        case 1: return "En cours";
        case 2: return "En attente";
        case 3: return "Terminé";
        default: return "Inconnu";
      }
    }

    void _onItemTapped(int index) {
      setState(() {
        selectedIndex = index;
      });

      // Affiche ce que le bouton fait
      String action = '';
      switch (index) {
        case 0:
          action = "Ouverture de la liste des inspections";
          break;
        case 1:
          action = "Synchronisation des données avec le serveur";
          break;
        case 2:
          action = "Ouverture des paramètres de l'application";
          break;
        case 3:
          action = "Informations sur l'application";
          break;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(action),
          duration: const Duration(seconds: 2),
        ),
      );
    }


    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // HEADER AVEC BORDURE ARRONDIE EN BAS
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
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            // child: Icon(Icons.flag, color: Colors.green),
                            backgroundImage:  AssetImage('assets/me/images/MIRAH-BG.png'),
                          ),
                          const SizedBox(width: 10),
                          const Text(
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
                  // Barre de recherche
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Recherche ici en entrant la reference',
                        border: InputBorder.none,
                        suffixIcon: Icon(Icons.search, color: Colors.orange),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Filtres
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              children: [
                _buildFilterChip("All", isSelected: true),
                const SizedBox(width: 8),
                _buildFilterChip("Aujourd'hui"),
                const SizedBox(width: 8),
                _buildFilterChip("All"),
                const Spacer(),
                const Icon(Icons.filter_list, color: Colors.black54),
              ],
            ),
          ),

          // Liste des dossiers
          Expanded(
            child: Consumer<InspectionController>(
              builder: (context, controller, child) {
                final inspections = controller.items;

                if (inspections.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  itemCount: inspections.length,
                  itemBuilder: (context, index) {
                    final inspection = inspections[index];
                    final statut = inspection.statutInspectionId ?? 0;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Icône dossier dépendant du statut
                          Icon(Icons.folder, color: getStatusColor(statut), size: 45),
                          const SizedBox(width: 12),

                          // Infos inspection
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Numéro inspection
                                Text(
                                  "Inspection #${inspection.id}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Consigne
                                Text(
                                  "Consigne : ${inspection.consigneInspect ?? 'Aucune'}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Date assignation
                                Text(
                                  "Assignée le ${inspection.datePrevueInspect ?? '-'}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Badge statut à droite avec icône
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: getStatusColor(statut).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: getStatusColor(statut)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  getStatusIcon(statut),
                                  size: 14,
                                  color: getStatusColor(statut),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  getStatusLabel(statut),
                                  style: TextStyle(
                                    color: getStatusColor(statut),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          )



        ],
      ),

      // Bottom navigation
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Dossier',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sync),
            label: 'Synchronisation',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Paramètres',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Infos',
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.shade300 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Text(label),
    );
  }
}
