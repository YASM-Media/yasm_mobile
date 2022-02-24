import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class DataNotFound extends StatelessWidget {
  final String message;

  const DataNotFound({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/json/data_not_found.json',
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.5,
            repeat: true,
            animate: true,
            frameRate: FrameRate.max,
          ),
          Text(
            this.message,
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.03,
            ),
          ),
        ],
      ),
    );
  }
}
