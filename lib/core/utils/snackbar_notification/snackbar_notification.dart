import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';
import 'package:quatation_making/core/utils/theme/app_typography.dart';
import 'package:quatation_making/router/app_routes.dart';


class NotificationSnack {
  static void _showSnackBar(String message, Color color) {
    final messenger =
        NavigationService.scaffoldMessengerKey.currentState;

    if (messenger == null) return;

    final snackBar = SnackBar(
      content: Text(
        message,
        style: AppTypography.label.copyWith(color: AppColors.card),
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        left: 14.w,
        right: 14.w,
        bottom: 16.h,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      duration: const Duration(seconds: 2),
    );

    messenger
      ..clearSnackBars()
      ..showSnackBar(snackBar);
  }

  // ✅ SUCCESS
  static void showSuccess(String message) {
    _showSnackBar(message, AppColors.successColor);
  }

  // ✅ ERROR
  static void showError(String message) {
    _showSnackBar(message, AppColors.errorColor);
  }

  // ✅ WARNING
  static void showWarning( String message) {
    _showSnackBar( message, Colors.orange);
  }

  static void showNormal( String message) {
    _showSnackBar(message, Colors.black);
  }

  static void showOverlay(
      String text,
      Color color,
      ) {
    final navigatorState = NavigationService.navigatorKey.currentState;
    if (navigatorState == null) return;

    final overlayState = navigatorState.overlay;
    if (overlayState == null) return;

    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (_) => Positioned(
        top: 80,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(14.r),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  color: Colors.black.withOpacity(0.25),
                ),
              ],
            ),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: AppTypography.label.copyWith(color: AppColors.card),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

}