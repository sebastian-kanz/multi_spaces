import 'package:flutter/material.dart';

import '../../../../core/constants.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final IconData prefixIcon;
  final Function onInputChanged;
  final bool obscureText;

  const CustomInputField({
    super.key,
    required this.label,
    required this.prefixIcon,
    required this.onInputChanged,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(kPaddingM),
        hintText: label,
        hintStyle: TextStyle(
          color: Theme.of(context).colorScheme.outline,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
      obscureText: obscureText,
      onChanged: (String input) => onInputChanged(input),
    );
  }
}
