import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/app.dart';
import 'package:yasm_mobile/providers/auth/auth.provider.dart';
import 'package:yasm_mobile/services/activity.service.dart';
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

class CombinedProviders extends StatelessWidget {
  final String apiUrl;
  final String rawApiUrl;

  const CombinedProviders({
    Key? key,
    required this.apiUrl,
    required this.rawApiUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(),
        ),
        Provider<AuthService>(
          create: (context) => AuthService(
            apiUrl: this.apiUrl,
            rawApiUrl: this.rawApiUrl,
          ),
        ),
        Provider<UserService>(
          create: (context) => UserService(
            apiUrl: this.apiUrl,
            rawApiUrl: this.rawApiUrl,
          ),
        ),
        Provider<PostService>(
          create: (context) => PostService(
            apiUrl: this.apiUrl,
            rawApiUrl: this.rawApiUrl,
          ),
        ),
        Provider<FollowService>(
          create: (context) => FollowService(
            apiUrl: this.apiUrl,
            rawApiUrl: this.rawApiUrl,
          ),
        ),
        Provider<LikeService>(
          create: (context) => LikeService(
            apiUrl: this.apiUrl,
            rawApiUrl: this.rawApiUrl,
          ),
        ),
        Provider<CommentService>(
          create: (context) => CommentService(
            apiUrl: this.apiUrl,
            rawApiUrl: this.rawApiUrl,
          ),
        ),
        Provider<SearchService>(
          create: (context) => SearchService(
            apiUrl: this.apiUrl,
            rawApiUrl: this.rawApiUrl,
          ),
        ),
        Provider<StoriesService>(
          create: (context) => StoriesService(
            apiUrl: this.apiUrl,
            rawApiUrl: this.rawApiUrl,
          ),
        ),
        Provider<ChatService>(
          create: (context) => ChatService(
            apiUrl: this.apiUrl,
            rawApiUrl: this.rawApiUrl,
          ),
        ),
        Provider<TokensService>(
          create: (context) => TokensService(),
        ),
        Provider<ActivityService>(
          create: (context) => ActivityService(
            apiUrl: this.apiUrl,
            rawApiUrl: this.rawApiUrl,
          ),
        ),
      ],
      child: App(),
    );
  }
}
