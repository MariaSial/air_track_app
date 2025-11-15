import 'package:air_track_app/services/forget_password_service.dart';
import 'package:air_track_app/widgets/app_colors.dart';
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

  final ForgetPasswordApiService _api = ForgetPasswordApiService(
    baseUrl: 'https://testproject.famzhost.com/api/v1',
  );

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

  // New: service unavailable popup
  Future<void> _showServiceUnavailablePopup() async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Service Unavailable'),
        content: const Text(
          'Password reset service is unavailable for now. Please try again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: TextStyle(color: blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _sendResetEmail() async {
    // Ensure formState.validate returns false if form state is null
    if (!(_formKey.currentState?.validate() ?? false)) return;

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

    // Show "service unavailable" popup instead of calling API.
    // The real API call is left below, commented out so you can re-enable it later.

    await _showServiceUnavailablePopup();
    return;

    // --- Uncomment this block to re-enable API call when service is available ---
    /*
    setState(() => isLoading = true);

    try {
      // Now the service returns the API message
      final message = await _api.sendForgotPassword(email);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      // Optionally delay so user sees the message
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.signinview);
      }
    } catch (e) {
      // Prefer showing the exception message when available
      String message = 'Something went wrong';
      if (e is ForgotPasswordException) {
        message = e.message;
      } else {
        message = e.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
    */
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
