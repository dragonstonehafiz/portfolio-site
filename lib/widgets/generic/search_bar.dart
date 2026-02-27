import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool isDense;

  const SearchBarWidget({
    Key? key,
    this.onChanged,
    this.hintText = 'Search projects...',
    this.isDense = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        isDense: isDense,
      ),
      onChanged: onChanged,
    );
  }
}
