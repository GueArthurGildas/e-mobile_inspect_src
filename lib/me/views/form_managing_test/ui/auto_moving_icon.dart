import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Icône animée qui flotte (X/Y) et pivote légèrement en boucle.
class AutoMovingIcon extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;

  /// amplitude du mouvement en px
  final double ampX;
  final double ampY;

  /// durée d’un cycle complet
  final Duration duration;

  /// Taille du cadre (pour garder la mise en page stable)
  final double frame;

  const AutoMovingIcon({
    super.key,
    required this.icon,
    this.size = 28,
    this.color = Colors.white,
    this.ampX = 3,
    this.ampY = 2,
    this.duration = const Duration(seconds: 2),
    this.frame = 40,
  });

  @override
  State<AutoMovingIcon> createState() => _AutoMovingIconState();
}

class _AutoMovingIconState extends State<AutoMovingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(); // boucle infinie
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.frame,
      height: widget.frame,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) {
          // t : 0..1
          final t = _c.value * 2 * math.pi;
          final dx = widget.ampX * math.sin(t);
          final dy = widget.ampY * math.cos(t * 1.2); // rythme un peu différent
          final angle = 0.06 * math.sin(t * 1.4);     // ~3.4°

          return Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.rotate(
              angle: angle,
              child: Icon(widget.icon, size: widget.size, color: widget.color),
            ),
          );
        },
      ),
    );
  }
}
