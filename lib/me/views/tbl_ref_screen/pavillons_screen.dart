import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/controllers/pavillons_controller.dart';

class PavillonsScreen extends StatefulWidget {
  const PavillonsScreen({super.key});

  @override
  State<PavillonsScreen> createState() => _PavillonsScreenState();
}

class _PavillonsScreenState extends State<PavillonsScreen> {
  final PavillonsController _controller = PavillonsController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _controller.loadAndSync();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pavillons'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _controller.items.length,
              itemBuilder: (context, index) {
                final item = _controller.items[index];
                return ListTile(
                  title: Text(item.toMap().toString()),
                );
              },
            ),
    );
  }
}
