import 'package:air_track_app/view/aqi_analytics/aqi_analytics_view.dart';
import 'package:air_track_app/view/authentication/contactus_view.dart';
import 'package:air_track_app/view/authentication/forgot_password_view.dart';
import 'package:air_track_app/view/authentication/sign_in_view.dart';
import 'package:air_track_app/view/authentication/sign_up_view.dart';
import 'package:air_track_app/view/home_view/main_home_screen.dart';
import 'package:air_track_app/view/splash/onboarding_view.dart';
import 'package:air_track_app/view/splash/splash_view.dart';
import 'package:air_track_app/view/notifications/notification_view.dart';
import 'package:air_track_app/view/report_status/reports_view.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = "/onboardingview";
  static const String signupview = "/signupview";
  static const String signinview = "/signinview";
  static const String forgotpassword = "/forgotpasswordview";
  static const String contactusview = "/contactusview";
  static const String aqianalyticsview = "/aqianalyticsview";
  static const String reportsview = "/reportsview";
  static const String notificationview = "/notificationview";
  static const String mainhomeview = "/mainhomeview";
}

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case AppRoutes.onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingView());
      case AppRoutes.signupview:
        return MaterialPageRoute(builder: (_) => SignUpView());
      case AppRoutes.signinview:
        return MaterialPageRoute(builder: (_) => SignInView());
      case AppRoutes.forgotpassword:
        return MaterialPageRoute(builder: (_) => ForgotPasswordView());
      case AppRoutes.contactusview:
        return MaterialPageRoute(builder: (_) => ContactusView());
      case AppRoutes.aqianalyticsview:
        return MaterialPageRoute(builder: (_) => AqiAnalyticsView());
      case AppRoutes.reportsview:
        return MaterialPageRoute(builder: (_) => ReportsView());
      case AppRoutes.notificationview:
        return MaterialPageRoute(builder: (_) => NotificationView());
      case AppRoutes.mainhomeview:
        return MaterialPageRoute(builder: (_) => MainHomeScreen());
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('No route found'))),
        );
    }
  }
}
