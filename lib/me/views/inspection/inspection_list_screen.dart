import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/routes/app_routes.dart';

class PendingInspectionPage extends StatefulWidget {
  @override
  _PendingInspectionPageState createState() => _PendingInspectionPageState();
}

class _PendingInspectionPageState extends State<PendingInspectionPage> {
  final List<Map<String, String>> inspections = [
    {
      "shipName": "Navire Ivoire",
      "date": "08/06/2025",
      "port": "Abidjan",
      "status": "En attente",
    },
    {
      "shipName": "Navire Atlantique",
      "date": "09/06/2025",
      "port": "San Pedro",
      "status": "En attente",
    },
    {
      "shipName": "Navire Delta",
      "date": "10/06/2025",
      "port": "Sassandra",
      "status": "En retard",
    },
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredInspections = inspections
        .where(
          (item) => item["shipName"]!.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Inspections en attente'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Rechercher un navire...',
                prefixIcon: const Icon(Icons.search, color: Colors.black),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.orange.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.orange.shade700,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: filteredInspections.length,
              itemBuilder: (context, index) {
                final item = filteredInspections[index];
                final isLate = item['status'] == "En retard";

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                    border: Border.all(color: Colors.orange.shade100),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icône navire
                          CircleAvatar(
                            radius: 28,
                            backgroundColor: Colors.orange.shade100,
                            child: Icon(
                              Icons.directions_boat,
                              color: Colors.orange.shade800,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Détails inspection
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['shipName']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text("Date : ${item['date']}"),
                                Text("Port : ${item['port']}"),
                              ],
                            ),
                          ),

                          // Badge + Bouton
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: isLate
                                      ? Colors.red[100]
                                      : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  item['status']!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isLate
                                        ? Colors.red[900]
                                        : Colors.orange[800],
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.green.shade800,
                                    width: 2,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  backgroundColor: Colors.transparent,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Voir",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Transform.rotate(
                                      angle:
                                          0.6, // inclinaison vers le haut gauche (~-23°)
                                      child: Icon(
                                        Icons.arrow_upward,
                                        size: 16,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      // --- Bas : boutons PDF + Voir
                      Row(
                        children: [
                          // Bouton PDF
                          OutlinedButton(
                            onPressed: () {
                              // Action PDF
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: Colors.red.shade400,
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                            ),
                            child: Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red.shade400,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Bouton Voir large
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                // Action Voir
                              },
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: Colors.green.shade800,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    AppRoutes.navireStatus,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Transform.rotate(
                                      angle: -0.4,
                                      child: Icon(
                                        Icons.arrow_upward,
                                        size: 16,
                                        color: Colors.green.shade800,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Voir",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
