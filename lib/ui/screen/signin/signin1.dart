import 'package:test_app_divkit/me/routes/app_routes.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Signin1Page extends StatefulWidget {
  const Signin1Page({super.key});

  @override
  State<Signin1Page> createState() => _Signin1PageState();
}

class _Signin1PageState extends State<Signin1Page> {
  bool _obscureText = true;
  IconData _iconVisible = Icons.visibility_off;

  final Color _backgroundColor = Colors.white;
  final Color _primaryColor = const Color(0xFFFF6A00); // Orange
  final Color _underlineColor = const Color(0xFFFF6A00);
  final Color _buttonColor = const Color(0xFFFF6A00); // Orange

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
      _iconVisible = _obscureText ? Icons.visibility_off : Icons.visibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: Platform.isIOS
            ? SystemUiOverlayStyle.dark
            : const SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.dark,
              ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(32, 72, 32, 24),
          children: [
            Image.asset('assets/me/images/MIRAH-BG.png', height: 120),
            const SizedBox(height: 32),
            TextField(
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(color: _primaryColor),
              cursorColor: _primaryColor,
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _primaryColor, width: 2.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _underlineColor),
                ),
                labelText: 'Email',
                labelStyle: TextStyle(color: _primaryColor),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              obscureText: _obscureText,
              style: TextStyle(color: _primaryColor),
              cursorColor: _primaryColor,
              decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _primaryColor, width: 2.0),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _underlineColor),
                ),
                labelText: 'Password',
                labelStyle: TextStyle(color: _primaryColor),
                suffixIcon: IconButton(
                  icon: Icon(_iconVisible, color: _primaryColor, size: 20),
                  onPressed: _toggleObscureText,
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                Fluttertoast.showToast(
                  msg: 'Click forgot password',
                  toastLength: Toast.LENGTH_SHORT,
                );
              },
              child: Text(
                'Forgot Password?',
                style: TextStyle(color: _primaryColor, fontSize: 13),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(_buttonColor),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                ),
              ),
              onPressed: () {
                Fluttertoast.showToast(
                  msg: 'Click login',
                  toastLength: Toast.LENGTH_SHORT,
                );

                // Navigator.pushNamed(context, AppRoutes.homeMenu);
                Navigator.pushNamed(context, AppRoutes.inspectionWizard);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'CONNEXION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Sign in with',
                style: TextStyle(fontSize: 15, color: _primaryColor),
              ),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: 'Signin with google',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: _primaryColor),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(4),
                        ),
                      ),
                      child: const Image(
                        image: AssetImage('assets/images/google.png'),
                        width: 24,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: 'Signin with facebook',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    },
                    child: Image.asset(
                      'assets/images/facebook.png',
                      width: 40,
                      color: _primaryColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Fluttertoast.showToast(
                        msg: 'Signin with twitter',
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    },
                    child: Image.asset(
                      'assets/images/twitter.png',
                      width: 40,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 60),
            Center(
              child: GestureDetector(
                onTap: () {
                  Fluttertoast.showToast(
                    msg: 'Click signup',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                },
                child: Text(
                  'No account yet? Create one',
                  style: TextStyle(fontSize: 15, color: _primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
