import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:yasm_mobile/constants/hive_names.constant.dart';
import 'package:yasm_mobile/models/image/image.model.dart' as ImageModel;
import 'package:yasm_mobile/models/like/like.model.dart';
import 'package:yasm_mobile/models/post/post.model.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/auth.service.dart';
import 'package:yasm_mobile/services/comment.service.dart';
import 'package:yasm_mobile/services/follow.service.dart';
import 'package:yasm_mobile/services/like.service.dart';
import 'package:yasm_mobile/services/post.service.dart';
import 'package:yasm_mobile/services/search.service.dart';
import 'package:yasm_mobile/services/user.service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();

  Hive.registerAdapter<User>(new UserAdapter());
  Hive.registerAdapter<Post>(new PostAdapter());
  Hive.registerAdapter<ImageModel.Image>(new ImageModel.ImageAdapter());
  Hive.registerAdapter<Like>(new LikeAdapter());

  await Hive.openBox<User>(YASM_USER_BOX);
  await Hive.openBox<List<dynamic>>(YASM_POSTS_BOX);
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
      ],
      child: App(),
    );
  }
}
