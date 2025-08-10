// pays_screen.dart
import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/controllers/pays_controller.dart';
import 'package:test_app_divkit/me/models/pays_model.dart';

class PaysScreen extends StatefulWidget {
  const PaysScreen({super.key});

  @override
  State<PaysScreen> createState() => _PaysScreenState();
}

class _PaysScreenState extends State<PaysScreen> {
  final PaysController _controller = PaysController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    await _controller.loadAndSync();
    print("Nombre de pays chargés : \${_controller.pays.length}");
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des pays'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Recharger depuis l\'API',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _controller.pays.isEmpty
          ? const Center(child: Text("Aucun pays trouvé dans la base locale."))
          : ListView.builder(
              itemCount: _controller.pays.length,
              itemBuilder: (context, index) {
                final Pays pays = _controller.pays[index];
                return ListTile(
                  leading: Text(pays.id.toString()),
                  title: Text(pays.libelle),
                  subtitle: Text(pays.code),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          for (var p in _controller.pays) {
            print('${p.id} - ${p.libelle} (${p.code})');
          }
        },
        child: const Icon(Icons.list),
      ),
    );
  }
}
