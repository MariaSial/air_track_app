import 'package:air_track_app/services/auth_storage.dart';
import 'package:air_track_app/services/signin_service.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:air_track_app/widgets/app_textstyle.dart';
import 'package:flutter/material.dart';
import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_routes.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/app_text_field.dart';
import 'package:air_track_app/widgets/blue_button.dart';
import 'package:air_track_app/widgets/white_text_button.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;
  late final TextEditingController passwordController;

  bool isPasswordVisible = false;
  bool isLoading = false;

  final SigninApiService _api = SigninApiService(
    baseUrl: 'https://testproject.famzhost.com/api/v1',
  );

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() => isLoading = true);

    try {
      // Call API login endpoint
      final token = await _api.loginWithEmail(email, password);
      // ✅ Save token once after login
      await AuthStorage.saveToken(token);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('✅ Sign in successful!'),
            // backgroundColor: white,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pushReplacementNamed(context, AppRoutes.aqianalyticsview);
      }
    } on ApiException catch (e) {
      // DEBUG: Print to console
      print('🔴 ApiException caught!');
      print('🔴 Status Code: ${e.statusCode}');
      print('🔴 Message: ${e.message}');

      if (mounted) {
        String displayMessage = e.message;

        // Force custom messages based on status code
        if (e.statusCode == 401) {
          displayMessage = 'Incorrect email or password';
          print('🔴 Changed to: $displayMessage');
        } else if (e.statusCode == 404) {
          displayMessage = 'No account found with this email';
          print('🔴 Changed to: $displayMessage');
        }

        print('🔴 Final message: $displayMessage');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $displayMessage'),
            // backgroundColor: white,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('🔴 Generic Exception caught: ${e.runtimeType}');
      print('🔴 Exception: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ An unexpected error occurred: ${e.toString()}'),
            // backgroundColor: white,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
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

                  // 📧 Email field
                  AppTextField(
                    controller: emailController,
                    hintText: "Email",
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your email';
                      }
                      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(v.trim())) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),

                  // 🔑 Password field
                  AppTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: !isPasswordVisible,
                    maxLines: 1,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
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

                  // Forgot Password
                  WhiteTextButton(
                    text: 'Forgot Password?',
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.forgotpassword,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't Have an Account?"),
                      WhiteTextButton(
                        text: 'Sign Up',
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.signupview,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Sign In Button
                  BlueButton(
                    text: isLoading ? 'Please wait...' : 'Sign In',
                    onPressed: isLoading ? null : _signInWithEmailAndPassword,
                  ),

                  const SizedBox(height: 10),

                  // Contact Us
                  WhiteTextButton(
                    text: 'Contact Us',
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.contactusview,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
