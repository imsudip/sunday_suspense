import 'dart:convert';
import 'dart:developer';

import 'package:meilisearch/meilisearch.dart';

import '../page_manager.dart';
import '../widgets/song_viewers.dart';
import 'package:http/http.dart' as http;

import 'service_locator.dart';

const String baseUrl = 'https://zk3rid.deta.dev';

class DatabaseService {
  DatabaseService();
  static buildQualityStore(List<dynamic> data) {
    final pageManager = getIt<PageManager>();
    var qualityStore = <String, String>{};
    if (data.length == 4) {
      qualityStore['low'] = data[0]['url'];
      qualityStore['medium'] = data[1]['url'];
      qualityStore['high'] = data[2]['url'];
      qualityStore['hd'] = data[3]['url'];
    } else if (data.length == 3) {
      qualityStore['low'] = data[0]['url'];
      qualityStore['medium'] = data[1]['url'];
      qualityStore['high'] = data[2]['url'];
    } else if (data.length == 2) {
      qualityStore['low'] = data[0]['url'];
      qualityStore['medium'] = data[1]['url'];
    } else if (data.length == 1) {
      qualityStore['low'] = data[0]['url'];
    }
    pageManager.audioQualityStoreNotifier.value = qualityStore;
    log("Quality Store: ${qualityStore.keys}");
    var cuurentQuality = pageManager.audioQualityNotifier.value;
    if (qualityStore.containsKey(cuurentQuality)) {
      return qualityStore[cuurentQuality];
    } else {
      return qualityStore.values.first;
    }
  }

  static Future<String> getStreamLink(String videoUrl) async {
    loadingDialog();
    final url = "$baseUrl/getLink?url=$videoUrl";
    var res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      return "";
    }
    var jdata = jsonDecode(res.body);
    var audio = buildQualityStore(jdata);
    return audio;
  }

  /// Get Trending Audios from database sorted by date
  static Future<List<Map<String, dynamic>>> getTrending({int page = 1, int perPage = 20}) async {
    final client = getIt<MeiliSearchClient>();
    final index = client.index('sunday');
    final res = await index.search(' ', limit: perPage, offset: (page - 1) * perPage, sort: ['timestamp:desc']);
    return res.hits ?? [];
  }

  /// Search for audios in database
  static Future<List<Map<String, dynamic>>> searchAudio(String tag, {int page = 1, int perPage = 20}) async {
    final client = getIt<MeiliSearchClient>();
    final index = client.index('sunday');
    final res = await index.search(tag, limit: perPage, offset: (page - 1) * perPage, sort: ['timestamp:desc']);
    return res.hits ?? [];
  }

  /// Get audios from a particular category like adventure, crime, etc
  static Future<List<Map<String, dynamic>>> getAudioByTag(String tag, {int page = 1, int perPage = 20}) async {
    final client = getIt<MeiliSearchClient>();
    final index = client.index('sunday');
    final res = await index
        .search('', limit: perPage, offset: (page - 1) * perPage, sort: ['timestamp:desc'], filter: ['tags = $tag']);
    return res.hits ?? [];
  }

  /// Get audios from a List of ids
  static Future<List<Map<String, dynamic>>> getAudioFromList(
    List<String> idList,
  ) async {
    final client = getIt<MeiliSearchClient>();
    final index = client.index('sunday');
    // remove all empty strings
    idList.removeWhere((element) => element.isEmpty);
    final res = await index.search('', sort: ['timestamp:desc'], filter: ['video_id IN [${idList.join(',')}]']);
    return res.hits ?? [];
  }

  /// Get recommended audios from a particular audio title
  static Future<List<Map<String, dynamic>>> moreLikethis(
    String title,
  ) async {
    final client = getIt<MeiliSearchClient>();
    final index = client.index('sunday');
    List<Map<String, dynamic>> finalResult = [];
    Set<String> titles = {};
    var t1 = title.split('-');
    for (var titlePart in t1) {
      final res = await index.search('"$titlePart"', limit: 10, sort: ['timestamp:desc']);
      for (var item in res.hits!) {
        if (!titles.contains(item['title'])) {
          finalResult.add(item);
          titles.add(item['title']);
        }
      }
    }
    // print(finalResult.map((e) => e['title']));
    if (finalResult.length < 15) {
      final res2 = await getTrending(page: 1, perPage: 10 - finalResult.length);
      return [...finalResult, ...res2];
    } else if (finalResult.length > 15) {
      var ranked = finalResult.toList();
      ranked.sort((a, b) => b['views'].compareTo(a['views']));
      return ranked.sublist(0, 10);
    } else {
      return finalResult.toList();
    }
  }
}
