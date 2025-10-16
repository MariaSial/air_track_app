import 'package:air_track_app/view/home/authentication/forgot_password_view.dart';
import 'package:air_track_app/view/home/authentication/sign_in_view.dart';
import 'package:air_track_app/view/home/authentication/sign_up_view.dart';
import 'package:air_track_app/view/home/splash/onboarding_view.dart';
import 'package:air_track_app/view/home/splash/splash_view.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = "/onboardingview";
  static const String signupview = "/signupview";
  static const String signinview = "/signinview";
  static const String forgotpassword = "/forgotpasswordview";
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
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('No route found'))),
        );
    }
  }
}
