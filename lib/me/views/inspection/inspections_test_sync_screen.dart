import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app_divkit/me/controllers/inspection_controller.dart';
import 'package:test_app_divkit/me/controllers/inspections_controller.dart';
import 'package:test_app_divkit/me/models/inspection.dart';
import 'package:test_app_divkit/me/models/inspection_model.dart';

class InspectionScreen extends StatelessWidget {
  const InspectionScreen({super.key});

  /// Couleur selon le statut
  Color getStatusColor(int? statut) {
    switch (statut) {
      case 1:
        return Colors.orange; // En cours
      case 2:
        return Colors.amber.shade700; // En attente
      case 3:
        return Colors.green; // Terminé
      default:
        return Colors.grey;
    }
  }

  /// Icône selon le statut
  IconData getStatusIcon(int? statut) {
    switch (statut) {
      case 1:
        return Icons.sync;
      case 2:
        return Icons.hourglass_bottom;
      case 3:
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  /// Libellé du statut
  String getStatusLabel(int? statut) {
    switch (statut) {
      case 1:
        return "En cours";
      case 2:
        return "En attente";
      case 3:
        return "Terminé";
      default:
        return "Inconnu";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => InspectionController()..loadLocalOnly(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Liste des inspections'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                // Re-synchroniser les données
                context.read<InspectionController>().loadAndSync();
              },
            )
          ],
        ),
        body: Consumer<InspectionController>(
          builder: (context, controller, child) {
            if (controller.items.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return ListView.builder(
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                final Inspection inspection = controller.items[index];
                final statut = inspection.statutInspectionId ?? 0;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  padding: const EdgeInsets.all(12),
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
                      // Icône dossier
                      Icon(Icons.folder, color: getStatusColor(statut), size: 45),
                      const SizedBox(width: 12),

                      // Infos inspection
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Inspection #${inspection.id}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "Date prévue : ${inspection.datePrevueInspect ?? '-'}",
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              "Consigne : ${inspection.consigneInspect ?? 'Aucune'}",
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                            ),
                          ],
                        ),
                      ),

                      // Badge statut à droite
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
      ),
    );
  }
}
