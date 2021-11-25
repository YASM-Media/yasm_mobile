import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yasm_mobile/constants/logger.constant.dart';
import 'package:yasm_mobile/models/user/user.model.dart';
import 'package:yasm_mobile/services/search.service.dart';
import 'package:yasm_mobile/widgets/user/user_list.widget.dart';

class UserSearch extends StatefulWidget {
  final String searchQuery;

  UserSearch({
    Key? key,
    required this.searchQuery,
  }) : super(key: key);

  @override
  _UserSearchState createState() => _UserSearchState();
}

class _UserSearchState extends State<UserSearch> {
  late final SearchService _searchService;
  late List<User> users;

  @override
  void initState() {
    super.initState();

    this._searchService = Provider.of<SearchService>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this._searchService.searchForUser(widget.searchQuery),
      builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
        if (snapshot.hasError) {
          log.e(snapshot.error, snapshot.error, snapshot.stackTrace);

          return Text('Something went wrong, please try again later');
        }

        if (snapshot.connectionState == ConnectionState.done) {
          this.users = snapshot.data!;

          return UserList(
            users: users,
          );
        }

        return Column(
          children: [
            CircularProgressIndicator(),
          ],
        );
      },
    );
  }
}
