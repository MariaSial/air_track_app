import 'package:flutter/material.dart';

class ContactRow extends StatelessWidget {
  IconData icon;
  String text;
  ContactRow({required this.icon, required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Icon(icon),
          SizedBox(width: 12),
          Flexible(child: Text(text)),
        ],
      ),
    );
  }
}
