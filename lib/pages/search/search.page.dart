import 'package:flutter/material.dart';
import 'package:yasm_mobile/constants/post_fetch_type.constant.dart';
import 'package:yasm_mobile/constants/post_list_type.constant.dart';
import 'package:yasm_mobile/pages/search/search_results.page.dart';
import 'package:yasm_mobile/widgets/posts/post_list.widget.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  static const routeName = "/search-main";

  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(
                  SearchResults.routeName,
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.07,
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 20.0,
                ),
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    20.0,
                  ),
                  border: Border.all(
                    width: 2,
                    color: Colors.white24,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Search'),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Suggested Posts',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: MediaQuery.of(context).size.height * 0.03,
                ),
              ),
            ),
            PostList(
              postListType: PostListType.NORMAL,
              postFetchType: PostFetchType.SUGGESTED,
            ),
          ],
        ),
      ),
    );
  }
}
