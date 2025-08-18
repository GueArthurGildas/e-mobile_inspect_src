import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WalletScreen(),
  ));
}

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ En-tête personnalisé avec image + recherche
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
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage('assets/me/images/MIRAH-BG.png'),
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
                    // Champ de recherche
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Recherche ici en entrant la référence',
                          border: InputBorder.none,
                          suffixIcon: Icon(Icons.search, color: Colors.orange),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ Contenu principal après l’en-tête
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
                  _BalanceCard(),
                  SizedBox(height: 20),
                  _MainActionButton(),
                  SizedBox(height: 30),
                  _MenuOption(icon: Icons.history, label: "Historique des transactions"),
                  SizedBox(height: 12),
                  _MenuOption(icon: Icons.shield_outlined, label: "Sécurité"),
                  SizedBox(height: 12),
                  _MenuOption(icon: Icons.settings, label: "Paramètres"),
                ],
              ),
            ),
          ],
        ),
      ),

      // ✅ Bouton central flottant vert
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          color: const Color(0xFF2ECC71),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
          onPressed: () {},
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // ✅ BottomBar arrondi
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          color: Colors.orange,
          child: SizedBox(
            height: 65,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Icon(Icons.home, color: Colors.white),
                SizedBox(width: 40),
                Icon(Icons.person, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text("Solde disponible", style: TextStyle(color: Colors.white70)),
          SizedBox(height: 8),
          Text(
            "250 000 FCFA",
            style: TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            "Compte principal",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _MainActionButton extends StatelessWidget {
  const _MainActionButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Action de recharge
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF2ECC71),
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text(
        "Recharger",
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}

class _MenuOption extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MenuOption({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.grey[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: Colors.orange),
      title: Text(label),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {},
    );
  }
}
