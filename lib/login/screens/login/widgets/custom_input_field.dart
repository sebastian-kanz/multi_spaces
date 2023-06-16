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
        hintStyle: const TextStyle(
          // color: kBlack.withOpacity(0.5),
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Icon(
          prefixIcon,
          // color: kBlack.withOpacity(0.5),
        ),
      ),
      obscureText: obscureText,
      onChanged: (String input) => onInputChanged(input),
    );
  }
}
