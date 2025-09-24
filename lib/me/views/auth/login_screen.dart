import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:e_Inspection_APP/me/routes/app_routes.dart';
import 'package:universal_io/io.dart';

// 🔽 importe ton controller
import 'package:e_Inspection_APP/me/controllers/user_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  IconData _iconVisible = Icons.visibility_off;

  final Color _backgroundColor = Colors.white;
  final Color _primaryColor = const Color(0xFFFF6A00);
  final Color _underlineColor = const Color(0xFFFF6A00);

  // 🔽 AJOUTS
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final UserController _userCtrl = UserController();
  bool _checking = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _toggleObscureText() {
    setState(() {
      _obscureText = !_obscureText;
      _iconVisible = _obscureText ? Icons.visibility_off : Icons.visibility;
    });
  }

  // 🔽 Fonction: vérifie si l'email existe dans la base locale
  Future<bool> _emailExists(String email) async {
    // Charge/rafraîchit la liste locale (SQLite)
    await _userCtrl.loadLocalOnly();

    final e = email.trim().toLowerCase();
    // Adapte les noms si besoin: _userCtrl.users / u.email
    return _userCtrl.users.any(
          (u) => (u.email ?? '').trim().toLowerCase() == e,
    );
  }

  // Récupère le mot de passe enlevé du prefix/suffix et de la fin numérique id*myCal
  String? extractPassword({
    required String refMetierCode,
    required String prefix,
    required String suffix,
    required int id,
    required int myCal,
  }) {
    final tail = (id * myCal).toString();
    if (!refMetierCode.endsWith(tail)) return null;

    final withoutTail = refMetierCode.substring(0, refMetierCode.length - tail.length);
    if (!withoutTail.startsWith(prefix)) return null;

    final afterPrefix = withoutTail.substring(prefix.length);
    if (!afterPrefix.endsWith(suffix)) return null;

    return afterPrefix.substring(0, afterPrefix.length - suffix.length);
  }

  // 🔽 Handler du bouton "CONNEXION"
  Future<void> _onConnexionPressed() async {
    if (_checking) return;

    final email = _emailCtrl.text.trim();
    final enteredPassword = _passCtrl.text.trim();
    // paramètres fixés comme côté PHP
    const prefix = '_ABC';
    const suffix = 'XYZ!_@';
    final myCal = 5 * 1000 + 36;


    if (email.isEmpty) {
      Fluttertoast.showToast(
        msg: "Veuillez saisir votre adresse e-mail.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
        fontSize: 15.0,
      );
      return;
    }





    setState(() => _checking = true);
    try {
      final user = await _userCtrl.findLocalByEmail(email);

      // 2. reconstituer le mot de passe depuis ref_metier_code
      final recovered = extractPassword(
        refMetierCode: user?.ref_metier_code ?? '',
        prefix: prefix,
        suffix: suffix,
        id: user?.id ?? 0,
        myCal: myCal,


      );

      //final recovered = null;




      // 3. comparer
      if (recovered == null || recovered != enteredPassword) {
        //print("je suis null");
        Fluttertoast.showToast(
          msg: "Email ou mot de passe invalide",//"'Email ou mot de passe invalide'.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
        return;
      }


      if (user == null) {
        Fluttertoast.showToast(
          msg: "Utilisateur introuvable (incohérence locale).",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.redAccent,
          textColor: Colors.white,
        );
        return;
      }

// 💾 Sauver la session (nom, email, id)
      await _userCtrl.persistCurrentUser(user);

// ✅ feedback + navigation
      Fluttertoast.showToast(
        msg: "Bienvenue ${user.name ?? ''}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      if (!mounted) return;
      Navigator.pushNamed(context, AppRoutes.sync);

    } catch (e) {
      Fluttertoast.showToast(
        msg: "Erreur lors de la vérification: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 15.0,
      );
    } finally {
      if (mounted) setState(() => _checking = false);
    }
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

            // 🔽 Ajout controller pour récupérer l'email
            TextField(
              controller: _emailCtrl,
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
              controller: _passCtrl,
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
                labelText: 'Mot de passe',
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
                'Mot de passe oublié?',
                style: TextStyle(color: _primaryColor, fontSize: 13),
                textAlign: TextAlign.right,
              ),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              style: ButtonStyle(
                // ⚠️ Remplace WidgetStateProperty par MaterialStateProperty
                backgroundColor: MaterialStateProperty.all(_primaryColor),
                overlayColor: MaterialStateProperty.all(Colors.transparent),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0),
                  ),
                ),
              ),
              onPressed: _checking ? null : _onConnexionPressed,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: _checking
                    ? const SizedBox(
                  height: 22, width: 22,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text(
                  'CONNEXION',
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 60),
            Center(
              child: GestureDetector(
                onTap: () {
                  Fluttertoast.showToast(
                    msg: "Adresse e-mail ou mot de passe incorrect.",
                    toastLength: Toast.LENGTH_LONG,
                    gravity: ToastGravity.TOP, // 👈 affichage en haut
                    backgroundColor: Colors.black87,
                    textColor: Colors.white,
                    fontSize: 15.0,
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
