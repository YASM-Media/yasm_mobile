import 'package:flutter/material.dart';
import 'package:yasm_mobile/combined_providers.dart';
import 'package:yasm_mobile/setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await combinedSetup();

  runApp(DevRoot());
}

class DevRoot extends StatefulWidget {
  @override
  _DevRootState createState() => _DevRootState();
}

class _DevRootState extends State<DevRoot> {
  @override
  Widget build(BuildContext context) {
    return CombinedProviders(
      apiUrl: "http://10.0.2.2:5000/v1/api",
      rawApiUrl: "10.0.2.2:5000",
    );
  }
}
