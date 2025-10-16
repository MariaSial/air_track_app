import 'package:air_track_app/widgets/app_colors.dart';
import 'package:air_track_app/widgets/app_textstyle.dart';
import 'package:flutter/material.dart';

class BlueButton extends StatefulWidget {
  String text;
  VoidCallback onPressed;
  BlueButton({required this.text, required this.onPressed, super.key});

  @override
  State<BlueButton> createState() => _BlueButtonState();
}

class _BlueButtonState extends State<BlueButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: Size(
          MediaQuery.sizeOf(context).width * 0.3,
          MediaQuery.sizeOf(context).height * 0.085,
        ),
        backgroundColor: blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: widget.onPressed,
      child: Text(widget.text, style: blueButtonStyle),
    );
  }
}
