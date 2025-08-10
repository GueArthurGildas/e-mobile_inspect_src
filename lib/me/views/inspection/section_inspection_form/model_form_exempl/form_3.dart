import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InfosGeneralesScreen extends StatefulWidget {
  const InfosGeneralesScreen({super.key});

  @override
  State<InfosGeneralesScreen> createState() => _InfosGeneralesScreenState();
}

class _InfosGeneralesScreenState extends State<InfosGeneralesScreen> {
  final _formKey = GlobalKey<FormState>();
  final Color orange = const Color(0xFFFF6A00);
  final Color green = const Color(0xFF006400);

  // Champs
  String? typeInspection, port, inspecteur;
  bool isSurprise = false;
  DateTime? date;
  TimeOfDay? heure;

  final titreController = TextEditingController();
  final lieuController = TextEditingController();
  final contexteController = TextEditingController();
  final consignesController = TextEditingController();
  final observationsController = TextEditingController();

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => date = picked);
  }

  Future<void> pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => heure = picked);
  }

  Widget sectionTitle(String title, {IconData? icon, Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon ?? Icons.circle, color: color ?? orange),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color ?? orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget inputField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label),
      validator: (val) => val!.isEmpty ? 'Champ requis' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Informations générales"),
        backgroundColor: orange,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            sectionTitle(
              "🛥️  INFOS GÉNÉRALES",
              icon: Icons.info_outline_rounded,
            ),
            inputField("Titre de l'inspection", titreController),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Type d'inspection"),
              items: [
                'Complète',
                'Rapide',
                'Surprise',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => typeInspection = val),
              validator: (val) => val == null ? 'Sélection requise' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Date prévue",
                      ),
                      child: Text(
                        date != null
                            ? DateFormat.yMMMMd('fr_FR').format(date!)
                            : "Choisir une date",
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: pickTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: "Heure prévue",
                      ),
                      child: Text(
                        heure != null
                            ? heure!.format(context)
                            : "Choisir une heure",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Port d’inspection"),
              items: [
                'Abidjan',
                'San Pedro',
                'Sassandra',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => port = val),
              validator: (val) => val == null ? 'Sélection requise' : null,
            ),
            const SizedBox(height: 12),
            inputField("Lieu géographique (GPS ou Zone)", lieuController),

            const SizedBox(height: 24),
            sectionTitle(
              "👥  ÉQUIPE EN CHARGE",
              icon: Icons.group,
              color: green,
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Inspecteur principal",
              ),
              items: [
                'KONE',
                'N’Guessan',
                'Traoré',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => inspecteur = val),
              validator: (val) => val == null ? 'Sélection requise' : null,
            ),
            SwitchListTile(
              title: const Text("Inspection surprise ?"),
              value: isSurprise,
              activeColor: green,
              onChanged: (val) => setState(() => isSurprise = val),
            ),

            const SizedBox(height: 24),
            sectionTitle(
              "📄  CONTEXTE & OBSERVATIONS",
              icon: Icons.article,
              color: Colors.black87,
            ),
            inputField("Contexte ou mission", contexteController, maxLines: 2),
            inputField(
              "Consignes particulières",
              consignesController,
              maxLines: 2,
            ),
            inputField(
              "Observations générales",
              observationsController,
              maxLines: 3,
            ),

            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Étape enregistrée ✅")),
                  );
                }
              },
              icon: const Icon(Icons.save),
              label: const Text("Enregistrer"),
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
