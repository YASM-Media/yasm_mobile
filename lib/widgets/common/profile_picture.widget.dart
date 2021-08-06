import 'package:flutter/material.dart';

class ProfilePicture extends StatelessWidget {
  final String imageUrl;
  final double size;

  ProfilePicture({Key? key, required this.imageUrl, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: imageUrl.length == 0
          ? Icon(
              Icons.person,
              size: size / 2,
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(100.0),
              child: Image.network(
                imageUrl,
                height: size,
                width: size,
              ),
            ),
      radius: size / 2,
    );
  }
}
