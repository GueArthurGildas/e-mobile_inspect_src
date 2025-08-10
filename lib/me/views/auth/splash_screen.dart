import 'dart:async';
import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/views/auth/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Délai avant de naviguer vers l'écran de connexion
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fond blanc
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de l'entreprise
            Image.asset(
              'assets/me/images/MIRAH-BG.png', // Assure-toi d’avoir ce fichier dans ton projet
              height: 150,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(color: Colors.orange),
          ],
        ),
      ),
    );
  }
}
