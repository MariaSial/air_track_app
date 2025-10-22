// SignInView with Firestore credential check
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_routes.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:air_track_app/widgets/app_text_field.dart';
import 'package:air_track_app/widgets/app_textstyle.dart';
import 'package:air_track_app/widgets/blue_button.dart';
import 'package:air_track_app/widgets/white_text_button.dart';

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

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // Put this inside your SignInView State class (e.g. _SignInViewState)
  Future<void> _signInWithCnicAndPassword(
    String cnicInput,
    String password,
  ) async {
    final cnic = cnicInput.replaceAll(RegExp(r'\D'), '');
    if (cnic.length != 13) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 13-digit CNIC')),
      );
      return;
    }
    if (password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter password')));
      return;
    }

    try {
      // find user doc with this CNIC
      final q = await FirebaseFirestore.instance
          .collection('users')
          .where('cnic', isEqualTo: cnic)
          .limit(1)
          .get();

      if (q.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No account found for this CNIC')),
        );
        return;
      }

      final data = q.docs.first.data();
      final email = (data['email'] ?? '') as String;
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account does not have an email linked'),
          ),
        );
        return;
      }

      // sign in with email + password (Firebase)
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // on success navigate to home/contactus etc.
      if (mounted)
        Navigator.pushReplacementNamed(context, AppRoutes.contactusview);
    } on FirebaseAuthException catch (e) {
      String msg = e.message ?? 'Authentication failed';
      if (e.code == 'wrong-password') msg = 'Incorrect password';
      if (e.code == 'user-not-found') msg = 'No user found with that email';
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
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
                    hintText: "CNIC",
                    keyboardType: TextInputType.number,
                    maxLength: 13,
                  ),
                  AppTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: !isPasswordVisible,
                    maxLines: 1,
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
                      const Text("Don't Have an Account?"),
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
                    onPressed: () {
                      _signInWithCnicAndPassword(
                        cnicController.text.trim(),
                        passwordController.text,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  WhiteTextButton(
                    text: contactus,
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        AppRoutes.contactusview,
                      );
                    },
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
