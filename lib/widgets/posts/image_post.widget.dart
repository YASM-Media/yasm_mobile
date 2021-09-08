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
    return Container(
      child: Stack(
        children: [
          Image.file(
            this.imageFile,
          ),
          IconButton(
            onPressed: this.onDelete,
            icon: Icon(Icons.clear),
          ),
        ],
      ),
    );
  }
}
