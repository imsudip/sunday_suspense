import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sunday_suspense/ui/app_colors.dart';

class FCMFunctions {
  static final FCMFunctions _singleton = new FCMFunctions._internal();

  FCMFunctions._internal();

  factory FCMFunctions() {
    return _singleton;
  }

  late FirebaseMessaging messaging;

//************************************************************************************************************ */
  /// Create a [AndroidNotificationChannel] for heads up notifications
  late AndroidNotificationChannel channel;

  /// Initialize the [FlutterLocalNotificationsPlugin] package.
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//************************************************************************************************************ */

  Future initApp() async {
    await Firebase.initializeApp();

    messaging = FirebaseMessaging.instance;

    if (!kIsWeb) {
      channel = const AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        importance: Importance.high,
        showBadge: true,
      );

      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      /// Create an Android Notification Channel.
      ///
      /// We use this channel in the `AndroidManifest.xml` file to override the
      /// default FCM channel to enable heads up notifications.
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      //for IOS Foreground Notification
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future subscripeToTopics(String topic) async {
    await messaging.subscribeToTopic(topic);
  }

  ///Expire : https://firebase.google.com/docs/cloud-messaging/manage-tokens
  Future<String?> getFCMToken() async {
    final fcmToken = await messaging.getToken();
    return fcmToken;
  }

  void tokenListener() {
    messaging.onTokenRefresh.listen((fcmToken) {
      print("FCM Token dinlemede");
      // TODO: If necessary send token to application server.
    }).onError((err) {
      print(err);
    });
  }

  /// IOS
  Future iosWebPermission() async {
    if (Platform.isIOS || kIsWeb) {
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );
    }
  }

  ///Foreground messages
  ///
  ///To handle messages while your application is in the foreground, listen to the onMessage stream.
  void foreGroundMessageListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description,
                importance: Importance.max,
                priority: Priority.high,
                ticker: 'ticker',
                icon: "@mipmap/ic_music",
                color: AppColors.backgroundColor),
          ),
        );
      }
    });

    ///Background messages
    /// To handle messages while your app is in the background or terminated, listen to the onBackgroundMessage stream.
    /// This is only available on Android and iOS.

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');

      //  Navigator.pushNamed(
      //    context,
      //    '/message',
      //    arguments: MessageArguments(message, true),
      //  );
    });
  }
}

final fcmFunctions = FCMFunctions();
