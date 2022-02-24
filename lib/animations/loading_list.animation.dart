import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingList extends StatelessWidget {
  const LoadingList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/json/loading_list.json',
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.5,
      repeat: true,
      animate: true,
    );
  }
}
