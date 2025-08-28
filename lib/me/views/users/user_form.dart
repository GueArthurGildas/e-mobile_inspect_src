// // lib/pages/user_form_page.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:test_app_divkit/me/controllers/user_controller.dart';
// import 'package:test_app_divkit/me/models/user_model.dart';
//
// class UserFormPage extends StatefulWidget {
//   final User? user;
//   const UserFormPage({Key? key, this.user}) : super(key: key);
//
//   @override
//   _UserFormPageState createState() => _UserFormPageState();
// }
//
// class _UserFormPageState extends State<UserFormPage> {
//   final _formKey = GlobalKey<FormState>();
//   late String _name;
//   late String _email;
//
//   @override
//   void initState() {
//     super.initState();
//     _name = widget.user?.name ?? '';
//     _email = widget.user?.email ?? '';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isEditing = widget.user != null;
//     final ctrl = Provider.of<UserController>(context, listen: false);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(isEditing ? 'Modifier Utilisateur' : 'Ajouter Utilisateur'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 initialValue: _name,
//                 decoration: InputDecoration(labelText: 'Nom'),
//                 onSaved: (v) => _name = v ?? '',
//                 validator: (v) => v!.isEmpty ? 'Veuillez saisir un nom' : null,
//               ),
//               TextFormField(
//                 initialValue: _email,
//                 decoration: InputDecoration(labelText: 'Email'),
//                 onSaved: (v) => _email = v ?? '',
//                 validator: (v) =>
//                     v!.isEmpty ? 'Veuillez saisir un email' : null,
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 child: Text(isEditing ? 'Enregistrer' : 'Ajouter'),
//                 onPressed: () async {
//                   if (!_formKey.currentState!.validate()) return;
//                   _formKey.currentState!.save();
//                   final user = User(
//                     id: widget.user?.id ?? 0,
//                     name: _name,
//                     email: _email,
//                   );
//                   if (isEditing) {
//                     await ctrl.updateUser(user);
//                   } else {
//                     await ctrl.addUser(user);
//                   }
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
