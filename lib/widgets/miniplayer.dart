import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../ui/text_styles.dart';
import 'player_parts.dart';

import '../page_manager.dart';
import '../screens/player.dart';
import '../services/service_locator.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<String>(
      valueListenable: pageManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        // print('title: $title');
        if (title == '') {
          return Container(
            height: 0,
          );
        } else {
          return GestureDetector(
            onTap: () {
              Get.to(() => PlayerScreen());
            },
            onVerticalDragStart: (details) {
              Get.to(() => PlayerScreen());
            },
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: SizedBox(
                  height: 68,
                  // color: AppColors.accentColor,
                  child: Column(
                    children: [
                      const SizedBox(height: 2),
                      const MinimalAudioProgressBar(),
                      // const SizedBox(height: 10),
                      Expanded(
                          child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16,
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(height: 60, child: const CurrentSongArt(width: 60)),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                              child: Text(
                            title,
                            style: AppTextStyle.bodytext1.copyWith(fontSize: 14),
                            maxLines: 2,
                          )),
                          const SizedBox(
                            width: 10,
                          ),
                          const AudioControlButtons(),
                          const SizedBox(
                            width: 16,
                          ),
                        ],
                      )),
                      // const SizedBox(height: 10),
                    ],
                  )),
            ),
          );
        }
      },
    );
  }
}
