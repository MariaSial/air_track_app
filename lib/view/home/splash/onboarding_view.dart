import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:air_track_app/widgets/app_textstyle.dart';
import 'package:air_track_app/widgets/blue_button.dart';
import 'package:air_track_app/widgets/app_routes.dart';
import 'package:air_track_app/widgets/white_text_button.dart';
import 'package:flutter/material.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Welcome To", style: onBoardingstyle),
              SizedBox(height: 14),
              Image.asset(logo),
              SizedBox(height: 14),
              Center(child: Text(appName.toUpperCase(), style: appHeading)),
              Center(child: Text(province.toUpperCase(), style: appProvince)),
              SizedBox(height: 14),
              BlueButton(
                text: signup,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.signupview);
                },
              ),
              SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already Have an Account?"),
                  WhiteTextButton(
                    text: signin,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.signinview,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
