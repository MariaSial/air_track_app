// lib/view/home/contactus_view.dart
import 'package:air_track_app/services/contact_apiservice.dart';
import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_images.dart';
import 'package:air_track_app/widgets/app_routes.dart';
import 'package:air_track_app/widgets/app_scaffold.dart';
import 'package:air_track_app/widgets/app_text.dart';
import 'package:air_track_app/widgets/app_text_field.dart';
import 'package:air_track_app/widgets/app_textstyle.dart';
import 'package:air_track_app/widgets/blue_button.dart';
import 'package:air_track_app/widgets/contact_row.dart';
import 'package:flutter/material.dart';

class ContactusView extends StatefulWidget {
  const ContactusView({super.key});

  @override
  State<ContactusView> createState() => _ContactusViewState();
}

class _ContactusViewState extends State<ContactusView> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController msgController;
  bool _isSending = false;

  final ContactApiservice _api = ContactApiservice(
    baseUrl: 'https://testproject.famzhost.com/api/v1',
  );

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    msgController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    msgController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final message = msgController.text.trim();

    if (name.isEmpty || email.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final resultMessage = await _api.sendContactUs(
        name: name,
        email: email,
        message: message,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resultMessage), backgroundColor: green),
      );
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushReplacementNamed(context, AppRoutes.aqianalyticsview);
      nameController.clear();
      emailController.clear();
      msgController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(logo),
              const SizedBox(height: 12),
              Text(contactus, style: blueButtonStyle.copyWith(color: black)),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.sizeOf(context).width * 0.91,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    ContactRow(icon: Icons.call, text: contactno),
                    ContactRow(icon: Icons.email, text: contactemail),
                    ContactRow(icon: Icons.location_on, text: location),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(controller: nameController, hintText: "Name"),
              AppTextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                hintText: "Email",
              ),
              AppTextField(
                controller: msgController,
                hintText: "Message",
                maxLines: 4,
              ),
              const SizedBox(height: 8),
              BlueButton(
                text: _isSending ? 'Please wait...' : send,
                onPressed: _isSending ? null : _handleSend,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
