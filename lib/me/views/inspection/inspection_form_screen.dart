import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/routes/app_routes.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_controller.dart';
import 'package:test_app_divkit/me/views/shared/app_bar.dart';

class WizardOption {
  String title;
  String key;
  String route;

  WizardOption({required this.title, required this.key, required this.route});
}

class InspectionWizardScreen extends StatefulWidget {
  const InspectionWizardScreen({super.key});

  @override
  State<InspectionWizardScreen> createState() => _InspectionWizardScreenState();
}

class _InspectionWizardScreenState extends State<InspectionWizardScreen> {
  int currentStep = 0;
  bool _loading = false;
  final InspectionController _controller = InspectionController();
  Map<String, dynamic> wizardData = {};

  final List<WizardOption> steps = [
    WizardOption(
      title: "Informations initiales",
      key: 'informationsInitiales',
      route: AppRoutes.inspectionInformationsInitiales,
    ),
    WizardOption(
      title: "Societe consignataire, agent shipping et capitaine du navire",
      key: 'responsables',
      route: AppRoutes.inspectionInformationsResponsables,
    ),
    WizardOption(
      title: "Contrôle documentaire",
      key: 'documents',
      route: AppRoutes.inspectionDocuments,
    ),
    WizardOption(
      title: "Contrôle des engins installes",
      key: 'enginsInstalles',
      route: AppRoutes.inspectionInformationsEngins,
    ),
    WizardOption(
      title: "Contrôle des captures sur le navire",
      key: 'controleCaptures',
      route: AppRoutes.inspectionInformationsInfractions,
    ),
    WizardOption(
      title: "Conformité aux mesures & programmes applicables",
      key: 'conformiteReglementaire',
      route: AppRoutes.inspectionSoumission,
    ),
  ];

  final Color orange = const Color(0xFFFF6A00);
  final Color disabledButton = const Color(0xA4FF6A00);
  final Color green = const Color(0xFF006400);
  final Color bg = const Color(0xFFF9F9F9);

  @override
  void initState() {
    _init();
    super.initState();
  }

  Future<void> _init() async {
    setState(() => _loading = true);
    try {
      await _controller.loadData();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void saveStepData(String key, dynamic data) {
    setState(() {
      wizardData[key] = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(_controller.data);

    return Scaffold(
      backgroundColor: bg,
      appBar: CustomAppBar(title: "Réalisation de l'Inspection"),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: orange))
          : SafeArea(
              child: Column(
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
                                ),
                              ],
                              border: Border.all(
                                color: isActive ? orange : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: isCompleted
                                    ? green
                                    : (isActive ? orange : Colors.grey[300]),
                                child: Icon(
                                  isCompleted
                                      ? Icons.check
                                      : (isActive
                                            ? Icons.edit
                                            : Icons.circle_outlined),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                steps[index].title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isActive ? orange : Colors.black87,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 16,
                                color: isActive ? orange : Colors.black87,
                              ),
                              onTap: () async {
                                if (index <= currentStep || true) {
                                  _controller.data['formData'] = [wizardData];
                                  final dynamic stepData =
                                      await Navigator.pushNamed<dynamic>(
                                        context,
                                        steps[index].route,
                                        arguments: _controller.data,
                                      );

                                  if (stepData != null) {
                                    saveStepData(steps[index].key, stepData);
                                    setState(() {
                                      currentStep = index + 1;
                                    });
                                  }
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Barre de progression
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 12,
                    ),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        // Bouton PDF
                        ElevatedButton.icon(
                          onPressed: () {
                            // Génération PDF ?
                          },
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.black,
                          ),
                          label: const Text(
                            "PDF",
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[100],
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                        ),
                        const Spacer(),
                        // Bouton suivant ou soumettre
                        ElevatedButton(
                          onPressed: () {
                            // if (currentStep < steps.length - 1) {
                            //   setState(() {
                            //     currentStep++;
                            //   });
                            // } else {
                            //   // Soumettre
                            //   ScaffoldMessenger.of(context).showSnackBar(
                            //     const SnackBar(content: Text("Inspection soumise avec succès ✅")),
                            //   );
                            // }

                            if (currentStep == steps.length - 1 || true) {
                              // Soumettre
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Inspection soumise avec succès ✅",
                                  ),
                                ),
                              );

                              print(wizardData);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: (currentStep == steps.length - 1)
                                ? orange
                                : disabledButton,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            "Soumettre",
                            // currentStep == steps.length - 1 ? "Soumettre" : "Continuer",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
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
