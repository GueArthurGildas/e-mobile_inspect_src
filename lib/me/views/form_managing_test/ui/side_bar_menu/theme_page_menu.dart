import 'package:flutter/material.dart';

const _deepGreen = Color(0xFF145A32); // vert sombre

/// Scaffold commun : AppBar + contenu + bandeau vert sombre en bas
class SectionScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floating;

  const SectionScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floating,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 0,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: body,
            ),
          ),
          // Bandeau vert sombre
          Container(
            height: 10,
            width: double.infinity,
            color: _deepGreen,
          ),
        ],
      ),
      floatingActionButton: floating,
    );
  }
}
