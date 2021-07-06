import 'package:flutter/material.dart';
import 'package:yasm_mobile/pages/auth/auth.page.dart';
import 'package:yasm_mobile/services/auth.service.dart';

class Home extends StatelessWidget {
  static const routeName = "/home";

  Home({Key? key}) : super(key: key);

  final AuthService _authService = AuthService();

  Future<void> logout(context) async {
    await _authService.logout();
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
            Text('Welcome to YASM!!🌟'),
            TextButton(
              onPressed: () async {
                this.logout(context);
              },
              child: Text('Logout'),
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
