import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import '../ui/app_colors.dart';

import '../notifiers/play_button_notifier.dart';
import '../notifiers/progress_notifier.dart';
import '../notifiers/repeat_button_notifier.dart';
import '../page_manager.dart';
import '../services/service_locator.dart';

class CurrentSongTitle extends StatelessWidget {
  const CurrentSongTitle({Key? key, this.textStyle = const TextStyle(fontSize: 18), this.centered = false})
      : super(key: key);
  final TextStyle textStyle;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<String>(
      valueListenable: pageManager.currentSongTitleNotifier,
      builder: (_, title, __) {
        return Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(
            title,
            style: textStyle,
            textAlign: centered ? TextAlign.center : TextAlign.start,
          ),
        );
      },
    );
  }
}

class CurrentSongArt extends StatelessWidget {
  const CurrentSongArt({Key? key, this.width = 80}) : super(key: key);
  final double width;
  final bool disableHero = false;
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<String>(
      valueListenable: pageManager.currentSongImageNotifier,
      builder: (_, art, __) {
        if (art == "") {
          return Container(
            color: AppColors.accentColor,
            child: const Center(
              child: Icon(
                Icons.music_note,
                color: AppColors.backgroundColor,
                size: 40,
              ),
            ),
          );
        }
        if (disableHero) {
          return Center(
            child: CachedNetworkImage(
              imageUrl: art,
              width: width,
              fit: BoxFit.cover,
            ),
          );
        } else {
          return Hero(
            tag: art,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: art,
                width: width,
                fit: BoxFit.cover,
              ),
            ),
          );
        }
      },
    );
  }
}

// class Playlist extends StatelessWidget {
//   const Playlist({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return Expanded(
//       child: ValueListenableBuilder<List<String>>(
//         valueListenable: pageManager.playlistNotifier,
//         builder: (context, playlistTitles, _) {
//           return ListView.builder(
//             itemCount: playlistTitles.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text('${playlistTitles[index]}'),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

// class AddRemoveSongButtons extends StatelessWidget {
//   const AddRemoveSongButtons({Key? key}) : super(key: key);
//   @override
//   Widget build(BuildContext context) {
//     final pageManager = getIt<PageManager>();
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 20.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           FloatingActionButton(
//             onPressed: pageManager.add,
//             child: const Icon(Icons.add),
//           ),
//           FloatingActionButton(
//             onPressed: pageManager.remove,
//             child: const Icon(Icons.remove),
//           ),
//         ],
//       ),
//     );
//   }
// }

class AudioProgressBar extends StatelessWidget {
  const AudioProgressBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: pageManager.seek,
          thumbColor: const Color.fromARGB(255, 194, 8, 14),
          progressBarColor: AppColors.primaryColor,
          baseBarColor: AppColors.accentColor,
          bufferedBarColor: AppColors.primaryColor.withOpacity(0.3),
          thumbRadius: 8,
          barHeight: 8,
        );
      },
    );
  }
}

class MinimalAudioProgressBar extends StatelessWidget {
  const MinimalAudioProgressBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ProgressBarState>(
      valueListenable: pageManager.progressNotifier,
      builder: (_, value, __) {
        return ProgressBar(
          progress: value.current,
          buffered: value.buffered,
          total: value.total,
          onSeek: pageManager.seek,
          thumbColor: AppColors.primaryColor,
          progressBarColor: AppColors.primaryColor,
          baseBarColor: AppColors.accentColor,
          bufferedBarColor: AppColors.primaryColor.withOpacity(0.3),
          timeLabelLocation: TimeLabelLocation.none,
          thumbRadius: 0,
          barCapShape: BarCapShape.round,
        );
      },
    );
  }
}

class AudioControlButtons extends StatelessWidget {
  const AudioControlButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          // RepeatButton(),

          SeekBack(),
          PlayButton(),
          // NextSongButton(),
          SeekForward(),
          // ShuffleButton(),
        ],
      ),
    );
  }
}

class AudioControlButtons2 extends StatelessWidget {
  const AudioControlButtons2({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        // RepeatButton(),

        const SeekBack(),
        Transform.scale(
          scale: 1.5,
          child: const PlayButton(),
        ),
        // NextSongButton(),
        const SeekForward(),
        // ShuffleButton(),
      ],
    );
  }
}

class RepeatButton extends StatelessWidget {
  const RepeatButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<RepeatState>(
      valueListenable: pageManager.repeatButtonNotifier,
      builder: (context, value, child) {
        Icon icon;
        switch (value) {
          case RepeatState.off:
            icon = const Icon(Icons.repeat, color: Colors.grey);
            break;
          case RepeatState.repeatSong:
            icon = const Icon(Icons.repeat_one);
            break;
          case RepeatState.repeatPlaylist:
            icon = const Icon(Icons.repeat);
            break;
        }
        return IconButton(
          icon: icon,
          onPressed: pageManager.repeat,
        );
      },
    );
  }
}

class PreviousSongButton extends StatelessWidget {
  const PreviousSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isFirstSongNotifier,
      builder: (_, isFirst, __) {
        return IconButton(
          icon: const Icon(Icons.skip_previous),
          onPressed: (isFirst) ? null : pageManager.previous,
        );
      },
    );
  }
}

class SeekBack extends StatelessWidget {
  const SeekBack({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return IconButton(
      icon: const Icon(Iconsax.backward_10_seconds),
      onPressed: pageManager.rewind,
    );
  }
}

class SeekForward extends StatelessWidget {
  const SeekForward({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return IconButton(
      icon: const Icon(Iconsax.forward_10_seconds),
      onPressed: pageManager.fastForward,
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<ButtonState>(
      valueListenable: pageManager.playButtonNotifier,
      builder: (_, value, __) {
        switch (value) {
          case ButtonState.loading:
            return Container(
              margin: const EdgeInsets.all(8.0),
              height: 44,
              child: const LoadingAnimation(),
            );
          case ButtonState.paused:
            return IconButton(
              icon: const Icon(Icons.play_arrow_rounded),
              iconSize: 44.0,
              onPressed: pageManager.play,
            );
          case ButtonState.playing:
            return IconButton(
              icon: const Icon(Icons.pause_rounded),
              iconSize: 44.0,
              onPressed: pageManager.pause,
            );
        }
      },
    );
  }
}

class NextSongButton extends StatelessWidget {
  const NextSongButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isLastSongNotifier,
      builder: (_, isLast, __) {
        return IconButton(
          icon: const Icon(Icons.skip_next),
          onPressed: (isLast) ? null : pageManager.next,
        );
      },
    );
  }
}

class ShuffleButton extends StatelessWidget {
  const ShuffleButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final pageManager = getIt<PageManager>();
    return ValueListenableBuilder<bool>(
      valueListenable: pageManager.isShuffleModeEnabledNotifier,
      builder: (context, isEnabled, child) {
        return IconButton(
          icon: (isEnabled) ? const Icon(Icons.shuffle) : const Icon(Icons.shuffle, color: Colors.grey),
          onPressed: pageManager.shuffle,
        );
      },
    );
  }
}

class LoadingAnimation extends StatelessWidget {
  const LoadingAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 2.5,
      child: LottieBuilder.asset(
        'assets/lottie/loading.json',
        repeat: true,
        fit: BoxFit.contain,
      ),
    );
  }
}
