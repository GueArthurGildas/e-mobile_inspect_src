import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/controllers/typenavires_controller.dart';

class TypenaviresScreen extends StatefulWidget {
  const TypenaviresScreen({super.key});

  @override
  State<TypenaviresScreen> createState() => _TypenaviresScreenState();
}

class _TypenaviresScreenState extends State<TypenaviresScreen> {
  final TypenaviresController _controller = TypenaviresController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await _controller.loadLocalOnly();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Typenavires'),
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
