import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_images.dart';
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
                // height: MediaQuery.sizeOf(context).width * 0.45,
                decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ContactRow(icon: Icons.call, text: contactno),
                    ContactRow(icon: Icons.email, text: contactemail),
                    ContactRow(icon: Icons.location_on, text: location),
                  ],
                ),
              ),
              AppTextField(
                controller: nameController,
                keyboardType: TextInputType.name,
                hintText: "Name",
              ),
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
              SizedBox(height: 8),
              BlueButton(text: send, onPressed: () {}),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
