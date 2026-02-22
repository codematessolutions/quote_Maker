import 'package:flutter/material.dart';

// lib/screens/summary_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quatation_making/core/utils/constants/app_spacing.dart';
import 'package:quatation_making/core/utils/constants/constants.dart';
import 'package:quatation_making/core/utils/snackbar_notification/snackbar_notification.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';
import 'package:quatation_making/core/utils/theme/app_padding.dart';
import 'package:quatation_making/core/utils/theme/app_radius.dart';
import 'package:quatation_making/core/utils/theme/app_typography.dart';
import 'package:quatation_making/features/quotation/application/summary_provider.dart';
import 'package:quatation_making/features/quotation/data/summary_model.dart';
import 'package:quatation_making/features/quotation/viewmodel/quotation_viewmodel.dart';

class SummaryDetailsScreen extends ConsumerStatefulWidget {
  const SummaryDetailsScreen({super.key});

  @override
  ConsumerState<SummaryDetailsScreen> createState() => _SummaryDetailsScreenState();
}

class _SummaryDetailsScreenState extends ConsumerState<SummaryDetailsScreen> {
  final specialOfferCtrl = TextEditingController();
  final advanceCtrl = TextEditingController();
  final customerNameCtrl = TextEditingController();
  final customerPhoneCtrl = TextEditingController();
  bool _isSaving = false;
   bool _hasSavedOnce = false;

  @override
  void dispose() {
    specialOfferCtrl.dispose();
    advanceCtrl.dispose();
    customerNameCtrl.dispose();
    customerPhoneCtrl.dispose();
    super.dispose();
  }

