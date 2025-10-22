import 'package:air_track_app/view/home/authentication/contactus_view.dart';
import 'package:air_track_app/widgets/app_routes.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:air_track_app/widgets/blue_button.dart';
import 'package:air_track_app/widgets/app_textstyle.dart';
import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';

class OtpVerificationView extends StatefulWidget {
  final String verificationId;
  final String name;
  final String cnic;
  final String phone; // in international format
  final String city;
  final String passwordHash;

  const OtpVerificationView({
    super.key,
    required this.verificationId,
    required this.name,
    required this.cnic,
    required this.phone,
    required this.city,
    required this.passwordHash,
  });

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  final TextEditingController _otpController = TextEditingController();
  bool _isVerifying = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtpAndSave() async {
    final smsCode = _otpController.text.trim();
    if (smsCode.length < 4) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter the OTP code')));
      return;
    }

    setState(() => _isVerifying = true);
    debugPrint('OTP verify: sending credential for code=$smsCode');

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: smsCode,
      );

      debugPrint('Signing in with credential...');
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        debugPrint('Sign-in completed but user is null');
        throw Exception('Authentication failed (no user returned).');
      }

      debugPrint('Signed in UID=${user.uid}');

      // Build profile data
      final uid = user.uid;
      final profileData = <String, dynamic>{
        'uid': uid,
        'name': widget.name,
        'cnic': widget.cnic,
        'phone': widget.phone,
        'city': widget.city,
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (widget.passwordHash.isNotEmpty) {
        profileData['passwordHash'] = widget.passwordHash;
      }

      debugPrint('Saving user profile for uid=$uid');
      await _firestore.collection('users').doc(uid).set(profileData);
      debugPrint('Profile saved');

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Registration successful')));

      // Use route constant (replace with your actual home route if different)
      // Make sure AppRoutes.contactusview exists and is a route string
      Navigator.pushReplacementNamed(context, AppRoutes.contactusview);
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: code=${e.code}, message=${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.message ?? e.code}')),
      );
    } catch (e, st) {
      debugPrint('OTP verification error: $e\n$st');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(logo),
                const SizedBox(height: 12),
                Text(
                  'Enter OTP',
                  style: blueButtonStyle.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 12),
                Text(
                  'Code sent to ${widget.phone}',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: 200,
                  child: TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Enter OTP'),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                BlueButton(
                  text: _isVerifying ? 'Verifying...' : 'Verify & Register',
                  onPressed: _isVerifying ? () {} : _verifyOtpAndSave,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
