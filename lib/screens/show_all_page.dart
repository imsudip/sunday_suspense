import 'package:animated_icon_button/animated_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:loadmore/loadmore.dart';
import '../ui/app_colors.dart';
import '../widgets/player_parts.dart';
import '../widgets/song_viewers.dart';

class ShowAllPage extends StatefulWidget {
  const ShowAllPage({super.key, required this.title, required this.future});
  final String title;
  // future func
  final Future<dynamic> Function(int page) future;

  @override
  State<ShowAllPage> createState() => _ShowAllPageState();
}

class _ShowAllPageState extends State<ShowAllPage> {
  final List<dynamic> _songs = [];
  int _page = 1;
  bool _hasMore = true;

  bool isExpanded = true;

  Future<bool> _loadMore() async {
    print("loading more");
    if (!_hasMore) return false;
    var songs = await widget.future(_page);
    if (songs.length < 10) {
      _hasMore = false;
    }
    setState(() {
      _songs.addAll(songs);
      _page++;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        actions: [
          AnimatedIconButton(
            onPressed: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            icons: const [
              AnimatedIconItem(
                icon: Icon(Icons.unfold_less_rounded),
              ),
              AnimatedIconItem(
                icon: Icon(Icons.unfold_more_rounded),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: AppColors.backgroundColor,
      body: LoadMore(
        onLoadMore: _loadMore,
        whenEmptyLoad: true,
        isFinish: !_hasMore,
        delegate: MyLoadMoreDelegate(),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          itemCount: _songs.length,
          itemBuilder: (context, index) {
            if (isExpanded) {
              return VerticalListCard(
                songs: _songs,
                index: index,
              );
            } else {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: MinimalVerticalListCard(songs: _songs, index: index),
              );
            }
          },
        ),
      ),
    );
  }
}

class MyLoadMoreDelegate extends LoadMoreDelegate {
  @override
  Widget buildChild(LoadMoreStatus status, {LoadMoreTextBuilder builder = DefaultLoadMoreTextBuilder.english}) {
    switch (status) {
      case LoadMoreStatus.loading:
        return const Center(
          child: LoadingAnimation(),
        );
      case LoadMoreStatus.nomore:
        return const Center(
          child: Text('No more'),
        );

      case LoadMoreStatus.idle:
        return const Center(
          child: Text('Idle'),
        );
      default:
        return const Center(
          child: Text('Default'),
        );
    }
  }
}
