import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/controllers/conservations_controller.dart';

class ConservationsScreen extends StatefulWidget {
  const ConservationsScreen({super.key});

  @override
  State<ConservationsScreen> createState() => _ConservationsScreenState();
}

class _ConservationsScreenState extends State<ConservationsScreen> {
  final ConservationsController _controller = ConservationsController();
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
        title: const Text('Conservations'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _controller.items.length,
              itemBuilder: (context, index) {
                final item = _controller.items[index];
                return ListTile(title: Text(item.toMap().toString()));
              },
            ),
    );
  }
}
