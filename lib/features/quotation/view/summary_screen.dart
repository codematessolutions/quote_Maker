import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quatation_making/core/utils/constants/app_spacing.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/constants/app_assets.dart';
import '../../../core/utils/theme/app_colors.dart';
import '../../../core/utils/theme/app_typography.dart';
import '../viewmodel/quotation_viewmodel.dart';
import '../../../core/utils/constants/constants.dart';
import '../application/summary_provider.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(quotationViewModelProvider);
    final vm = ref.read(quotationViewModelProvider.notifier);
    final summary = ref.watch(summaryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon:Image.asset(AppAssets.circleArrowLeft,scale: 4,),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Summery',
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppDimens.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: items.isEmpty
                  ? _SkeletonSummary()
                  : ListView.builder(
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.material,
                                  style: AppTypography.body1.copyWith(
                                      fontWeight: FontWeight.w600
                                  ),
                              ),
                              Text(
                                item.brand,
                                  style: AppTypography.body2,
                              ),
                              AppSpacing.h2,
                              Text(
                                'Qty: ${item.qty}  Rating: ${item.price.toStringAsFixed(2)}',
                               style: AppTypography.caption.copyWith(
                                 fontSize: 13.sp,fontWeight: FontWeight.w400
                               ),
                              ),
                              const Divider(thickness: 0.7,),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            // const SizedBox(height: 12),
            // Text(
            //   'Grand Total: ₹${total.toStringAsFixed(2)}',
            //   style: const TextStyle(
            //     fontSize: 16,
            //     fontWeight: FontWeight.bold,
            //   ),
            //   textAlign: TextAlign.right,
            // ),
            const SizedBox(height: 16),
            SafeArea(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimens.buttonRadius),
                    ),
                  ),
                  onPressed: items.isEmpty
                      ? null
                      : () async {
                          try {
                            await vm.downloadPdf(summary: summary);
                          } on AppException catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.message)),
                            );
                          } catch (_) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Unable to generate PDF. Please try again.',
                                ),
                              ),
                            );
                          }
                        },
                  child: const Text(
                    'Download PDF',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonSummary extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        7,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: Container(
            height: 12,
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
    );
  }
}

