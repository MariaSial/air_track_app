import 'dart:async';
import 'package:air_track_app/services/auth_storage.dart';
import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:air_track_app/widgets/app_textstyle.dart';
import 'package:air_track_app/widgets/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _startAndCheckAuth();

    // Navigate after 3 seconds
    // Timer(const Duration(seconds: 3), () {
    //   Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    // });
  }

  Future<void> _startAndCheckAuth() async {
    // keep splash visible for UX
    await Future.delayed(const Duration(milliseconds: 800));

    // 1) Try to read token from your AuthStorage (preferred)
    String? token;
    try {
      token = await AuthStorage.getToken(); // update this if named differently
    } catch (_) {
      token = null;
    }

    // 2) Fallback: if you also saved isLoggedIn in SharedPreferences
    if (token == null || token.isEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
        if (isLoggedIn) {
          // Optionally try to read token from prefs if you saved it
          token = prefs.getString('token');
        }
      } catch (_) {
        // ignore
      }
    }

    // Decide route: if token exists -> go to home, else onboarding or sign-in
    if (!mounted) return;
    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, AppRoutes.aqianalyticsview);
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(splash), fit: BoxFit.cover),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(logo),
              const SizedBox(height: 14),
              Center(child: Text(appName.toUpperCase(), style: appHeading)),
              Center(
                child: Text(
                  province.toUpperCase(),
                  style: appProvince,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
