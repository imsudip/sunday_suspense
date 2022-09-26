import 'package:debounce_throttle/debounce_throttle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loadmore/loadmore.dart';

import '../services/database_service.dart';
import '../ui/app_colors.dart';
import '../ui/text_styles.dart';
import '../widgets/song_viewers.dart';
import 'show_all_page.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  Duration debounceTime = const Duration(milliseconds: 300);
  String searchQuery = '';

  List<dynamic> searchResults = [];
  int page = 2;

  void submitSearch(String query) async {
    print("searching...");
    var results = await DatabaseService.getSongsUsingTag(query);
    setState(() {
      page = 2;
      searchResults = results;
    });
  }

  bool _hasMore = true;

  Future<bool> _loadMore() async {
    print("loading more");
    if (!_hasMore) return false;
    print(page);
    var songs = await DatabaseService.getSongsFromSearch(searchController.text, page: page);
    if (songs.length < 10) {
      _hasMore = false;
    }
    setState(() {
      searchResults.addAll(songs);
      page++;
    });
    return true;
  }

  final debouncer = Debouncer<String>(const Duration(milliseconds: 200), initialValue: '');

  @override
  void initState() {
    // Run a search whenever the user pauses while typing.
    searchController.addListener(() => debouncer.value = searchController.text);
    debouncer.values.listen((search) => submitSearch(search));
    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text(
          'Search',
          style: AppTextStyle.subHeading,
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 54,
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: CupertinoTextField(
              placeholder: 'Search',
              controller: searchController,
              style: AppTextStyle.bodytext1,
              placeholderStyle: AppTextStyle.bodytext1.copyWith(color: AppColors.textSecondaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              prefix: const Padding(
                padding: EdgeInsets.only(left: 20),
                child: Icon(
                  Iconsax.search_normal_1,
                  color: AppColors.textSecondaryColor,
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          Expanded(
            child: LoadMore(
              onLoadMore: _loadMore,
              whenEmptyLoad: false,
              isFinish: !_hasMore,
              delegate: MyLoadMoreDelegate(),
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  return MinimalVerticalListCard(songs: searchResults, index: index);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
