import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yasm_mobile/constants/hive_names.constant.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/enum/activity_type.enum.dart';
import 'package:yasm_mobile/models/activity/activity.model.dart';
import 'package:yasm_mobile/models/image/image.model.dart' as ImageModel;
import 'package:yasm_mobile/models/like/like.model.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/models/story/story.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';

/*
 * Set up FCM service for server sent notifications.
 */
Future<void> setupFCM() async {
  // Initializing Firebase Notification settings.
  NotificationSettings settings =
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Check for authorization status
  log.i("FCM Authorization Status: ${settings.authorizationStatus}");
}

Future<void> setupFirebaseHive() async {
  await Firebase.initializeApp();
  await Hive.initFlutter();
}

Future<void> setupHive() async {
  Hive.registerAdapter<User>(new UserAdapter());
  Hive.registerAdapter<Post>(new PostAdapter());
  Hive.registerAdapter<ImageModel.Image>(new ImageModel.ImageAdapter());
  Hive.registerAdapter<Like>(new LikeAdapter());
  Hive.registerAdapter<Story>(new StoryAdapter());
  Hive.registerAdapter<ActivityType>(new ActivityTypeAdapter());
  Hive.registerAdapter<Activity>(new ActivityAdapter());

  await Hive.openBox<User>(YASM_USER_BOX);
  await Hive.openBox<List<dynamic>>(YASM_POSTS_BOX);
  await Hive.openBox<List<dynamic>>(YASM_STORIES_BOX);
  await Hive.openBox<List<dynamic>>(YASM_ACTIVITY_BOX);
}

Future<void> combinedSetup() async {
  await setupFirebaseHive();
  await setupHive();
  await setupFCM();
}