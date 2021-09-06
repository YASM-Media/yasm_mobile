import 'dart:io';

import 'package:flutter/material.dart';

class ImagePost extends StatelessWidget {
  final File imageFile;
  final VoidCallback onDelete;

  const ImagePost({
    Key? key,
    required this.imageFile,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Column(
        children: [
          Image.file(
            this.imageFile,
          ),
          Container(
            margin: EdgeInsets.all(30.0),
            child: TextButton(
              child: Text(
                'Remove',
                style: TextStyle(
                  fontSize: 70.0,
                ),
              ),
              onPressed: this.onDelete,
            ),
          )
        ],
      ),
    );
  }
}
