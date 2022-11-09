// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sunday_suspense/services/notification_service.dart';
import 'screens/root.dart';
import 'ui/my_theme.dart';
import 'page_manager.dart';
import 'services/service_locator.dart';

void main() async {
  await GetStorage.init("prefs");
  await GetStorage.init('HistoryBox');
  await dotenv.load(fileName: ".env");
  await setupServiceLocator();
  runApp(const MyApp());
  await fcmFunctions.initApp();
  await fcmFunctions.iosWebPermission();
  fcmFunctions.foreGroundMessageListener();
  await fcmFunctions.subscripeToTopics("news");
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    getIt<PageManager>().init();
  }

  @override
  void dispose() {
    getIt<PageManager>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: MyTheme.darkTheme,
      home: const RootWidget(),
    );
  }
}
