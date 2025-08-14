import 'package:flutter/material.dart';


class InformationsCapturesScreen extends StatefulWidget {
  const InformationsCapturesScreen({super.key, required this.tabBars, required this.tabBarViews});

  final List<Tab> tabBars;
  final List<Widget> tabBarViews;

  @override
  State<InformationsCapturesScreen> createState() => _InformationsCapturesScreenState();
}

class _InformationsCapturesScreenState extends State<InformationsCapturesScreen> {
  static const Color _orangeColor = Color(0xFFFF6A00);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.tabBars.length,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: _orangeColor,
          iconTheme: IconThemeData(color: Colors.white),
          titleSpacing: 0,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: TabBar(
              isScrollable: true,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black26,
              indicatorColor: Colors.white,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: widget.tabBars,
            ),
          ),
        ),
        body: TabBarView(
          children: widget.tabBarViews,
        ),
      ),
    );
  }
}
