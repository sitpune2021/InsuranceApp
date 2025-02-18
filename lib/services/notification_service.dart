import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:insurance/appointment_screen/appointment_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     const AndroidInitializationSettings androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings settings = InitializationSettings(
//       android: androidSettings,
//     );

//     await _localNotificationsPlugin.initialize(settings);
//   }

//   static Future<void> showNotification(RemoteMessage message) async {
//     const AndroidNotificationDetails androidDetails =
//         AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//     );

//     const NotificationDetails notificationDetails =
//         NotificationDetails(android: androidDetails);

//     await _localNotificationsPlugin.show(
//       0,
//       message.notification?.title ?? "No Title",
//       message.notification?.body ?? "No Body",
//       notificationDetails,
//     );
//   }
// }
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.intance.setupFlutterNotifications();
  await NotificationService.intance.showNotification(message);
}

class NotificationService {
  NotificationService._();

  static final NotificationService intance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isFlutterLocalNotificationsInitilized = false;
  // static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await _requestPermission();
    await _setupMessageHandlers();
    final fcmtoken = await _messaging.getToken();
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // prefs.setString("fcmtoken", fcmtoken.toString());
    print("FCM Token: $fcmtoken");
  }

  Future<String?> getFcmToken() async {
    // Retrieve and return the FCM token
    return await _messaging.getToken();
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print("Permission Status:${settings.authorizationStatus}");
  }

  Future<void> setupFlutterNotifications() async {
    if (_isFlutterLocalNotificationsInitilized) {
      return;
    }
    const channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    const initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");

    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: darwinSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print("Notification tapped: ${response.payload}");

        // Handle notification tap
        // _handleNotificationTap(response.payload);
      },
    );

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    // await FirebaseMessaging.instance
    //     .setForegroundNotificationPresentationOptions(
    //   alert: true,
    //   badge: true,
    //   sound: true,
    // );
    _isFlutterLocalNotificationsInitilized = true;
  }

  //  void _handleNotificationTap(String? payload) {
  //   if (payload != null) {
  //     navigatorKey.currentState?.push(
  //       MaterialPageRoute(builder: (context) => AppointmentScreen()),
  //     );
  //   }
  // }

  Future<void> showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null && android != null) {
      await _localNotifications.show(
        0,
        message.notification?.title ?? "No Title",
        message.notification?.body ?? "No Body",
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        //  payload: "appointment_screen",
      );
    }
  }

  Future<void> _setupMessageHandlers() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground notification received: ${message.notification?.title}");

      // Show local notification using flutter_local_notifications
      showNotification(message);
    });

//background meaasge
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
//opened app

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundMessage(initialMessage);
    }
  }

  void _handleBackgroundMessage(RemoteMessage message) {}
}
