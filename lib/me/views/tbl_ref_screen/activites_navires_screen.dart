import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/controllers/activites_navires_controller.dart';

class ActivitesNaviresScreen extends StatefulWidget {
  const ActivitesNaviresScreen({super.key});

  @override
  State<ActivitesNaviresScreen> createState() => _ActivitesNaviresScreenState();
}

class _ActivitesNaviresScreenState extends State<ActivitesNaviresScreen> {
  final ActivitesNaviresController _controller = ActivitesNaviresController();
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
        title: const Text('ActivitesNavires'),
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
