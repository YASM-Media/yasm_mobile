import 'package:flutter/material.dart';
import 'package:yasm_mobile/combined_providers.dart';
import 'package:yasm_mobile/setup.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await combinedSetup();

  runApp(ProdRoot());
}

class ProdRoot extends StatefulWidget {
  @override
  _ProdRootState createState() => _ProdRootState();
}

class _ProdRootState extends State<ProdRoot> {
  @override
  Widget build(BuildContext context) {
    return CombinedProviders(
      apiUrl: "https://yasm-node-react.herokuapp.com/v1/api",
      rawApiUrl: "yasm-node-react.herokuapp.com",
    );
  }
}
