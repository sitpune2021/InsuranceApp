import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Session {
  Future<String> userDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String stringValue = prefs.getString('username') ?? '';
    return stringValue;
  }

  static Future<void> logout() async {
    // await FirebaseMessaging.instance.deleteToken();
    // print("FCM Token deleted");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clears all session data
  }
}
