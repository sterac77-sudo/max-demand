// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';

/// A widget for displaying a single phase input field.
class PhaseInputField extends StatelessWidget {
  const PhaseInputField({
    super.key,
    required this.controller,
    required this.phaseNumber,
    required this.phaseLabel,
    this.readOnly = false,
    this.onTap,
  });

  final TextEditingController controller;
  final int phaseNumber;
  final String phaseLabel;
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: phaseLabel,
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        keyboardType: TextInputType.number,
        readOnly: readOnly,
        onTap: onTap,
      ),
    );
  }
}
