import 'package:cached_network_image/cached_network_image.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:octo_image/octo_image.dart';
import '../utils.dart';
import 'player_parts.dart';

import '../page_manager.dart';
import '../screens/player.dart';
import '../services/service_locator.dart';
import '../ui/app_colors.dart';
import '../ui/text_styles.dart';

class HorizontalListView extends StatelessWidget {
  const HorizontalListView({super.key, required this.songs});
  final List<dynamic> songs;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 268,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        itemBuilder: (c, index) {
          return GestureDetector(
              onTap: () async {
                final pageManager = getIt<PageManager>();

                pageManager.addOne(songs[index]).whenComplete(() {
                  Get.to(() => PlayerScreen());
                });
              },
              child: _card(songs, index, context));
        },
      ),
    );
  }
}

class VerticalListView extends StatelessWidget {
  const VerticalListView({super.key, required this.songs});
  final List<dynamic> songs;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: songs.length,
      itemBuilder: (context, index) {
        return VerticalListCard(
          songs: songs,
          index: index,
        );
      },
    );
  }
}

class VerticalListCard extends StatelessWidget {
  const VerticalListCard({
    Key? key,
    required this.songs,
    required this.index,
  }) : super(key: key);

  final List songs;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 295,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: GestureDetector(
          onTap: () async {
            final pageManager = getIt<PageManager>();

            pageManager.addOne(songs[index]).whenComplete(() {
              Get.to(() => PlayerScreen());
            });
          },
          child: _card(songs, index, context)),
    );
  }
}

void loadingDialog() {
  Get.dialog(
      Center(
        child: Container(
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            color: AppColors.accentColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
              child: Padding(
            padding: EdgeInsets.all(16.0),
            child: LoadingAnimation(),
          )),
        ),
      ),
      barrierDismissible: false);
}

Container _card(List<dynamic> songs, int index, BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.75,
    margin: const EdgeInsets.symmetric(horizontal: 6),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.accentColor,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: double.infinity,
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: OctoImage(
                        image: CachedNetworkImageProvider(songs[index]['thumbnail']),
                        placeholderBuilder: OctoPlaceholder.blurHash(
                          songs[index]['blurhash'],
                        ),
                        errorBuilder: OctoError.icon(color: Colors.red),
                        fit: BoxFit.fitWidth,
                        // height: 200,
                      )),
                ),
                const Positioned(
                    right: 10,
                    bottom: 10,
                    child: Icon(
                      EvaIcons.playCircle,
                      color: AppColors.primaryWhiteColor,
                      size: 38,
                    ))
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 12,
        ),
        Text(songs[index]['title'], maxLines: 2, style: AppTextStyle.subHeading),
        const SizedBox(
          height: 4,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '${showDate(songs[index]['date'])} ◽ ${calculateDuration(songs[index]['length'])}',
              style: AppTextStyle.bodytext2,
            ),
          ],
        ),
      ],
    ),
  );
}

class MinimalVerticalList extends StatefulWidget {
  const MinimalVerticalList({super.key, required this.songs, required this.onExtraScroll, required this.onFirstScroll});
  final List<dynamic> songs;
  final void Function() onExtraScroll, onFirstScroll;

  @override
  State<MinimalVerticalList> createState() => _MinimalVerticalListState();
}

class _MinimalVerticalListState extends State<MinimalVerticalList> {
  double posOnstart = 0;
  double posOnend = 0;
  final ScrollController _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          posOnstart = notification.metrics.pixels;
          if (posOnstart == 0) {
            widget.onFirstScroll();
          }
        }
        if (notification is ScrollEndNotification) {
          posOnend = notification.metrics.pixels;
          if (posOnstart == posOnend && posOnend == notification.metrics.minScrollExtent) {
            widget.onExtraScroll();
          }
        }
        return true;
      },
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: widget.songs.length,
        controller: _scrollController,
        itemBuilder: (context, index) {
          return MinimalVerticalListCard(
            songs: widget.songs,
            index: index,
            navigate: false,
          );
        },
      ),
    );
  }
}

class MinimalVerticalListCard extends StatelessWidget {
  const MinimalVerticalListCard(
      {Key? key, required this.songs, required this.index, this.history, this.navigate = true})
      : super(key: key);

  final List<dynamic> songs;
  final int index;
  final Duration? history;
  final bool navigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 76,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
          onTap: () async {
            final pageManager = getIt<PageManager>();

            pageManager.addOne(songs[index]).whenComplete(() {
              if (navigate) {
                Get.to(() => PlayerScreen());
              }
            });
          },
          child: _smallCard(songs, index, context, history)),
    );
  }
}

Widget _smallCard(List<dynamic> songs, int index, BuildContext context, Duration? history) {
  return Column(
    children: [
      Row(
        children: [
          SizedBox(
            width: 100,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: OctoImage(
                          image: CachedNetworkImageProvider(songs[index]['thumbnail']),
                          placeholderBuilder: OctoPlaceholder.blurHash(
                            songs[index]['blurhash'],
                          ),
                          errorBuilder: OctoError.icon(color: Colors.red),
                          fit: BoxFit.fitWidth,
                          // height: 200,
                        )),
                  ),
                  const Center(
                      child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.primaryWhiteColor,
                    size: 38,
                  ))
                ],
              ),
            ),
          ),
          const SizedBox(
            width: 14,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  songs[index]['title'],
                  maxLines: 2,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      '${showDate(songs[index]['date'])} ◽',
                      style: AppTextStyle.bodytext2,
                    ),
                    Text(
                      history != null ? "${calculateDuration(history.inSeconds)} ◽" : '',
                      style: AppTextStyle.bodytext2.copyWith(color: AppColors.primaryColor),
                    ),
                    Text(
                      ' ${calculateDuration(songs[index]['length'])}',
                      style: AppTextStyle.bodytext2,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      if (history != null)
        const SizedBox(
          height: 4,
        ),
      if (history != null)
        Container(
          height: 6,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: history.inSeconds / songs[index]['length'],
              backgroundColor: AppColors.accentColor,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          ),
        )
    ],
  );
}
