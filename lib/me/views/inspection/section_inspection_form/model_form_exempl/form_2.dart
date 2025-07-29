import 'package:flutter/material.dart';

class FormulaireInspectionStyleBanking extends StatelessWidget {
  const FormulaireInspectionStyleBanking({super.key});

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF6A00);
    final green = const Color(0xFF006400);

    InputDecoration fieldDecoration(String label, {int lines = 1}) {
      return InputDecoration(
        labelText: label,
        alignLabelWithHint: lines > 1,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Réalisation de l'inspection"),
        backgroundColor: orange,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Texte simple
          TextField(
            decoration: fieldDecoration("Titre de l’inspection *"),
          ),
          const SizedBox(height: 16),

          // Dropdown
          DropdownButtonFormField<String>(
            decoration: fieldDecoration("Type d’inspection *"),
            items: ['Complète', 'Partielle', 'Surprise']
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (val) {},
          ),
          const SizedBox(height: 16),

          // Date
          TextField(
            decoration: fieldDecoration("Date prévue *"),
            readOnly: true,
            onTap: () {
              // implémenter showDatePicker ici
            },
          ),
          const SizedBox(height: 16),

          // Heure
          TextField(
            decoration: fieldDecoration("Heure prévue *"),
            readOnly: true,
            onTap: () {
              // implémenter showTimePicker ici
            },
          ),
          const SizedBox(height: 16),

          // Lieu
          TextField(
            decoration: fieldDecoration("Lieu géographique *"),
          ),
          const SizedBox(height: 16),

          // Texte multilignes
          TextField(
            maxLines: 4,
            decoration: fieldDecoration("Observations générales *", lines: 4),
          ),
          const SizedBox(height: 16),

          // Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Inspection surprise ?", style: TextStyle(fontSize: 16)),
              Switch(
                value: true,
                activeColor: green,
                onChanged: (val) {},
              )
            ],
          ),
          const SizedBox(height: 16),

          // Checkbox
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Documents disponibles", style: TextStyle(fontSize: 16)),
              CheckboxListTile(
                value: true,
                onChanged: (val) {},
                title: const Text("Certificat d'immatriculation"),
              ),
              CheckboxListTile(
                value: false,
                onChanged: (val) {},
                title: const Text("Licence de pêche"),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Signature (factice ici)
          OutlinedButton.icon(
            onPressed: () {
              // ouvrir signature pad
            },
            icon: const Icon(Icons.draw),
            label: const Text("Signer inspection"),
          ),
          const SizedBox(height: 16),

          // Bouton soumission
          ElevatedButton.icon(
            onPressed: () {
              // soumettre
            },
            icon: const Icon(Icons.send),
            label: const Text("Soumettre l’inspection"),
            style: ElevatedButton.styleFrom(
              backgroundColor: orange,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
