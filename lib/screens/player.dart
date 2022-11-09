import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:solid_bottom_sheet/solid_bottom_sheet.dart';
import '../services/database_service.dart';
import '../ui/my_theme.dart';
import '../ui/text_styles.dart';
import '../widgets/art_glass_overlay.dart';
import '../widgets/song_viewers.dart';

import '../page_manager.dart';
import '../services/service_locator.dart';
import '../ui/app_colors.dart';
import '../widgets/player_parts.dart';

class PlayerScreen extends StatelessWidget {
  PlayerScreen({super.key});

  final SolidController _solidController = SolidController();

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return WillPopScope(
      onWillPop: () async {
        if (_solidController.isOpened) {
          _solidController.hide();
          return false;
        }
        return true;
      },
      child: Theme(
        data: MyTheme.darkTheme
            .copyWith(bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent)),
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: ArtGlass(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  AppBar(
                    title: Text(
                      "Now Playing",
                      style: AppTextStyle.subHeading,
                    ),
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Iconsax.arrow_down_1),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                    actions: [
                      // quality button
                      ValueListenableBuilder<String>(
                          valueListenable: pageManager.audioQualityNotifier,
                          builder: (_, quality, __) {
                            return PopupMenuButton<String>(
                              onSelected: (value) {
                                pageManager.changeAudioQuality(pageManager.audioQualityStoreNotifier.value[value]!);
                                pageManager.setAudioQuality(value);
                              },
                              itemBuilder: (context) {
                                // audio quality stored in {quality:url} format
                                return List.generate(
                                        pageManager.audioQualityStoreNotifier.value.keys.length, (index) => index)
                                    .map((e) => PopupMenuItem(
                                          value: pageManager.audioQualityStoreNotifier.value.keys.elementAt(e),
                                          child: Text(pageManager.audioQualityStoreNotifier.value.keys.elementAt(e)),
                                        ))
                                    .toList();
                              },
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Iconsax.cd,
                                      color: AppColors.primaryColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(quality),
                                  ],
                                ),
                              ),
                            );
                          }),
                    ],
                  ),
                  const SizedBox(height: 80),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: const CurrentSongArt(
                          width: double.infinity,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Center(
                      child: CurrentSongTitle(
                    centered: true,
                  )),
                  Text("Mirchi Bangla", style: AppTextStyle.bodytext2),
                  const SizedBox(height: 40),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: AudioProgressBar(),
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: AudioControlButtons2(),
                  ),
                ],
              ),
            ),
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: SolidBottomSheet(
              minHeight: 180,
              controller: _solidController,
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              smoothness: Smoothness.high,
              // toggleVisibilityOnTap: true,
              headerBar: Container(
                height: 54,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.accentColor,
                      AppColors.backgroundColor,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primaryWhiteColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "More Like This",
                      style: AppTextStyle.subHeading,
                    ),
                  ],
                ),
              ),

              body: Container(
                color: AppColors.backgroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ValueListenableBuilder<String>(
                    valueListenable: pageManager.currentSongTitleNotifier,
                    builder: (_, title, __) {
                      if (title == '') {
                        return const SizedBox(
                          height: 200,
                          child: Center(
                            child: SizedBox(height: 50, child: LoadingAnimation()),
                          ),
                        );
                      }

                      return FutureBuilder(
                        future: DatabaseService.moreLikethis(title),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            List<dynamic> songs = snapshot.data!;
                            return MinimalVerticalList(
                              songs: songs,
                              onExtraScroll: () {
                                if (_solidController.isOpened) {
                                  print("pull down");
                                  _solidController.hide();
                                }
                              },
                              onFirstScroll: () {
                                if (!_solidController.isOpened) {
                                  _solidController.show();
                                }
                              },
                            );
                          } else {
                            return const SizedBox(
                              height: 200,
                              child: Center(
                                child: SizedBox(height: 50, child: LoadingAnimation()),
                              ),
                            );
                          }
                        },
                      );
                    }),
              ), // Your body here
            ),
          ),
        ),
      ),
    );
  }
}
