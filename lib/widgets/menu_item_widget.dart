import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';
import 'package:quatation_making/core/utils/theme/app_padding.dart';
import 'package:quatation_making/core/utils/theme/app_radius.dart';
import 'package:quatation_making/core/utils/theme/app_typography.dart';

class MenuItemWidget extends StatelessWidget {
  final int index;
  final int selectedIndex;
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const MenuItemWidget({
    super.key,
    required this.index,
    required this.selectedIndex,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = index == selectedIndex;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46.h,
        margin: AppPadding.pt10,
        padding: AppPadding.px16,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightBLueF5 : Colors.transparent,
          borderRadius: AppRadius.r10,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
              size: 22.w,
            ),
            SizedBox(width: 16.w),
            Text(
              text,
              style: AppTypography.body1.copyWith(
                color: isSelected ? AppColors.primaryColor : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}