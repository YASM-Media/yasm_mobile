import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/pages/auth/auth.page.dart';
import 'package:yasm_mobile/pages/user/user_update.page.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/auth.service.dart';

class Home extends StatelessWidget {
  static const routeName = "/home";

  Home({Key? key}) : super(key: key);

  final AuthService _authService = AuthService();

  Future<void> logout(context) async {
    await _authService.logout();
    Provider.of<AuthProvider>(context, listen: false).removeUser();
    Navigator.of(context).pushReplacementNamed(Auth.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('YASM!!🌟'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer<AuthProvider>(
              builder: (context, auth, _) => Text(auth.getUser() != null
                  ? auth.getUser()!.emailAddress
                  : "You are not logged in."),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushNamed(UserUpdate.routeName);
              },
              child: Text('User Update'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
    );
  }
}
