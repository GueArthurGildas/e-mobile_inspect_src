import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app_divkit/me/controllers/inspections_controller.dart';
import 'package:test_app_divkit/me/routes/app_routes.dart';
import 'package:test_app_divkit/me/views/dashboard/test_welcome_screen.dart';
import 'package:test_app_divkit/me/views/form_managing_test/ui/wizard_screen.dart';
import 'package:test_app_divkit/me/views/inspection/inspection_form_screen.dart';
import 'package:test_app_divkit/me/views/shared/common.dart';
// 👉 importe l'écran cible
import 'package:test_app_divkit/me/views/form_managing_test/ui/inspection_list_screen.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});
  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  static const _primary = Color(0xFFFF6A00);
  final InspectionController _controllerInspection = InspectionController();
  static const Duration _minLoader = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    _run();
  }




  Future<void> _run() async {
    final start = DateTime.now();


    try {
      await Common.checkInternetConnection(); // juste info; on avance quoi qu’il arrive
      await _controllerInspection.loadAndSync();
    } catch (_) {
      // on ignore et on continue offline
    }

    final elapsed = DateTime.now().difference(start);
    if (elapsed < _minLoader) {
      await Future.delayed(_minLoader - elapsed);
    }
    if (!mounted) return;

    // 🔽 Transition locale (slide-up + fade) sans passer par onGenerateRoute
    Navigator.of(context).pushAndRemoveUntil(
      _slideUpRouteToInspectionList(),
          (route) => false,
    );
  }

  /// Route avec transition douce depuis le bas + fade
  PageRoute _slideUpRouteToInspectionList() {
    return PageRouteBuilder(
      settings: const RouteSettings(name: AppRoutes.homeMenu), // on garde le name
      transitionDuration: const Duration(milliseconds: 650),         // un peu lente
      reverseTransitionDuration: const Duration(milliseconds: 420),
      pageBuilder: (_, __, ___) => const WalletScreen(),
      transitionsBuilder: (_, animation, __, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: _primary,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 52, height: 52,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 5),
          ),
        ),
      ),
    );
  }
}
