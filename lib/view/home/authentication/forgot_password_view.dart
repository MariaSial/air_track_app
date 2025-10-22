// paste into lib/view/home/authentication/forgot_password_view.dart
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:air_track_app/widgets/app_text_field.dart';
import 'package:air_track_app/widgets/app_textstyle.dart';
import 'package:air_track_app/widgets/blue_button.dart';
import 'package:air_track_app/widgets/white_text_button.dart';
import 'package:air_track_app/widgets/app_routes.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController emailController;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!(_formKey.currentState?.validate() ?? true)) return;

    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter your email')));
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Check your inbox.'),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted)
        Navigator.pushReplacementNamed(context, AppRoutes.signinview);
    } on FirebaseAuthException catch (e) {
      final message = e.message ?? 'Failed to send reset email';
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(logo),
                const SizedBox(height: 12),
                Text(forgot, style: blueButtonStyle.copyWith(color: black)),
                const SizedBox(height: 20),
                const Text("Enter your email to reset your password."),
                const SizedBox(height: 12),

                Form(
                  key: _formKey,
                  child: AppTextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    hintText: "Email",
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Please enter your email';
                      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                      if (!emailRegex.hasMatch(v.trim()))
                        return 'Please enter a valid email';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 12),
                BlueButton(
                  text: isLoading ? 'Please wait...' : send,
                  onPressed: isLoading ? () {} : _sendResetEmail,
                ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't Have an Account?"),
                    WhiteTextButton(
                      text: signup,
                      onPressed: () => Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.signupview,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                BlueButton(
                  text: signin,
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.signinview,
                  ),
                ),
                const SizedBox(height: 10),
                WhiteTextButton(
                  text: contactus,
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
    );
  }
}
