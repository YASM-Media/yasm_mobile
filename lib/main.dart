import 'package:flutter/material.dart';
import 'package:yasm_mobile/pages/home.page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
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
          return MaterialApp(
            title: 'YASM!!🌟',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: Colors.pink[500],
            ),
            home: Home(),
          );
        }

        return CircularProgressIndicator();
      },
    );
  }
}
