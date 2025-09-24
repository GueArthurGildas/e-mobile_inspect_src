import 'dart:io';
import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/controllers/activites_navires_controller.dart';

class ActivitesNaviresScreen extends StatefulWidget {
  const ActivitesNaviresScreen({super.key});

  @override
  State<ActivitesNaviresScreen> createState() => _ActivitesNaviresScreenState();
}

class _ActivitesNaviresScreenState extends State<ActivitesNaviresScreen> {
  final ActivitesNaviresController _controller = ActivitesNaviresController();

  bool _loading = true;
  String _loadingMessage = "Chargement...";
  String? _error;

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
      final online = await _hasInternet();
      if (!online) {
        throw const SocketException("No Internet");
      }

      // 1) Sync API -> local
      await _controller.loadAndSync();
    } catch (e) {
      // 2) Visible error message
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

    // 3) Always reload local for display
    await _controller.loadLocalOnly();

    if (!mounted) return;
    setState(() => _loading = false);
  }

  /// Check real internet connectivity via DNS lookup
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
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: _controller.items.length,
              itemBuilder: (context, index) {
                final item = _controller.items[index];
                return ListTile(
                  title: Text("Activité #${item.id ?? '—'}"),
                  subtitle: Text(item.toMap().toString()),
                );
              },
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activités Navires'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refresh),
        ],
      ),
      body: body,
    );
  }
}
