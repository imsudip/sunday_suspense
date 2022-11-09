import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'services/database_service.dart';
import 'ui/app_colors.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';

class PageManager {
  // Listeners: Updates going to the UI
  final currentSongTitleNotifier = ValueNotifier<String>('');
  final currentSongImageNotifier = ValueNotifier<String>('');
  final currentSongIdNotifier = ValueNotifier<String>('');
  final playlistNotifier = ValueNotifier<List<String>>([]);
  final progressNotifier = ProgressNotifier();
  final repeatButtonNotifier = RepeatButtonNotifier();
  final isFirstSongNotifier = ValueNotifier<bool>(true);
  final playButtonNotifier = PlayButtonNotifier();
  final isLastSongNotifier = ValueNotifier<bool>(true);
  final isShuffleModeEnabledNotifier = ValueNotifier<bool>(false);
  final audioQualityNotifier = ValueNotifier<String>('');
  final audioQualityStoreNotifier = ValueNotifier<Map<String, String>>({}); // Map<quality, url>
  final mediaItemNotifier = ValueNotifier<MediaItem?>(null);
  // final _audioHandler = getIt<AudioHandler>();
  late AudioPlayer audioPlayer;

  final box = GetStorage("HistoryBox");
  final prefs = GetStorage("prefs");

  // Events: Calls coming from the UI
  void init() async {
    await initiateBackgroundAudio();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
    audioQualityNotifier.value = prefs.read("audioQuality") ?? "high";
  }

  Future initiateBackgroundAudio() async {
    await JustAudioBackground.init(
      androidNotificationChannelId: 'com.example.sunday_suspense.channel.audio',
      androidNotificationChannelName: 'Audio playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    );
    audioPlayer = AudioPlayer();
  }

  void _listenToPlaybackState() {
    audioPlayer.playerStateStream.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering ||
          processingState == ProcessingState.idle) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        audioPlayer.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    audioPlayer.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      int seconds = position.inSeconds;

      if (seconds % 5 == 0 && seconds != oldState.current.inSeconds) {
        log("saving history...");
        box.write(currentSongIdNotifier.value, seconds);
      }
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
  }

  void _listenToBufferedPosition() {
    audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    audioPlayer.durationStream.listen((duration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    mediaItemNotifier.addListener(() {
      currentSongTitleNotifier.value = mediaItemNotifier.value?.title ?? '';
      currentSongImageNotifier.value = mediaItemNotifier.value?.artUri.toString() ?? '';
      currentSongIdNotifier.value = mediaItemNotifier.value?.id ?? '';
    });
  }

  Future<void> seek(Duration position) async {
    await audioPlayer.seek(position);
  }

  Future<void> addOne(dynamic audio) async {
    var streamUrl = await DatabaseService.getStreamLink(audio['url']);
    if (streamUrl == "") {
      Get.back();
      Get.snackbar("Error", "There is a problem with this song. Please try another one.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.accentColor,
          colorText: AppColors.primaryWhiteColor);
      return;
    }
    final mediaItem = MediaItem(
      id: audio['video_id'] ?? '',
      album: 'sunday suspense',
      title: audio['title'] ?? '',
      artUri: Uri.parse(audio['thumbnail']),
      extras: {'url': streamUrl},
    );

    mediaItemNotifier.value = mediaItem;
    AudioSource audioSource = LockCachingAudioSource(
      Uri.parse(streamUrl),
      tag: mediaItem,
    );
    Get.back();
    Duration initialPosition = Duration(seconds: box.read(audio['video_id'] ?? '') ?? 0);
    audioPlayer.setAudioSource(audioSource, initialPosition: initialPosition).whenComplete(() {
      audioPlayer.play();
    });
  }

  Future<void> setAudioQuality(String quality) async {
    audioQualityNotifier.value = quality;
    prefs.write("audioQuality", quality);
  }

  Future<void> changeAudioQuality(String url) async {
    final oldMediaItem = mediaItemNotifier.value;
    if (oldMediaItem == null) return;
    final mediaItem = MediaItem(
      id: oldMediaItem.id,
      album: oldMediaItem.album,
      title: oldMediaItem.title,
      artUri: oldMediaItem.artUri,
      extras: {'url': url},
    );
    mediaItemNotifier.value = mediaItem;
    AudioSource audioSource = LockCachingAudioSource(
      Uri.parse(url),
      tag: mediaItem,
    );
    await audioPlayer.pause();
    var currentDuration = audioPlayer.position;
    await audioPlayer.setAudioSource(audioSource, initialPosition: currentDuration);
    await audioPlayer.play();
  }

  void dispose() {
    audioPlayer.dispose();
  }

  void stop() {
    audioPlayer.stop();
  }

  void pause() {
    audioPlayer.pause();
  }

  void play() {
    audioPlayer.play();
  }

  void fastForward() {
    audioPlayer.seek(audioPlayer.position + const Duration(seconds: 10));
  }

  void rewind() {
    audioPlayer.seek(audioPlayer.position - const Duration(seconds: 10));
  }
}
