import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quatation_making/core/utils/theme/app_typography.dart';

class ReadOnlyField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const ReadOnlyField({super.key,
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: AppTypography.body2,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.caption,
        border: const OutlineInputBorder(),
        isDense: true,

      ),
    );
  }
}