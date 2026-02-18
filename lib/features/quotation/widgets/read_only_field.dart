import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';
import 'package:quatation_making/core/utils/theme/app_radius.dart';
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
        hintText: label,
        helperText: ' ',        // 👈 critical
        errorMaxLines: 1,
        hintStyle: AppTypography.body1.copyWith(
            color: AppColors.grey5D
        ),
        border:OutlineInputBorder(borderRadius: AppRadius.r20,borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: AppRadius.r20,borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: AppRadius.r20,borderSide: BorderSide.none),
        errorBorder: OutlineInputBorder(borderRadius: AppRadius.r20,borderSide: BorderSide.none),
        fillColor: AppColors.card,
        filled: true,
        isDense: true,
      ),
    );
  }
}