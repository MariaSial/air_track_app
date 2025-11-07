import 'package:air_track_app/widgets/app_colors.dart';
import 'package:flutter/material.dart';

class AppDropdown extends StatefulWidget {
  final List<String> items;

  final Function(String)? onChanged;

  const AppDropdown({super.key, required this.items, this.onChanged});

  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        padding: EdgeInsets.symmetric(horizontal: 8),
        value: selectedValue,
        icon: Icon(Icons.arrow_drop_down, color: black),
        hint: const Text(''), // <--- hide default label
        items: widget.items
            .map(
              (value) =>
                  DropdownMenuItem<String>(value: value, child: Text(value)),
            )
            .toList(),
        onChanged: (newValue) {
          setState(() {
            selectedValue = newValue;
          });
          if (widget.onChanged != null && newValue != null) {
            widget.onChanged!(newValue);
          }
        },
      ),
    );
  }
}
