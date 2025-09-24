import 'dart:io';
import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/controllers/conservations_controller.dart';

class ConservationsScreen extends StatefulWidget {
  const ConservationsScreen({super.key});

  @override
  State<ConservationsScreen> createState() => _ConservationsScreenState();
}

class _ConservationsScreenState extends State<ConservationsScreen> {
  final ConservationsController _controller = ConservationsController();
  bool _loading = true;
  String _loadingMessage = "Chargement...";
  String? _error; // <- pour afficher le message d'erreur à l'écran

  @override
  void initState() {
    super.initState();
    _loadLocal();
  }

  Future<void> _loadLocal() async {
    setState(() {
      _loading = true;
      _error = null;
      _loadingMessage = "Chargement depuis la base locale...";
    });
    await _controller.loadLocalOnly();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
      _loadingMessage = "Mise à jour des données locales...";
    });

    try {
      // 1) Vérifier l'accès internet AVANT l'appel API
      final online = await _hasInternet();
      if (!online) {
        throw const SocketException("No Internet");
      }

      // 2) Synchro avec l’API
      await _controller.loadAndSync();
    } catch (e) {
      // 3) Afficher une erreur visible à l'écran
      _error = "Pas de connexion internet. Affichage des données locales.";
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Pas de connexion internet"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    // 4) Toujours recharger le local
    await _controller.loadLocalOnly();

    if (!mounted) return;
    setState(() => _loading = false);
  }

  /// Vérifie une vraie connectivité internet (pas juste Wi-Fi/4G)
  Future<bool> _hasInternet() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(_loadingMessage, style: const TextStyle(fontSize: 16)),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
        ],
      ),
    )
        : Column(
      children: [
        if (_error != null)
          Container(
            width: double.infinity,
            color: Colors.red.withOpacity(0.1),
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                const Icon(Icons.wifi_off, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: _refresh,
                  child: const Text("Réessayer"),
                )
              ],
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: _controller.items.length,
            itemBuilder: (context, index) {
              final item = _controller.items[index];
              return ListTile(title: Text(item.toMap().toString()));
            },
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conservations'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: body,
    );
  }
}
