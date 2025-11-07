// sign_up_view_api.dart
import 'package:air_track_app/services/signup_service.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:air_track_app/widgets/app_routes.dart';
import 'package:air_track_app/widgets/app_dropdown.dart';
import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:air_track_app/widgets/app_text_field.dart';
import 'package:air_track_app/widgets/app_textstyle.dart';
import 'package:air_track_app/widgets/blue_button.dart';
import 'package:air_track_app/widgets/white_text_button.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController cnicController;
  late final TextEditingController phoneController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmpasswordController;
  late final TextEditingController cityController;

  bool isPasswordVisible = false;
  bool _isSubmitting = false;

  // Replace baseUrl with your real API base (or inject)
  final SignupApiService _api = SignupApiService(
    baseUrl: 'https://testproject.famzhost.com/api/v1',
  );

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    cnicController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    cityController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    cnicController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    cityController.dispose();
    super.dispose();
  }

  // Optional: keep hash fn if you used it elsewhere
  String _computePasswordHash(String plain) {
    if (plain.isEmpty) return '';
    final bytes = utf8.encode(plain);
    return sha256.convert(bytes).toString();
  }

  Future<void> _signUpWithEmailPassword() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final cnic = cnicController.text.trim().replaceAll(RegExp(r'\D'), '');
    final phone = phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    final city = cityController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || cnic.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please provide email, CNIC and password'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final resp = await _api.register(
        name: name,
        email: email,
        password: password,
        city: city,
        phone: phone,
        cnic: cnic,
      );

      // On success, resp likely contains message and user object
      final message = resp['message']?.toString() ?? 'Registration successful';

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      // Optionally: if API returns token, store it here
      // final token = resp['token'];

      // Navigate to contact us (matching your original behavior)
      Navigator.pushReplacementNamed(context, AppRoutes.contactusview);
    } catch (e) {
      final err = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $err'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(child: Image.asset(logo)),
                const SizedBox(height: 12),
                Text(signup, style: blueButtonStyle.copyWith(color: black)),
                const SizedBox(height: 20),

                AppTextField(
                  controller: nameController,
                  hintText: "Name",
                  keyboardType: TextInputType.name,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Please enter your name';
                    return null;
                  },
                ),

                AppTextField(
                  controller: emailController,
                  hintText: "Email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty)
                      return 'Please enter your email';
                    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                    if (!emailRegex.hasMatch(v.trim()))
                      return 'Please enter a valid email';
                    return null;
                  },
                ),

                AppTextField(
                  controller: cnicController,
                  hintText: "CNIC (13 digits)",
                  keyboardType: TextInputType.number,
                  maxLength: 13,
                  validator: (v) {
                    final digitsOnly = v?.replaceAll(RegExp(r'\D'), '') ?? '';
                    if (digitsOnly.length != 13)
                      return 'CNIC must be exactly 13 digits';
                    return null;
                  },
                ),

                AppTextField(
                  controller: cityController,
                  hintText: "City",
                  suffixIcon: AppDropdown(
                    items: cities,
                    onChanged: (val) => cityController.text = val,
                  ),
                ),

                AppTextField(
                  controller: phoneController,
                  hintText: "Phone",
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  validator: (v) {
                    final digitsOnly = v?.replaceAll(RegExp(r'\D'), '') ?? '';
                    if (digitsOnly.length != 11)
                      return 'Phone must be exactly 11 digits';
                    return null;
                  },
                ),

                AppTextField(
                  controller: passwordController,
                  hintText: "Password (min 8 chars)",
                  obscureText: !isPasswordVisible,
                  maxLines: 1,
                  validator: (v) {
                    if (v == null || v.length < 8)
                      return 'Password must be at least 8 characters';
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => isPasswordVisible = !isPasswordVisible),
                  ),
                ),

                const SizedBox(height: 16),
                BlueButton(
                  text: _isSubmitting ? 'Please wait...' : signup,
                  onPressed: _isSubmitting ? () {} : _signUpWithEmailPassword,
                ),

                const SizedBox(height: 12),
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
