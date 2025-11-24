import 'package:air_track_app/view/home_view/main_home_screen.dart';
import 'package:air_track_app/view/report_status/reports_view.dart';
import 'package:air_track_app/widgets/app_routes.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/legacy.dart';

// Providers
final themeProvider = StateProvider<bool>((ref) => false);
final localeProvider = StateProvider<Locale>((ref) => const Locale('en'));

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
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

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ur')],
        path: 'assets/langs',
        fallbackLocale: const Locale('en'),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      locale: locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      // home: ReportsView(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
    );
  }
}
