import 'package:flutter/material.dart';

class NavireStatusPage extends StatefulWidget {
  const NavireStatusPage({super.key});

  @override
  State<NavireStatusPage> createState() => _NavireStatusPageState();
}

class _NavireStatusPageState extends State<NavireStatusPage> {
  bool showDetails = true;

  final Color orange = const Color(0xFFFF6A00);
  final Color green = const Color(0xFF2E7D32);
  final Duration animDuration = const Duration(milliseconds: 400);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: orange,
        title: const Text(
          "Navire Status",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        elevation: 1,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --- Haut de page : Icône bateau + Nom + Statut ---
          Container(
            margin: const EdgeInsets.only(bottom: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icône bateau
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFFF6A00).withOpacity(0.1),
                  ),
                  child: Icon(
                    Icons.directions_boat_filled,
                    color: const Color(0xFFFF6A00),
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),

                // Détails nom + statut
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Kouassi Express",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 10,
                            color: const Color(0xFF2E7D32),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Inspection en cours",
                            style: TextStyle(color: Color(0xFF2E7D32)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _sectionHeader("Inspection prévue entre"),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              "08:00 - 09:30",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: orange,
              ),
            ),
          ),

          _sectionDivider(),

          _sectionHeader("État d’avancement"),
          Column(
            children: [
              _statusTile(
                "Inspection en cours",
                "L’inspection est en cours sur le quai C2",
                true,
                green,
              ),
              _statusTile(
                "À quai",
                "Le navire est arrivé à quai",
                false,
                orange,
              ),
              _statusTile(
                "En approche",
                "Le navire est proche du port",
                false,
                Colors.grey,
              ),
              _statusTile(
                "En mer",
                "Le navire est encore en mer",
                false,
                Colors.grey,
              ),
              _statusTile(
                "Inspection programmée",
                "Inspection enregistrée",
                false,
                Colors.grey,
              ),
            ],
          ),

          _sectionDivider(),

          _sectionHeader("Informations du navire"),
          _animatedInfo(showDetails, [
            _infoRow("Nom", "Kouassi Express"),
            _infoRow("Type", "Navire de pêche"),
            _infoRow("Pavillon", "Côte d'Ivoire"),
            _infoRow("Longueur", "45 mètres"),
            _infoRow("Propriétaire", "Atlantique CI"),
          ]),

          _sectionDivider(),

          _sectionHeader("Port d’inspection"),
          _locationRow("San Pedro, Côte d’Ivoire"),

          _sectionDivider(),

          _sectionHeader("Note pour l’inspecteur"),
          _animatedNote(
            "Le navire doit être inspecté à son arrivée à quai. Vérifier tous les documents.",
          ),

          _sectionDivider(),

          _sectionHeader("Documents à vérifier"),
          _placeholder("Liste des documents (à remplir)..."),

          _sectionDivider(),

          _sectionHeader("Photos / Captures"),
          _placeholder("Galerie des captures à afficher..."),

          _sectionDivider(),

          _sectionHeader("Commentaires additionnels"),
          _placeholder("Commentaires, anomalies ou recommandations..."),

          const SizedBox(height: 30),

          // Boutons
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.picture_as_pdf),
                color: orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      showDetails = !showDetails;
                    });
                  },
                  icon: Icon(Icons.remove_red_eye, color: Colors.white),
                  label: Text(
                    showDetails ? "Masquer infos" : "Voir fiche navire",
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
            // Bouton PDF
            ElevatedButton.icon(
              onPressed: () {
                // Action PDF
              },
              icon: Icon(Icons.picture_as_pdf, color: orange),
              label: Text("Fiche PDF", style: TextStyle(color: orange)),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Colors.white,
                side: BorderSide(color: orange),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Bouton Voir fiche navire
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    showDetails = !showDetails;
                  });
                },
                icon: Icon(Icons.remove_red_eye, color: Colors.white),
                label: Text(
                  showDetails ? "Masquer infos" : "Voir fiche navire",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: orange,
        ),
      ),
    );
  }

  Widget _statusTile(
    String title,
    String subtitle,
    bool isActive,
    Color color,
  ) {
    return AnimatedContainer(
      duration: animDuration,
      curve: Curves.easeInOut,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Icon(
                Icons.radio_button_checked,
                size: 20,
                color: isActive ? color : Colors.grey,
              ),
              Container(height: 30, width: 2, color: Colors.grey.shade300),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? color : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(flex: 6, child: Text(value)),
        ],
      ),
    );
  }

  Widget _animatedInfo(bool visible, List<Widget> children) {
    return AnimatedOpacity(
      duration: animDuration,
      opacity: visible ? 1 : 0,
      child: Column(children: children),
    );
  }

  Widget _locationRow(String location) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: Colors.redAccent),
        const SizedBox(width: 8),
        Expanded(child: Text(location)),
      ],
    );
  }

  Widget _animatedNote(String text) {
    return AnimatedContainer(
      duration: animDuration,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: orange.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 2, offset: Offset(0, 2)),
        ],
      ),
      child: Text(text),
    );
  }

  Widget _placeholder(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(text, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _sectionDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      height: 1,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 1, offset: Offset(0, 1)),
        ],
      ),
    );
  }
}
