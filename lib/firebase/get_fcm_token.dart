import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:vlr/firebase_options_primary.dart';
import 'package:vlr/main.dart';
import 'package:vlr/views/screens/dashboard/wallet_screen/add_money_screen/add_money_screen.dart';
import 'package:vlr/views/screens/gym/gym_book_visit_success/gym_book_visit_success_screen.dart';

import '../views/screens/dashboard/wallet_screen/wallet_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// ✅ Helper to download and save file for notifications
Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}

/// ✅ Robust method to show notification with Image & Data support
Future<void> _showNotificationWithPayload(RemoteMessage message) async {
  // Extract Title and Body from notification or data
  String? title = message.notification?.title ?? message.data['title'] ?? "No Title";
  String? body = message.notification?.body ?? message.data['body'] ?? "No Body";
  
  // Extract Image URL from various possible keys
  String? imageUrl = message.notification?.android?.imageUrl ?? 
                    message.data['image'] ?? 
                    message.data['imageUrl'] ?? 
                    message.data['img_url'];

  BigPictureStyleInformation? bigPictureStyleInformation;
  String? bigPicturePath;

  if (imageUrl != null && imageUrl.isNotEmpty) {
    try {
      // Download image for big picture
      bigPicturePath = await _downloadAndSaveFile(imageUrl, 'bigPicture_${Random().nextInt(1000)}');

      bigPictureStyleInformation = BigPictureStyleInformation(
        FilePathAndroidBitmap(bigPicturePath),
        largeIcon: FilePathAndroidBitmap(bigPicturePath),
        contentTitle: title,
        summaryText: body,
      );
    } catch (e) {
      debugPrint("Error downloading notification image: $e");
    }
  }

  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'high_importance_channel',
    'High Importance Notifications',
    channelDescription: 'This channel is used for important notifications',
    importance: Importance.max,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    styleInformation: bigPictureStyleInformation,
    playSound: true,
    enableVibration: true,
  );

  NotificationDetails notificationDetails = NotificationDetails(
    android: androidDetails,
    iOS: DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      attachments: bigPicturePath != null ? [DarwinNotificationAttachment(bigPicturePath)] : null,
    ),
  );

  await flutterLocalNotificationsPlugin.show(
    id: Random().nextInt(100000),
    title: title,
    body: body,
    notificationDetails: notificationDetails,
    payload: message.data.toString(),
  );
}

/// ✅ BACKGROUND HANDLER
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: PrimaryFirebaseOptions.currentPlatform,
    );
  }

  debugPrint("===== BACKGROUND MESSAGE RECEIVED =====");
  debugPrint("Data: ${message.data}");

  // Re-initialize notifications for background isolate
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
  await flutterLocalNotificationsPlugin.initialize(
    settings: const InitializationSettings(android: androidInit),
  );

  await _showNotificationWithPayload(message);
}

class NotificationServices {
  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  late AndroidNotificationChannel channel;

  /// ✅ INIT
  Future<void> init() async {
    await requestNotificationPermission();

    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    channel = const AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications',
      importance: Importance.max,
    );

    /// ✅ INIT LOCAL NOTIFICATION
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notification clicked: ${response.payload}");
      },
    );

    /// ✅ CREATE CHANNEL
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// ✅ START LISTENING FOR MESSAGES
    firebaseInit();
    setupInteractMessage();

    await getDeviceToken();
    isTokenRefresh();

    debugPrint("===== NOTIFICATION SERVICES INITIALIZED =====");
  }

  /// ✅ PERMISSION
  Future<void> requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint("Permission: ${settings.authorizationStatus}");
  }

  /// ✅ TOKEN
  Future<String> getDeviceToken() async {
    try {
      String? token = await messaging.getToken();
      debugPrint("FCM TOKEN: $token");
      return token ?? '';
    } catch (e) {
      debugPrint("Error getting FCM Token: $e");
      return '';
    }
  }

  /// ✅ FOREGROUND
  void firebaseInit() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      debugPrint("===== FOREGROUND MESSAGE RECEIVED =====");
      debugPrint("Data: ${message.data}");

      if (message.data['type'] == 'payment_success' ||
          message.data['type'] == 'wallet_recharge_success') {
        if (message.data.containsKey('booking_id')) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (_) => const GymBookVisitSuccessScreen()),
            (route) => false,
          );
        } else {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WalletScreen()),
            (route) => false,
          );
        }
      }

      await _showNotificationWithPayload(message);
    });
  }

  /// ✅ CLICK HANDLING
  void setupInteractMessage() {
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        debugPrint("Opened from terminated state");
        if (message.data['type'] == 'payment_success' ||
            message.data['type'] == 'wallet_recharge_success') {
          if (message.data.containsKey('booking_id')) {
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (_) => const GymBookVisitSuccessScreen()),
              (route) => false,
            );
          } else {
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const WalletScreen()),
              (route) => false,
            );
          }
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint("Opened from background");
      if (message.data['type'] == 'payment_success' ||
          message.data['type'] == 'wallet_recharge_success') {
        if (message.data.containsKey('booking_id')) {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(
                builder: (_) => const GymBookVisitSuccessScreen()),
            (route) => false,
          );
        } else {
          navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const WalletScreen()),
            (route) => false,
          );
        }
      }
    });
  }

  /// ✅ SHOW NOTIFICATION (Manually)
  Future<void> showNotification(RemoteMessage message) async {
    await _showNotificationWithPayload(message);
  }

  /// ✅ TOKEN REFRESH
  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((newToken) {
      debugPrint("FCM Token Refreshed: $newToken");
    });
  }
}
