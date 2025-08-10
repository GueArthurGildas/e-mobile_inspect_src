import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/controllers/types_engins_controller.dart';

class TypesEnginsScreen extends StatefulWidget {
  const TypesEnginsScreen({super.key});

  @override
  State<TypesEnginsScreen> createState() => _TypesEnginsScreenState();
}

class _TypesEnginsScreenState extends State<TypesEnginsScreen> {
  final TypesEnginsController _controller = TypesEnginsController();
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
        title: const Text('TypesEngins'),
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
