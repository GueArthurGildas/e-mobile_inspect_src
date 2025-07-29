// lib/pages/users_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_app_divkit/me/views/users/user_form.dart';
import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserController()..loadUsers(),
      child: Scaffold(
        appBar: AppBar(title: Text('Utilisateurs')),
        body: Consumer<UserController>(
          builder: (context, ctrl, _) {
            if (ctrl.isLoading) return Center(child: CircularProgressIndicator());
            if (ctrl.users.isEmpty) return Center(child: Text('Aucun utilisateur'));
            return ListView.builder(
              itemCount: ctrl.users.length,
              itemBuilder: (context, i) {
                final user = ctrl.users[i];
                return ListTile(
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UserFormPage(user: user),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => ctrl.deleteUser(user.id),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => UserFormPage()),
          ),
        ),
      ),
    );
  }
}