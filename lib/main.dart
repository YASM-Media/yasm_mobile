import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yasm_mobile/constants/hive_names.constant.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/enum/activity_type.enum.dart';
import 'package:yasm_mobile/models/image/image.model.dart' as ImageModel;
import 'package:yasm_mobile/models/like/like.model.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/models/story/story.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/auth.service.dart';
import 'package:yasm_mobile/services/chat.service.dart';
import 'package:yasm_mobile/services/comment.service.dart';
import 'package:yasm_mobile/services/follow.service.dart';
import 'package:yasm_mobile/services/like.service.dart';
import 'package:yasm_mobile/services/post.service.dart';
import 'package:yasm_mobile/services/search.service.dart';
import 'package:yasm_mobile/services/stories.service.dart';
import 'package:yasm_mobile/services/tokens.service.dart';
import 'package:yasm_mobile/services/user.service.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();

  Hive.registerAdapter<User>(new UserAdapter());
  Hive.registerAdapter<Post>(new PostAdapter());
  Hive.registerAdapter<ImageModel.Image>(new ImageModel.ImageAdapter());
  Hive.registerAdapter<Like>(new LikeAdapter());
  Hive.registerAdapter<Story>(new StoryAdapter());
  Hive.registerAdapter<ActivityType>(new ActivityTypeAdapter());

  await Hive.openBox<User>(YASM_USER_BOX);
  await Hive.openBox<List<dynamic>>(YASM_POSTS_BOX);
  await Hive.openBox<List<dynamic>>(YASM_STORIES_BOX);

  await setupFCM();

  runApp(Root());
}

class Root extends StatefulWidget {
  @override
  _RootState createState() => _RootState();
}

class _RootState extends State<Root> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        Provider<AuthService>(
          create: (context) => AuthService(),
        ),
        Provider<UserService>(
          create: (context) => UserService(),
        ),
        Provider<PostService>(
          create: (context) => PostService(),
        ),
        Provider<FollowService>(
          create: (context) => FollowService(),
        ),
        Provider<LikeService>(
          create: (context) => LikeService(),
        ),
        Provider<CommentService>(
          create: (context) => CommentService(),
        ),
        Provider<SearchService>(
          create: (context) => SearchService(),
        ),
        Provider<StoriesService>(
          create: (context) => StoriesService(),
        ),
        Provider<ChatService>(
          create: (context) => ChatService(),
        ),
        Provider<TokensService>(
          create: (context) => TokensService(),
        ),
      ],
      child: App(),
    );
  }
}
