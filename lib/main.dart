import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:insurance/dashboard_screen/dashboard_screen.dart';
import 'package:insurance/firebase_options.dart';
import 'package:insurance/login_screen/login_screen.dart';
import 'package:insurance/provider/appointment_provider.dart';
import 'package:insurance/services/notification_service.dart';
import 'package:insurance/splash_screen/splash_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  print("Background Message: ${message.notification?.title}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.intance.initialize();

  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  await Permission.camera.request();
  await Permission.location.request();
  // Request storage permission on Android if needed
  if (Platform.isAndroid) {
    await Permission.manageExternalStorage.request();
  }
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppointmentProvider>(
          create: (_) => AppointmentProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // navigatorKey: NotificationService.navigatorKey, // Set navigator key
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
