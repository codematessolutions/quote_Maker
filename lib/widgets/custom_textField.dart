import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool isPassword;
  final Widget? prefixIcon;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool enabled;
  final String? initialValue;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final ValueNotifier<bool>? obscureTextNotifier; // For password toggle

  const CustomTextFormField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.isPassword = false,
    this.prefixIcon,
    this.validator,
    this.onChanged,
    this.maxLength,
    this.inputFormatters,
    this.enabled = true,
    this.initialValue,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.obscureTextNotifier,
  });

  @override
  Widget build(BuildContext context) {
    // Create local notifier if not provided
    final localNotifier = obscureTextNotifier ?? ValueNotifier<bool>(true);

    return ValueListenableBuilder<bool>(
      valueListenable: localNotifier,
      builder: (context, obscureText, child) {
        return TextFormField(
          controller: controller,
          obscureText: isPassword ? obscureText : false,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          maxLength: maxLength,
          inputFormatters: inputFormatters,
          enabled: enabled,
          initialValue: initialValue,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            labelStyle:GoogleFonts.poppins(
              fontSize: 13.sp,
              color: AppColors.primaryColor,
            ),
            hintStyle: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: AppColors.primaryColor,
            ),
            prefixIcon: prefixIcon,
            suffixIcon: isPassword
                ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondary,
              ),
              onPressed: () {
                localNotifier.value = !localNotifier.value;
              },
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.greyF8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: BorderSide(color: AppColors.greyF8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Colors.blue, width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            filled: true,
            fillColor: AppColors.greyF8,
            counterText: '', // Hide character counter
          ),
        );
      },
    );
  }
}