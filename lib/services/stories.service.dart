import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart' as FA;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

class StoriesService {
  final FA.FirebaseAuth _firebaseAuth = FA.FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final Uuid uuid = new Uuid();

  Future<String> uploadStoryAndGenerateUrl(
    Uint8List storyData,
  ) async {
    String imageUuid = uuid.v4();

    await this
        ._firebaseStorage
        .ref("stories/$imageUuid.jpg")
        .putData(storyData);

    return await this
        ._firebaseStorage
        .ref("stories/$imageUuid.png")
        .getDownloadURL();
  }
}
