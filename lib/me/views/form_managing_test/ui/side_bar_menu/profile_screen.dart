import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/side_bar_menu/theme_page_menu.dart';



class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: "Profil",
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.person), title: Text("Nom complet")),
          Divider(),
          ListTile(leading: Icon(Icons.badge_outlined), title: Text("Matricule / Rôle")),
          Divider(),
          ListTile(leading: Icon(Icons.email_outlined), title: Text("Email")),
        ],
      ),
    );
  }
}

class MyInspectionsScreen extends StatelessWidget {
  const MyInspectionsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: "Mes inspections",
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) => ListTile(
          leading: const Icon(Icons.assignment_outlined),
          title: Text("Inspection #${i + 1}"),
          subtitle: const Text("Navire • Statut • Date"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () {
            // TODO: ouvrir le détail si besoin
          },
        ),
      ),
    );
  }
}

class SyncCenterScreen extends StatelessWidget {
  const SyncCenterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: "Synchroniser",
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const ListTile(
              leading: Icon(Icons.cloud_sync_outlined),
              title: Text("Centre de synchronisation"),
              subtitle: Text("Envoyer/recevoir les données"),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.cloud_upload_outlined),
              label: const Text("Lancer la synchronisation"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              onPressed: () async {
                // branche ta logique ici si tu veux un accès direct
                // await _syncController.syncAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Synchronisation démarrée…")),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GroupsTeamsScreen extends StatelessWidget {
  const GroupsTeamsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: "Groupes & équipes",
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.group_outlined), title: Text("Équipe Contrôles")),
          ListTile(leading: Icon(Icons.group_outlined), title: Text("Équipe Conformité")),
          ListTile(leading: Icon(Icons.group_outlined), title: Text("Équipe Statistiques")),
        ],
      ),
    );
  }
}

class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: "Enregistrements",
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(leading: Icon(Icons.bookmark_border), title: Text("Brouillons")),
          ListTile(leading: Icon(Icons.save_alt_outlined), title: Text("Exports générés")),
          ListTile(leading: Icon(Icons.history), title: Text("Historique d’actions")),
        ],
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return SectionScaffold(
      title: "Paramètres",
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SwitchListTile(
            value: true,
            onChanged: null, // TODO: binder
            title: Text("Thème sombre"),
          ),
          ListTile(leading: Icon(Icons.notifications_outlined), title: Text("Notifications")),
          ListTile(leading: Icon(Icons.security_outlined), title: Text("Sécurité")),
        ],
      ),
    );
  }
}
