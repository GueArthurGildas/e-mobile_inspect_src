import 'package:flutter/material.dart';

class FABAction {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color fabBackground;
  final Color foreground;

  const FABAction({
    this.fabBackground = const Color(0xFFE2E0F9),
    this.foreground = Colors.black,
    required this.icon,
    required this.label,
    required this.onPressed,
  });
}

class AppFABSpeedDial extends StatefulWidget {
  const AppFABSpeedDial({
    super.key,
    required this.fabActions,
    this.menuButtonColor = const Color(0xff5d5d72),
  });

  final List<FABAction> fabActions;
  final Color menuButtonColor;

  @override
  State<AppFABSpeedDial> createState() => _AppFABSpeedDialState();
}

class _AppFABSpeedDialState extends State<AppFABSpeedDial>
    with SingleTickerProviderStateMixin {
  bool _isOpen = false;
  late AnimationController _controller;
  late List<String> _backupLabels;
  late List<String> _labels;
  late List<String> _placeholders;

  @override
  void initState() {
    super.initState();
    _backupLabels = widget.fabActions.map((a) => a.label).toList();
    _placeholders = List.generate(_backupLabels.length, (index) => "");
    _labels = _placeholders;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _controller.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          setState(() => _labels = _backupLabels);
          break;
        case AnimationStatus.dismissed:
          setState(() => _labels = _placeholders);
          break;
        case AnimationStatus.forward:
        case AnimationStatus.reverse:
          break;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMenu() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget _buildMenuItem(FABAction action, int index) {
    final offsetY = (index + 1) * 55.0;

    return AnimatedPositioned(
      duration: Duration(milliseconds: 250),
      bottom: _isOpen ? offsetY + 30 : 15,
      right: 16,
      child: GestureDetector(
        onTap: () => action.onPressed(),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: action.fabBackground,
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isOpen) Icon(action.icon, color: action.foreground),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _labels[index],
                  style: TextStyle(
                    color: action.foreground,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        for (final (index, FABAction action) in widget.fabActions.indexed)
          _buildMenuItem(action, index),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            backgroundColor: widget.menuButtonColor,
            onPressed: _toggleMenu,
            tooltip: 'Menu',
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            child: AnimatedIcon(
              icon: AnimatedIcons.menu_close,
              progress: _controller,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
