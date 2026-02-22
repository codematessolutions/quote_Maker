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
        title:Text(
          'Previous Proposals',
          style:AppTypography.h5.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('quotations')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
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
                        Image.asset(AppAssets.documents,scale: 5.5,),
                        AppSpacing.w4,
                        // Left: main info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Text(
                              //   'Quotation #${docs.length - index}',
                              //   style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
                              // ),
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
                            Text(
                              NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0).format(total),
                              style: AppTypography.h5,
                            ),
                            AppSpacing.h4,
                            if (createdAt != null)
                              Text(dateFormat.format(createdAt), style:
                              AppTypography.caption.copyWith(color: AppColors.textSecondary,fontSize: 11.sp)),
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

