import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/controllers/types_documents_controller.dart';

class TypesDocumentsScreen extends StatefulWidget {
  const TypesDocumentsScreen({super.key});

  @override
  State<TypesDocumentsScreen> createState() => _TypesDocumentsScreenState();
}

class _TypesDocumentsScreenState extends State<TypesDocumentsScreen> {
  final TypesDocumentsController _controller = TypesDocumentsController();
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
        title: const Text('TypesDocuments'),
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
