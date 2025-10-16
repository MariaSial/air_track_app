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

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController cnicController;
  late final TextEditingController passwordController;

  bool isPasswordVisible = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    cnicController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    cnicController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _tryLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final cnic = cnicController.text.trim();
    final password = passwordController.text;

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    setState(() => isLoading = false);

    const mockValidCnic = '1234567890123';
    const mockValidPassword = 'flutter123';

    if (cnic == mockValidCnic && password == mockValidPassword) {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful')));
    } else {
      ScaffoldMessenger.of(
        // ignore: use_build_context_synchronously
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid CNIC or password')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Image.asset(logo),
                  const SizedBox(height: 12),
                  Text(signin, style: blueButtonStyle.copyWith(color: black)),
                  const SizedBox(height: 20),

                  AppTextField(
                    controller: cnicController,
                    hintText: "CNIC ",
                    keyboardType: TextInputType.number,
                    maxLength: 13,
                  ),

                  AppTextField(
                    controller: passwordController,
                    hintText: "Password ",
                    obscureText: !isPasswordVisible,

                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () => isPasswordVisible = !isPasswordVisible,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  WhiteTextButton(
                    text: forgot,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.forgotpassword,
                      );
                    },
                  ),
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
                    text: isLoading ? 'Please wait...' : 'Sign In',
                    onPressed: isLoading ? () {} : _tryLogin,
                  ),
                  WhiteTextButton(text: contactus, onPressed: () {}),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
