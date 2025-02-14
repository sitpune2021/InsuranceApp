import 'dart:async';

import 'package:flutter/material.dart';
import 'package:insurance/dashboard_screen/dashboard_screen.dart';
import 'package:insurance/login_screen/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    login();
  }

  void login() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Object isLoggedIn = sharedPreferences.get("isLoggedIn") ?? false;
    if (isLoggedIn == true) {
      Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(),
          ),
        ),
      );
    } else {
      Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Center(
            child:
                Image.asset(height: 50, width: 50, "assets/images/logo.png")));
  }
}
