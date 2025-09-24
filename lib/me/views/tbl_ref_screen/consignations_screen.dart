import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/controllers/consignations_controller.dart';

class ConsignationsScreen extends StatefulWidget {
  const ConsignationsScreen({super.key});

  @override
  State<ConsignationsScreen> createState() => _ConsignationsScreenState();
}

class _ConsignationsScreenState extends State<ConsignationsScreen> {
  final ConsignationsController _controller = ConsignationsController();
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
        title: const Text('Consignations'),
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
