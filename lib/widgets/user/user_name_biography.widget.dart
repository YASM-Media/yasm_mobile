import 'package:flutter/material.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

class UserNameBiography extends StatelessWidget {
  final User user;

  UserNameBiography({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "${user.firstName} ${user.lastName}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
          ),
          Text(
            user.biography,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
