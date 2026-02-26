import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:quatation_making/core/utils/constants/app_assets.dart';
import 'package:quatation_making/core/utils/constants/app_spacing.dart';

import '../../../core/utils/theme/app_colors.dart';
import '../../../core/utils/theme/app_typography.dart';
import '../../../core/utils/constants/constants.dart';
import '../../../core/services/pdf_service.dart';
import '../../../data/models/quotation_item.dart';
import 'package:quatation_making/features/quotation/data/summary_model.dart';

class QuotationHistoryScreen extends ConsumerWidget {
  const QuotationHistoryScreen({super.key});

  Future<void> _deleteQuotation(BuildContext context, String docId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Proposal', style: AppTypography.h5),
        content: Text('Are you sure you want to delete this proposal?', style: AppTypography.body2),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('quotations')
            .doc(docId)
            .update({'isDeleted': true});
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Proposal deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfService = PdfService();

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
        title: Text(
          'Previous Proposals',
          style: AppTypography.h5.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('quotations')
            .where('isDeleted', isNotEqualTo: true)
            .orderBy('isDeleted')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No quotations found'),
            );
          }

          final docs = snapshot.data!.docs;
          final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

          return ListView.builder(
            padding: const EdgeInsets.all(AppDimens.screenPadding),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
              final total = (data['total'] as num?)?.toDouble() ?? 0;

              final itemsJson = (data['items'] as List<dynamic>? ?? []);
              final items = itemsJson
                  .map((e) =>
                      QuotationItem.fromJson(e as Map<String, dynamic>))
                  .toList();

              final summaryMap =
                  (data['summary'] as Map<String, dynamic>? ?? {});
              final summary = PaymentSummary(
                totalAmount:
                    (summaryMap['totalAmount'] as num? ?? total).toDouble(),
                subsidy:
                    (summaryMap['subsidy'] as num? ?? 78000).toDouble(),
                specialOffer:
                    (summaryMap['specialOffer'] as num? ?? 0).toDouble(),
                advance:
                    (summaryMap['advance'] as num? ?? 0).toDouble(),
                customerName:
                    (summaryMap['customerName'] as String?) ?? '',
                customerPhone:
                    (summaryMap['customerPhone'] as String?) ?? '',
              );

              return InkWell(
                onLongPress: () => _deleteQuotation(context, doc.id),
                onTap: () async {
                  await pdfService.generateQuotationPdf(items, total, summary: summary);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 0,
                  color: AppColors.card,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(AppAssets.documents, scale: 5.5,),
                        AppSpacing.w4,
                        // Left: main info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (summary.customerName.isNotEmpty)
                                Text(
                                    summary.customerName,
                                    style: AppTypography.body1.copyWith(
                                  color: AppColors.primary,
                                      fontWeight: FontWeight.w600
                                )),
                              AppSpacing.h4,
                              if (summary.customerPhone.isNotEmpty)
                                Text(' ${summary.customerPhone}', style: AppTypography.body2.copyWith(
                                  color: AppColors.grey69
                                )),
                            ],
                          ),
                        ),
                        // Right: date + action
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Text(
                                  NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(total),
                                  style: AppTypography.h5,
                                ),
                                AppSpacing.w8,
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: Image.asset(
                                    AppAssets.delete,
                                    color: Colors.red,
                                    width: 18.w,
                                  ),
                                  onPressed: () => _deleteQuotation(context, doc.id),
                                ),
                              ],
                            ),
                            AppSpacing.h4,
                            if (createdAt != null)
                              Text(dateFormat.format(createdAt), style:
                              AppTypography.caption.copyWith(color: AppColors.textSecondary, fontSize: 11.sp)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}