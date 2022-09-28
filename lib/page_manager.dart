import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'services/database_service.dart';
import 'ui/app_colors.dart';
import 'notifiers/play_button_notifier.dart';
import 'notifiers/progress_notifier.dart';
import 'notifiers/repeat_button_notifier.dart';
import 'package:audio_service/audio_service.dart';
import 'services/service_locator.dart';

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

  final _audioHandler = getIt<AudioHandler>();

  final box = GetStorage("HistoryBox");
  final prefs = GetStorage("prefs");

  // Events: Calls coming from the UI
  void init() async {
    // await _loadPlaylist();
    _listenToChangesInPlaylist();
    _listenToPlaybackState();
    _listenToCurrentPosition();
    _listenToBufferedPosition();
    _listenToTotalDuration();
    _listenToChangesInSong();
    audioQualityNotifier.value = prefs.read("audioQuality") ?? "high";
  }

  void _listenToChangesInPlaylist() {
    _audioHandler.queue.listen((playlist) {
      if (playlist.isEmpty) {
        playlistNotifier.value = [];
        currentSongTitleNotifier.value = '';
        currentSongImageNotifier.value = '';
        currentSongIdNotifier.value = '';
      } else {
        final newList = playlist.map((item) => item.title).toList();
        playlistNotifier.value = newList;
      }
      _updateSkipButtons();
    });
  }

  void _listenToPlaybackState() {
    _audioHandler.playbackState.listen((playbackState) {
      final isPlaying = playbackState.playing;
      final processingState = playbackState.processingState;
      if (processingState == AudioProcessingState.loading || processingState == AudioProcessingState.buffering) {
        playButtonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        playButtonNotifier.value = ButtonState.paused;
      } else if (processingState != AudioProcessingState.completed) {
        playButtonNotifier.value = ButtonState.playing;
      } else {
        _audioHandler.seek(Duration.zero);
        _audioHandler.pause();
      }
    });
  }

  void _listenToCurrentPosition() {
    AudioService.position.listen((position) {
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
    _audioHandler.playbackState.listen((playbackState) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: playbackState.bufferedPosition,
        total: oldState.total,
      );
    });
  }

  void _listenToTotalDuration() {
    _audioHandler.mediaItem.listen((mediaItem) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: mediaItem?.duration ?? Duration.zero,
      );
    });
  }

  void _listenToChangesInSong() {
    _audioHandler.mediaItem.listen((mediaItem) {
      currentSongTitleNotifier.value = mediaItem?.title ?? '';
      currentSongImageNotifier.value = mediaItem?.artUri.toString() ?? '';
      currentSongIdNotifier.value = mediaItem?.id ?? '';
    });
  }

  void _updateSkipButtons() {
    final mediaItem = _audioHandler.mediaItem.value;
    final playlist = _audioHandler.queue.value;
    if (playlist.length < 2 || mediaItem == null) {
      isFirstSongNotifier.value = true;
      isLastSongNotifier.value = true;
    } else {
      isFirstSongNotifier.value = playlist.first == mediaItem;
      isLastSongNotifier.value = playlist.last == mediaItem;
    }
  }

  void play() => _audioHandler.play();
  void pause() => _audioHandler.pause();

  void seek(Duration position) {
    _audioHandler.seek(position).whenComplete(() {});
  }

  void previous() => _audioHandler.skipToPrevious();
  void next() => _audioHandler.skipToNext();

  void repeat() {
    repeatButtonNotifier.nextState();
    final repeatMode = repeatButtonNotifier.value;
    switch (repeatMode) {
      case RepeatState.off:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.none);
        break;
      case RepeatState.repeatSong:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case RepeatState.repeatPlaylist:
        _audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  void shuffle() {
    final enable = !isShuffleModeEnabledNotifier.value;
    isShuffleModeEnabledNotifier.value = enable;
    if (enable) {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
    } else {
      _audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
    }
  }

  // Future<void> add() async {
  //   final songRepository = getIt<PlaylistRepository>();
  //   final song = await songRepository.fetchAnotherSong();
  //   final mediaItem = MediaItem(
  //     id: song['id'] ?? '',
  //     album: song['album'] ?? '',
  //     title: song['title'] ?? '',
  //     extras: {'url': song['url']},
  //   );
  //   _audioHandler.addQueueItem(mediaItem);
  // }

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
    await remove();
    await _audioHandler.addQueueItem(mediaItem);
    await _audioHandler.play();

    Get.back();
    Future.delayed(const Duration(seconds: 1), () {
      _audioHandler.play();
      if (box.read(audio['video_id']) != null) {
        log("seeking to ${box.read(audio['video_id'])}");
        _audioHandler.seek(Duration(seconds: box.read(audio['video_id'])));
      } else {
        log("seeking to 0");
        _audioHandler.seek(const Duration(seconds: 0));
      }
    });

    // _audioHandler.skipToQueueItem(index)
  }

  Future<void> changeAudioQuality(String url) async {
    var oldMediaItem = _audioHandler.mediaItem.value!;
    final newMediaItem = MediaItem(
      id: oldMediaItem.id,
      album: oldMediaItem.album,
      title: oldMediaItem.title,
      artUri: oldMediaItem.artUri,
      extras: {'url': url},
    );
    await remove();
    await _audioHandler.addQueueItem(newMediaItem);
    await _audioHandler.play();
    Future.delayed(const Duration(seconds: 1), () {
      _audioHandler.play();
      if (box.read(oldMediaItem.id) != null) {
        log("seeking to ${box.read(oldMediaItem.id)}");
        _audioHandler.seek(Duration(seconds: box.read(oldMediaItem.id)));
      } else {
        log("seeking to 0");
        _audioHandler.seek(const Duration(seconds: 0));
      }
    });
  }

  Future<void> setAudioQuality(String quality) async {
    audioQualityNotifier.value = quality;
    prefs.write("audioQuality", quality);
  }

  Future<void> rewind() => _audioHandler.rewind();

  Future<void> fastForward() => _audioHandler.fastForward();

  Future<void> remove() async {
    final lastIndex = _audioHandler.queue.value.length - 1;
    if (lastIndex < 0) return;
    await _audioHandler.removeQueueItemAt(lastIndex);
  }

  void dispose() {
    _audioHandler.customAction('dispose');
  }

  void stop() {
    _audioHandler.stop();
  }
}
