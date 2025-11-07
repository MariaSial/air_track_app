import 'package:air_track_app/view/aqi_analytics/aqi_analytics_view.dart';
import 'package:air_track_app/widgets/app_routes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyDSiNAX2t8-P9auXaK1850-_q3UACql_N0",
        authDomain: "air-track-a2756.firebaseapp.com",
        projectId: "air-track-a2756",
        storageBucket: "air-track-a2756.firebasestorage.app",
        messagingSenderId: "419569247027",
        appId: "1:419569247027:web:26d72e5675a10ef7e0d446",
        measurementId: "G-444778EF41",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AqiAnalyticsView(),
      initialRoute: AppRoutes.splash, // Start from Splash Screen
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
