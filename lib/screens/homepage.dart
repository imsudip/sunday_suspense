import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/database_service.dart';
import 'searchScreen.dart';
import 'show_all_page.dart';
import '../ui/app_colors.dart';
import '../ui/text_styles.dart';
import '../widgets/art_glass_overlay.dart';
import '../widgets/song_viewers.dart';
import '../widgets/player_parts.dart';
import '../widgets/searchbar.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Audio Service Demo'),
      // ),
      backgroundColor: AppColors.backgroundColor,
      body: ArtGlass(
        intensity: 0.8,
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(
                    height: 52,
                  ),
                  Image.asset(
                    'assets/logo.png',
                    height: 80,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                      onTap: () {
                        Get.to(() => const SearchScreen());
                      },
                      child: AbsorbPointer(child: const SearchBar())),
                  const TrendingBar(),
                  const CategoryBar(title: "🎩 Sherlock Holmes", tag: "sherlock"),
                  const CategoryBar(title: "🚬 Feluda", tag: "feluda"),
                  const CategoryBar(title: "👓 Byomkesh Bakshi", tag: "byomkesh"),
                ],
              ),
            ),
            // add a gradient to the bottom of the page
            // Positioned(
            //   bottom: 0,
            //   child: IgnorePointer(
            //     child: Container(
            //       height: 50,
            //       width: MediaQuery.of(context).size.width,
            //       decoration: const BoxDecoration(
            //         gradient: LinearGradient(
            //           begin: Alignment.topCenter,
            //           end: Alignment.bottomCenter,
            //           colors: [
            //             Colors.transparent,
            //             AppColors.backgroundColor,
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class TrendingBar extends StatelessWidget {
  const TrendingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(' 🔥 Trending', style: AppTextStyle.headline2),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Get.to(() => ShowAllPage(
                      title: "Trending",
                      future: (page) {
                        return DatabaseService.getTrending(page: page);
                      }));
                },
                child: Text(
                  'See All',
                  style: AppTextStyle.headline3,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          FutureBuilder(
              future: DatabaseService.getTrending(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<dynamic> songs = snapshot.data!;
                  return HorizontalListView(songs: songs);
                } else {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: SizedBox(height: 50, child: LoadingAnimation()),
                    ),
                  );
                }
              }),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}

class CategoryBar extends StatelessWidget {
  const CategoryBar({super.key, required this.title, required this.tag});
  final String title, tag;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(' $title', style: AppTextStyle.headline2),
              const Spacer(),
              TextButton(
                onPressed: () {
                  Get.to(() => ShowAllPage(
                      title: title,
                      future: (page) {
                        return DatabaseService.searchAudio(tag, page: page);
                      }));
                },
                child: Text(
                  'See All',
                  style: AppTextStyle.headline3,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          FutureBuilder(
              future: DatabaseService.searchAudio(tag),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<Map<String, dynamic>> songs = snapshot.data!;
                  return HorizontalListView(songs: songs);
                } else {
                  return const SizedBox(
                    height: 200,
                    child: Center(
                      child: SizedBox(height: 50, child: LoadingAnimation()),
                    ),
                  );
                }
              }),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }
}
