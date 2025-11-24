// lib/view/home_view/sign_up_view_api.dart
import 'package:air_track_app/services/signin_service.dart';
import 'package:air_track_app/services/signup_service.dart';
import 'package:air_track_app/services/auth_storage.dart'; // <- added
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

      // On success
      final message = resp['message']?.toString() ?? 'Registration successful';
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      // Build a user map (prefer server-sent user object if available)
      Map<String, dynamic> userMap = {
        'name': name,
        'email': email,
        'city': city,
        'phone': phone,
        'cnic': cnic,
      };

      // If response contains a "user" object, prefer its fields (safe access)
      try {
        final serverUser = resp['user'];
        if (serverUser is Map<String, dynamic>) {
          userMap = {
            'name': serverUser['name']?.toString() ?? userMap['name'],
            'email': serverUser['email']?.toString() ?? userMap['email'],
            'city': serverUser['city']?.toString() ?? userMap['city'],
            'phone': serverUser['phone']?.toString() ?? userMap['phone'],
            'cnic': serverUser['cnic']?.toString() ?? userMap['cnic'],
          };
        }
      } catch (_) {
        // ignore parsing error; use local input values
      }

      // If the API returned a token, save it as well
      if (resp['token'] != null) {
        await AuthStorage.saveToken(resp['token'].toString());
      }

      // Save user profile securely so profile screen can read it
      await AuthStorage.saveUser(userMap);

      // Navigate to desired screen (you used contactus previously)
      Navigator.pushReplacementNamed(context, AppRoutes.mainhomeview);
    } on ApiException catch (e) {
      // 👇 Custom handling for common cases
      String displayMessage = e.message;

      if (e.statusCode == 409 ||
          e.statusCode == 422 ||
          e.message.contains('email')) {
        displayMessage =
            'This email is already registered. Please use another one.';
      } else if (e.statusCode == 400) {
        displayMessage = 'Invalid input. Please check your details.';
      } else if (e.statusCode == 500) {
        displayMessage = 'Server error. Please try again later.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ $displayMessage'), backgroundColor: red),
        );
      }
    } catch (e) {
      // Fallback for unexpected errors
      final err = e.toString();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $err'),
            backgroundColor: red,
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
                  hintText: "CNIC (XXXXX-XXXXXXX-X)",
                  keyboardType: TextInputType.number,
                  maxLength: 15, // includes hyphens
                  onChanged: (value) {
                    String digits = value.replaceAll(
                      RegExp(r'\D'),
                      '',
                    ); // remove all non-digits

                    String formatted = "";
                    if (digits.length >= 1) {
                      formatted = digits.substring(
                        0,
                        digits.length.clamp(0, 5),
                      );
                    }
                    if (digits.length > 5) {
                      formatted +=
                          "-" + digits.substring(5, digits.length.clamp(5, 12));
                    }
                    if (digits.length > 12) {
                      formatted +=
                          "-" +
                          digits.substring(12, digits.length.clamp(12, 13));
                    }

                    // Prevent infinite loop by updating only when different
                    if (formatted != cnicController.text) {
                      cnicController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                  },
                  validator: (v) {
                    final onlyDigits = v?.replaceAll(RegExp(r'\D'), '') ?? '';
                    if (onlyDigits.length != 13) {
                      return 'CNIC must be 13 digits (XXXXX-XXXXXXX-X)';
                    }
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
