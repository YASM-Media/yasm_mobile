import 'package:yasm_mobile/models/user/user.model.dart';

class StoryArgument {
  final List<User> stories;
  final int index;

  StoryArgument({
    required this.stories,
    required this.index,
  });
}
