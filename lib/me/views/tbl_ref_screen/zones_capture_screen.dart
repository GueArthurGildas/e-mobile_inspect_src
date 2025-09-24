import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/controllers/zones_capture_controller.dart';

class ZonesCaptureScreen extends StatefulWidget {
  const ZonesCaptureScreen({super.key});

  @override
  State<ZonesCaptureScreen> createState() => _ZonesCaptureScreenState();
}

class _ZonesCaptureScreenState extends State<ZonesCaptureScreen> {
  final ZonesCaptureController _controller = ZonesCaptureController();
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
        title: const Text('ZonesCapture'),
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
