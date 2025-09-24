import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/controllers/especes_controller.dart';

class EspecesScreen extends StatefulWidget {
  const EspecesScreen({super.key});

  @override
  State<EspecesScreen> createState() => _EspecesScreenState();
}

class _EspecesScreenState extends State<EspecesScreen> {
  final EspecesController _controller = EspecesController();
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
        title: const Text('Especes'),
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
