import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/app.dart';
import 'package:yasm_mobile/pages/common/loading.page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/auth.service.dart';
import 'package:yasm_mobile/services/follow.service.dart';
import 'package:yasm_mobile/services/post.service.dart';
import 'package:yasm_mobile/services/user.service.dart';

void main() {
  runApp(Root());
}

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error);
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>(
                create: (context) => AuthProvider(),
              ),
              Provider<AuthService>(
                create: (context) => AuthService(),
              ),
              Provider<UserService>(
                create: (context) => UserService(),
              ),
              Provider<PostService>(
                create: (context) => PostService(),
              ),
              Provider<FollowService>(
                create: (context) => FollowService(),
              ),
            ],
            child: App(),
          );
        }

        return Loading();
      },
    );
  }
}
