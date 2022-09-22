import 'dart:convert';
import 'package:http/http.dart' as http;
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
    var audio = jdata.last['url'];
    return audio;
  }

  static Future<List<Map<String, dynamic>>> getSongsUsingTag(String tag,
      {bool fuzzy = false, String mode = "or", int count = 10, int page = 1}) async {
    final url = "$baseUrl/search?query=$tag&count=$count&page=$page";
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
}
