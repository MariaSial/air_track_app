import 'dart:convert';
import 'package:air_track_app/widgets/app_routes.dart';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  late final TextEditingController emailController; // REAL email input
  late final TextEditingController cnicController;
  late final TextEditingController phoneController;
  late final TextEditingController passwordController;
  late final TextEditingController cityController;

  bool isPasswordVisible = false;
  bool _isSubmitting = false;

  final List<String> cities = [
    'Peshawar',
    'Abbottabad',
    'Mardan',
    'Swat',
    'Kohat',
    'Dera Ismail Khan',
    'Mansehra',
    'Charsadda',
    'Nowshera',
    'Bannu',
    'Haripur',
    'Karak',
    'Hangu',
    'Tank',
    'Batagram',
    'Shangla',
    'Lakki Marwat',
    'Swabi',
    'Chitral',
    'Dir (Upper)',
    'Dir (Lower)',
    'Buner',
    'Malakand',
    'Torghar',
    'Kolai-Palas',
    'Bajaur',
    'Mohmand',
    'Khyber',
    'Orakzai',
    'Kurram',
    'North Waziristan',
    'South Waziristan',
    'Parachinar',
    'Topi',
    'Timergara',
    'Mingora',
    'Balakot',
    'Gomal',
    'Jamrud',
    'Landi Kotal',
    'Havelian',
    'Tordher',
    'Khalabat',
    'Matta',
    'Barikot',
  ];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Helper: compute sha256 hex of password
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
      // Create user in Firebase Auth (real email)
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user!.uid;

      // Store profile in Firestore (includes email + cnic)
      final profile = <String, dynamic>{
        'uid': uid,
        'email': email,
        'name': name,
        'cnic': cnic,
        'phone': phone,
        'city': city,
        'passwordHash': _computePasswordHash(password),
        'authProvider': 'email',
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('users').doc(uid).set(profile);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful')));

      // Navigate to contact us (as you required)
      Navigator.pushReplacementNamed(context, AppRoutes.contactusview);
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? e.code;
      if (e.code == 'email-already-in-use') {
        msg =
            'An account already exists for this email. Try signing in or reset password.';
      } else if (e.code == 'weak-password') {
        msg = 'Provided password is too weak.';
      }
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
    } on FirebaseException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message ?? 'Firestore error')));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
                    if (v == null || v.trim().isEmpty)
                      return 'Please enter your name';
                    return null;
                  },
                ),

                // REAL email field (used for auth + forgot password)
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
                  hintText: "Password (min 6 chars)",
                  obscureText: !isPasswordVisible,
                  maxLines: 1,
                  validator: (v) {
                    if (v == null || v.length < 6)
                      return 'Password must be at least 6 characters';
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
