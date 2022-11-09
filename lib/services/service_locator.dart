import 'package:audio_service/audio_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meilisearch/meilisearch.dart';

import '../page_manager.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // page state
  getIt.registerSingleton<PageManager>(PageManager());

  // meilisearch
  getIt.registerSingleton<MeiliSearchClient>(
      MeiliSearchClient('https://meilisearch-on-koyeb-imsudip.koyeb.app/', dotenv.env['MASTER_KEY']));
}
