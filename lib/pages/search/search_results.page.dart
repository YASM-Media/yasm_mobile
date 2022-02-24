import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_offline/flutter_offline.dart';
import 'package:yasm_mobile/animations/offline.animation.dart';
import 'package:yasm_mobile/constants/post_list_type.constant.dart';
import 'package:yasm_mobile/widgets/posts/post_list.widget.dart';
import 'package:yasm_mobile/widgets/search/user_search.widget.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({Key? key}) : super(key: key);

  static const routeName = "/search-results";

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();

    this._tabController = new TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          MediaQuery.of(context).size.height * 0.15,
        ),
        child: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height * 0.2,
          automaticallyImplyLeading: false,
          title: CupertinoSearchTextField(
            style: TextStyle(color: Colors.white),
            onChanged: (String text) {
              setState(() {
                this._searchQuery = text;
              });
            },
          ),
          bottom: TabBar(
            controller: this._tabController,
            indicatorColor: Colors.pink,
            tabs: [
              Tab(
                child: Text(
                  'Users',
                  textAlign: TextAlign.center,
                ),
              ),
              Tab(
                child: Text(
                  'Posts',
                  textAlign: TextAlign.center,
                ),
              )
            ],
          ),
        ),
      ),
      body: OfflineBuilder(
        connectivityBuilder: (
          BuildContext context,
          ConnectivityResult connectivity,
          Widget _,
        ) {
          final bool connected = connectivity != ConnectivityResult.none;

          return connected
              ? TabBarView(
                  controller: this._tabController,
                  children: [
                    SingleChildScrollView(
                      child: UserSearch(
                        searchQuery: this._searchQuery,
                      ),
                    ),
                    SingleChildScrollView(
                      child: PostList(
                        postListType: PostListType.SEARCH,
                        searchQuery: this._searchQuery,
                      ),
                    ),
                  ],
                )
              : TabBarView(
                  controller: this._tabController,
                  children: [
                    Offline(message: 'You are offline'),
                    Offline(message: 'You are offline'),
                  ],
                );
        },
        child: SizedBox(),
      ),
    );
  }
}
