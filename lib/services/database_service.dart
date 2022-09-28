import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:sunday_suspense/services/service_locator.dart';

import '../page_manager.dart';
import '../widgets/song_viewers.dart';

const String baseUrl = 'https://zk3rid.deta.dev';

class DatabaseService {
  DatabaseService();

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

  static Future<List<Map<String, dynamic>>> getSongsUsingTag(String tag,
      {bool fuzzy = false, String mode = "or", int count = 10, int page = 1}) async {
    final url = "$baseUrl/search?query=$tag&count=$count&page=$page";
    var res = await http.get(Uri.parse(url));
    var jdata = jsonDecode(res.body);
    return jdata['results'].map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();
  }

  static Future<List<Map<String, dynamic>>> getSongsFromSearch(String tag, {int count = 10, int page = 1}) async {
    final url = "$baseUrl/search?query=$tag&count=$count&page=$page&fuzzy=true&mode=or";
    var res = await http.get(Uri.parse(url));
    var jdata = jsonDecode(res.body);
    return jdata['results'].map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();
  }

  static Future<List<Map<String, dynamic>>> getLatestSongs({int count = 10, int page = 1}) async {
    final url = "$baseUrl/getAllSongs?count=$count&page=$page";
    var res = await http.get(Uri.parse(url));
    var jdata = jsonDecode(res.body);
    return jdata['results'].map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();
  }

  static Future<List<Map<String, dynamic>>> moreLikeThis(String videoId) async {
    final url = "$baseUrl/moreLikeThis?videoId=$videoId";
    var res = await http.get(Uri.parse(url));
    var jdata = jsonDecode(res.body);
    return jdata['results'].map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();
  }

  static Future<List<Map<String, dynamic>>> getSongByCategory(String category, {int count = 10, int page = 1}) async {
    final url = "$baseUrl/getCategorySongs?category=$category&count=$count&page=$page";
    var res = await http.get(Uri.parse(url));
    var jdata = jsonDecode(res.body);
    return jdata['results'].map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();
  }

  static Future<List<Map<String, dynamic>>> getSongFromListt(List<String> idList) async {
    idList.remove("");
    var lString = jsonEncode(idList);
    final url = "$baseUrl/getSongsFromList?list=$lString";
    var res = await http.get(Uri.parse(url));
    var jdata = jsonDecode(res.body);
    return jdata.map<Map<String, dynamic>>((e) => e as Map<String, dynamic>).toList();
  }

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
}
