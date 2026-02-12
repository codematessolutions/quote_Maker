import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quatation_making/core/utils/constants/app_spacing.dart';

import '../../../core/utils/theme/app_colors.dart';
import '../../../core/utils/theme/app_typography.dart';
import '../../../core/utils/constants/constants.dart';
import '../../quotation/view/quotation_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const QuotationScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.screenPadding * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.panel,
                ),
                child: Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: AppColors.textSecondary,
                ),
              ),
             AppSpacing.h24,
              Text(
                'Quote Maker',
                style: AppTypography.h5,
              ),
              AppSpacing.h8,
              Text(
                'Create professional quotations in seconds',
                style: AppTypography.body2.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

