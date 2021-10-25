import 'package:flutter/material.dart';
import 'package:yasm_mobile/constants/post_list_type.constant.dart';
import 'package:yasm_mobile/widgets/common/custom_field.widget.dart';
import 'package:yasm_mobile/widgets/posts/post_list.widget.dart';
import 'package:yasm_mobile/widgets/search/user_search.widget.dart';

class SearchResults extends StatefulWidget {
  const SearchResults({Key? key}) : super(key: key);

  static const routeName = "/search-results";

  @override
  _SearchResultsState createState() => _SearchResultsState();
}

class _SearchResultsState extends State<SearchResults> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(),
                  ),
                ),
                onChanged: (String text) {
                  setState(() {
                    this._searchQuery = text;
                  });
                },
              ),
            ),
            // PostList(
            //   postListType: PostListType.SEARCH,
            //   searchQuery: this._searchQuery,
            // ),
            UserSearch(
              searchQuery: this._searchQuery,
            ),
          ],
        ),
      ),
    );
  }
}
