import 'package:flutter/material.dart';

class InspectionWizardScreen extends StatefulWidget {
  const InspectionWizardScreen({super.key});

  @override
  State<InspectionWizardScreen> createState() => _InspectionWizardScreenState();
}

class _InspectionWizardScreenState extends State<InspectionWizardScreen> {
  int currentStep = 0;

  final List<String> steps = [
    "Informations générales",
    "Navire",
    "Équipage",
    "Documents",
    "Infractions",
    "Soumission"
  ];

  final Color orange = const Color(0xFFFF6A00);
  final Color green = const Color(0xFF006400);
  final Color bg = const Color(0xFFF9F9F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text("Réalisation de l'Inspection"),
        backgroundColor: orange,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: steps.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                final isCompleted = index < currentStep;
                final isActive = index == currentStep;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentStep = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        )
                      ],
                      border: Border.all(
                        color: isActive ? orange : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor:
                        isCompleted ? green : (isActive ? orange : Colors.grey[300]),
                        child: Icon(
                          isCompleted
                              ? Icons.check
                              : (isActive ? Icons.edit : Icons.circle_outlined),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        steps[index],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isActive ? orange : Colors.black87,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    ),
                  ),
                );
              },
            ),
          ),

          // Barre de progression
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / steps.length,
              color: orange,
              backgroundColor: Colors.grey[300],
              minHeight: 6,
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          // Boutons de navigation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Bouton PDF
                ElevatedButton.icon(
                  onPressed: () {
                    // Génération PDF ?
                  },
                  icon: const Icon(Icons.picture_as_pdf, color: Colors.black),
                  label: const Text("PDF", style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[100],
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const Spacer(),
                // Bouton suivant ou soumettre
                ElevatedButton(
                  onPressed: () {
                    if (currentStep < steps.length - 1) {
                      setState(() {
                        currentStep++;
                      });
                    } else {
                      // Soumettre
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Inspection soumise avec succès ✅")),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: orange,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    currentStep == steps.length - 1 ? "Soumettre" : "Continuer",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
