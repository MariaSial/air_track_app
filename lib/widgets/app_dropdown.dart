import 'package:flutter/material.dart';
import 'package:air_track_app/widgets/app_colors.dart';

class AppDropdown extends StatefulWidget {
  final List<String> items;
  final Function(String)? onChanged;

  const AppDropdown({super.key, required this.items, this.onChanged});

  @override
  State<AppDropdown> createState() => _AppDropdownState();
}

class _AppDropdownState extends State<AppDropdown> {
  String? selectedValue;

  List<String> get _uniqueItems {
    final seen = <String>{};
    return widget.items.where((s) => seen.add(s)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: SizedBox(
        width: 160, // ✅ adjust this — match your TextField width (e.g. 140–200)
        child: DropdownButton<String>(
          value: selectedValue,
          isExpanded: true, // ✅ makes dropdown take full width of SizedBox
          icon: Icon(Icons.arrow_drop_down, color: black),
          alignment: Alignment.centerLeft,
          menuMaxHeight: 300, // ✅ optional: limits height of the dropdown menu
          selectedItemBuilder: (context) {
            // hide selected value inside the suffix
            return _uniqueItems.map((e) => const SizedBox(width: 24)).toList();
          },
          dropdownColor: lightgrey, // background color
          items: _uniqueItems.map((value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: TextStyle(color: black)),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() => selectedValue = newValue);
            if (widget.onChanged != null && newValue != null) {
              widget.onChanged!(newValue);
            }
          },
        ),
      ),
    );
  }
}
