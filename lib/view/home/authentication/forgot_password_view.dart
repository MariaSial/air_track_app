import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_routes.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:air_track_app/widgets/app_text_field.dart';
import 'package:air_track_app/widgets/app_textstyle.dart';
import 'package:air_track_app/widgets/blue_button.dart';
import 'package:air_track_app/widgets/white_text_button.dart';
import 'package:flutter/material.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController emailController;

  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  void dipose() {
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Image.asset(logo),
                const SizedBox(height: 12),
                Text(forgot, style: blueButtonStyle.copyWith(color: black)),
                const SizedBox(height: 20),
                Text("Enter your email to reset your password."),
                const SizedBox(height: 12),
                AppTextField(controller: emailController, hintText: "Email"),
                const SizedBox(height: 12),
                BlueButton(text: send, onPressed: () {}),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't Have an Account?"),
                    WhiteTextButton(
                      text: signup,
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.signupview,
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                BlueButton(
                  text: signin,
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.signinview,
                    );
                  },
                ),
                WhiteTextButton(text: contactus, onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
