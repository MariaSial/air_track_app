// lib/view/home_view/sign_in_view.dart
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  // Debug helper to print all secure storage values
  Future<void> _debugDumpSecureStorage() async {
    final s = const FlutterSecureStorage();
    final all = await s.readAll();
    print('--- SecureStorage dump ---');
    all.forEach((k, v) => print('$k => $v'));
    print('--- end dump ---');
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    setState(() => isLoading = true);

    try {
      // 1) Login -> returns token and may also save user if server included it
      final token = await _api.loginWithEmail(email, password);

      // 2) Ensure token is saved (SigninApiService already saves it, but safe to call again)
      await AuthStorage.saveToken(token);

      // 3) mark logged-in in prefs (optional)
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('token', token);

      // 4) If server didn't return user in login response, try to fetch profile endpoint.
      //    This will save user to AuthStorage via fetchProfile().
      try {
        await _api.fetchProfile(token);
      } catch (e) {
        // non-fatal — we continue navigation but profile screen might show '-' until user data saved.
        print('⚠️ fetchProfile failed after login: $e');
      }

      // Optional: debug dump (uncomment to inspect secure storage in console)
      // await _debugDumpSecureStorage();

      // 5) Navigate after all saves done
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('✅ Sign in successful!')));

        await Future.delayed(const Duration(milliseconds: 350));
        Navigator.pushReplacementNamed(context, AppRoutes.mainhomeview);
      }
    } on ApiException catch (e) {
      print(
        '🔴 ApiException caught! status: ${e.statusCode} msg: ${e.message}',
      );

      if (mounted) {
        String displayMessage = e.message;

        if (e.statusCode == 401) {
          displayMessage = 'Incorrect email or password';
        } else if (e.statusCode == 404) {
          displayMessage = 'No account found with this email';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ $displayMessage'),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      print('🔴 Generic Exception caught: ${e.runtimeType} -> $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ An unexpected error occurred: ${e.toString()}'),
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

                  // Email
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

                  // Password
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

                  // Sign Up Row
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
