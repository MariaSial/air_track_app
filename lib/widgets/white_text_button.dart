import 'package:air_track_app/widgets/app_textstyle.dart';
import 'package:flutter/material.dart';

class WhiteTextButton extends StatefulWidget {
  String text;
  VoidCallback onPressed;
  WhiteTextButton({required this.text, required this.onPressed, super.key});

  @override
  State<WhiteTextButton> createState() => _WhiteTextButtonState();
}

class _WhiteTextButtonState extends State<WhiteTextButton> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        minimumSize: Size(
          MediaQuery.sizeOf(context).width * 0.1,
          MediaQuery.sizeOf(context).height * 0.085,
        ),
        // backgroundColor: blue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: widget.onPressed,
      child: Text(widget.text, style: whiteButtonStyle),
    );
  }
}