  String formatCurrency(double amount) {
    return '₹${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    )}/-';
  }
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final summary = ref.watch(summaryProvider);
    final vm = ref.read(quotationViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title:  Text(
          'Payment Summary',
          style: AppTypography.h5,
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                // Customer details section
                Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: AppPadding.p14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.r10,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CUSTOMER DETAILS',
                        style: AppTypography.body1.copyWith(
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      TextFormField(
                        controller: customerNameCtrl,
                        decoration: InputDecoration(
                          labelText: 'Customer Name',
                          labelStyle: AppTypography.body2,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.r8,
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          ref.read(summaryProvider.notifier).setCustomerName(value.trim());
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter customer name';
                          }
                          return null;
                        },

                      ),
                      AppSpacing.h12,
                      TextFormField(
                        controller: customerPhoneCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          labelStyle: AppTypography.body2,
                          border: OutlineInputBorder(
                            borderRadius: AppRadius.r8,
                          ),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          ref.read(summaryProvider.notifier).setCustomerPhone(value.trim());
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter customer phone';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                // Amount Summary Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.r10,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      _buildAmountRow(
                        'TOTAL AMOUNT',
                        formatCurrency(summary.totalAmount),
                        isHeader: true,
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _buildAmountRow(
                        'SUBSIDY',
                        formatCurrency(summary.subsidy),
                        subtitle: '(Subsidy cheque to be submitted at the time of registration)',
                        isSubsidy: true,
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _buildAmountRow(
                        'PAYABLE AMOUNT AFTER SUBSIDY',
                        formatCurrency(summary.payableAfterSubsidy),
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _buildEditableRow(
                        'NEW YEAR SPECIAL OFFER',
                        specialOfferCtrl,
                        onChanged: (value) {
                          final offer = double.tryParse(value) ?? 0;
                          ref.read(summaryProvider.notifier).setSpecialOffer(offer);
                        },
                        isSpecialOffer: true,
                      ),

                      _buildAmountRow(
                        'FINAL PAYABLE AMOUNT',
                        formatCurrency(summary.finalPayableAmount),
                        isFinal: true,
                      ),
                    ],
                  ),
                ),

                AppSpacing.h20,

                // Payment Schedule Section
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:AppRadius.r12,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding:AppPadding.p12,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                        ),
                        child: Text(
                          'PAYMENT SCHEDULE',
                          style: AppTypography.body1.copyWith(
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _buildPaymentScheduleRow(
                        'ADVANCE',
                        '(Payable on material delivery)',
                        advanceCtrl,
                        onChanged: (value) {
                          final advance = double.tryParse(value) ?? 0;
                          ref.read(summaryProvider.notifier).setAdvance(advance);
                        },
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      _buildAmountRow(
                        'AFTER INSTALLATION',
                        formatCurrency(summary.afterInstallation),
                        isInstallation: true,
                      ),
                      Divider(height: 1, color: Colors.grey.shade300),
                      Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Text(
                          'KSEB REGISTRATION FEES, KSEB SINGLE PHASE NET METER AND SRUCTUR WORK GI INCLUDED',
                          style: AppTypography.caption.copyWith(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.grey69
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),

               AppSpacing.h30,

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48.h,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: _hasSavedOnce
                                  ? AppColors.primary
                                  : AppColors.textSecondary.withOpacity(0.3),
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppDimens.buttonRadius),
                            ),
                          ),
                          onPressed: _hasSavedOnce
                              ? () {
                                  final vm = ref.read(quotationViewModelProvider.notifier);
                                  final summary = ref.read(summaryProvider);
                                  _showExportOptions(context, vm, summary);
                                }
                              : null,
                          child: Text(
                            'Export PDF',
                            style: AppTypography.body1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _hasSavedOnce
                                  ? AppColors.primary
                                  : AppColors.textSecondary.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 48.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                            ),
                          ),
                          onPressed: _isSaving || _hasSavedOnce
                              ? null
                              : () async {
                                  if(formKey.currentState!.validate()){
                                    setState(() {
                                      _isSaving = true;
                                    });
                                    try {
                                      // Save to Firestore but don't clear items yet
                                      await vm.submitQuotation(
                                        summary: summary,
                                        clearAfter: false,
                                      );
                                      // Don't reset summary provider - keep data for PDF generation
                                      NotificationSnack.showSuccess('Quotation saved successfully');
                                      // // Navigate back to QuotationScreen
                                      // if (mounted) {
                                      //   Navigator.pop(context);
                                      // }
                                    } finally {
                                      if (mounted) {
                                        setState(() {
                                          _hasSavedOnce=true;
                                          _isSaving = false;
                                        });
                                      }
                                    }
                                  }
                                  else{
                                    NotificationSnack.showError('Please fill all the fields');
                                  }
                                },
                          child: _isSaving
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _hasSavedOnce ? 'Saved' : 'Save & Generate',
                                  style: AppTypography.body1.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.h40,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountRow(
      String label,
      String amount, {
        String? subtitle,
        bool isHeader = false,
        bool isSubsidy = false,
        bool isSpecialOffer = false,
        bool isFinal = false,
        bool isInstallation = false,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        borderRadius:isHeader?
        BorderRadius.only(topRight: Radius.circular(10.r),topLeft: Radius.circular(10.r)):isFinal?
        BorderRadius.only(bottomLeft: Radius.circular(10.r),bottomRight: Radius.circular(10.r)):null,
        color: isHeader
      ? Colors.blue.shade50
          : isFinal
        ? Colors.blue.shade50
        : null,
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: isHeader || isFinal ? 14.sp : 12.sp,
                    letterSpacing: 0.5,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        fontSize: 10.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTypography.h6.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: isHeader || isFinal ? 18.sp : 16.sp,
              color: isSpecialOffer
                  ? Colors.red
                  : isSubsidy
                  ? Colors.green
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableRow(
      String label,
      TextEditingController controller, {
        required Function(String) onChanged,
        bool isSpecialOffer = false,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13.sp,
                color: isSpecialOffer ? Colors.red : AppColors.textPrimary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SizedBox(
            width: 140.w,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: AppTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
                color: Colors.red,
              ),
              decoration: InputDecoration(
                prefixText: '₹',
                suffixText: '/-',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.r8,
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                isDense: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'enter special offer';
                }
                return null;
              },
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentScheduleRow(
      String label,
      String subtitle,
      TextEditingController controller, {
        required Function(String) onChanged,
      }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(
                    fontSize: 10.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 140.w,
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: AppTypography.h6.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
              decoration: InputDecoration(
                prefixText: '₹',
                border: OutlineInputBorder(
                  borderRadius: AppRadius.r8,
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                isDense: true,
              ),
              onChanged: onChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'enter advance';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showExportOptions(
    BuildContext context,
    QuotationViewModel vm,
    PaymentSummary summary,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.picture_as_pdf),
              title:Text('Export as PDF',style: AppTypography.body1.copyWith(
                fontWeight: FontWeight.w500,
              ),),
              onTap: () async {
                Navigator.pop(context);
                _exportPdfWithLoading(context, vm, summary);
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text('Share',style: AppTypography.body1.copyWith(
              fontWeight: FontWeight.w500,
              ),),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdfWithLoading(
    BuildContext context,
    QuotationViewModel vm,
    PaymentSummary summary,
  ) async {
    // Show loading dialog
    if (!mounted) return;

    late BuildContext dialogContext;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogContext = ctx;
        return AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              SizedBox(width: 16.w),
              Text(
                'Generating PDF...',
                style: AppTypography.body2,
              ),
            ],
          ),
        );
      },
    );

    try {
      await vm.downloadPdf(summary: summary);
      if (mounted) {
        // Close loading dialog using the dialog context
        Navigator.pop(dialogContext);

        // Small delay to ensure dialog closes before showing snackbar
        await Future.delayed(const Duration(milliseconds: 300));

        if (mounted) {
          NotificationSnack.showSuccess('PDF generated successfully');
          // Clear quotation items and reset summary after successful PDF export
          vm.clearQuotation();
          ref.read(summaryProvider.notifier).reset();
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(dialogContext); // Close loading dialog using dialog context
        NotificationSnack.showError('Failed to generate PDF: ${e.toString()}');
      }
    }
  }

}
