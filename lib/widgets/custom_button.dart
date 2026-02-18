import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quatation_making/core/utils/theme/app_radius.dart';
import 'package:quatation_making/core/utils/theme/app_typography.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({super.key, this.onTap,required this.label});
final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: AppRadius.r12,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.05),
      child: InkWell(
        borderRadius:AppRadius.r12,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          child: Row(
            children:  [
              Expanded(
                child: Text(
                  label,
                  style:AppTypography.h6.copyWith(
                    fontWeight: FontWeight.w400
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
