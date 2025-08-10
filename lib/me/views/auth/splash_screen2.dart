// lib/screens/splash_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:test_app_divkit/ui/screen/signin/signin1.dart';

import '../inspection/inspection_controller.dart';

class SplashScreen2 extends StatefulWidget {
  const SplashScreen2({super.key});

  static String id = "splash_screen2";

  @override
  State<SplashScreen2> createState() => _SplashScreen2State();
}

class _SplashScreen2State extends State<SplashScreen2> {
  final InspectionController _controller = InspectionController();

  @override
  void initState() {
    super.initState();
    //_init();

    // Délai avant de naviguer vers l'écran de connexion
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Signin1Page()),
      );
    });
  }

  // Future<void> _init() async {
  //   try {
  //     await _controller.loadData();
  //   } finally {
  //     if (!mounted) return;
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => Signin1Page()),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF6A00), // Orange dominant
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cercle de synchronisation
              Container(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  strokeWidth: 10,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  backgroundColor: Colors.white.withOpacity(0.4),
                ),
              ),
              const SizedBox(height: 40),

              // Texte principal
              const Text(
                "Syncing...",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),

              // Texte secondaire
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  "Please wait while your changes are synchronized.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
