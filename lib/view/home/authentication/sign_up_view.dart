import 'package:air_track_app/widgets/app_dropdown.dart';
import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:air_track_app/widgets/app_text_field.dart';
import 'package:air_track_app/widgets/app_textstyle.dart';
import 'package:air_track_app/widgets/blue_button.dart';
import 'package:air_track_app/widgets/white_text_button.dart';
import 'package:flutter/material.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController nameController;
  late final TextEditingController cnicController;
  late final TextEditingController phoneController;
  late final TextEditingController passwordController;
  late final TextEditingController cityController;

  bool isPasswordVisible = false;
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    cnicController = TextEditingController();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    cityController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    cnicController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    cityController.dispose();
    super.dispose();
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
                Text(
                  signup,
                  style: blueButtonStyle.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 20),

                AppTextField(
                  controller: nameController,
                  hintText: "Name",
                  keyboardType: TextInputType.name,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Please enter your name';
                    }
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
                    if (digitsOnly.length != 13) {
                      return 'CNIC must be exactly 13 digits';
                    }
                    return null;
                  },
                ),

                AppTextField(
                  controller: cityController,
                  hintText: "City",
                  suffixIcon: AppDropdown(
                    items: cities,

                    onChanged: (val) {
                      cityController.text = val;
                    },
                  ),
                ),

                AppTextField(
                  controller: phoneController,
                  hintText: "Phone",
                  keyboardType: TextInputType.phone,
                  maxLength: 11,
                  validator: (v) {
                    final digitsOnly = v?.replaceAll(RegExp(r'\D'), '') ?? '';
                    if (digitsOnly.length != 11) {
                      return 'Phone must be exactly 11 digits';
                    }
                    return null;
                  },
                ),

                AppTextField(
                  controller: passwordController,
                  hintText: "Password (min 6 chars)",
                  obscureText: !isPasswordVisible,
                  validator: (v) {
                    if (v == null || v.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() => isPasswordVisible = !isPasswordVisible);
                    },
                  ),
                ),

                const SizedBox(height: 16),
                BlueButton(
                  text: signup,
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      debugPrint('Valid:');
                      debugPrint('Name: ${nameController.text}');
                      debugPrint('CNIC: ${cnicController.text}');
                      debugPrint('City: ${cityController.text}');
                      debugPrint('Phone: ${phoneController.text}');
                      debugPrint('Password: ${passwordController.text}');
                      // navigate or call API...
                    } else {
                      // invalid - show errors
                      debugPrint('Form invalid');
                    }
                  },
                ),

                const SizedBox(height: 12),
                WhiteTextButton(text: contactus, onPressed: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
