import 'package:air_track_app/widgets/app_routes.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // home: const SplashView(),
      initialRoute: AppRoutes.splash, // Start from Splash Screen
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
