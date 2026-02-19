import 'package:flutter/material.dart';
import 'package:quatation_making/core/utils/constants/app_assets.dart';
import 'package:quatation_making/core/utils/theme/app_typography.dart';

import '../../../core/utils/constants/app_spacing.dart';
import '../../../core/utils/theme/app_colors.dart';
import '../../../data/models/quotation_item.dart';
import '../../../core/utils/constants/constants.dart';

class QuotationItemCard extends StatelessWidget {
  final QuotationItem item;
  final VoidCallback onDelete;

  const QuotationItemCard({
    super.key,
    required this.item,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(left: BorderSide(color: AppColors.primary,width: 3)),
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSpacing.h2,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.material,
                      style: AppTypography.body2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary
                      ),
                    ),
                    AppSpacing.h2,
                    Text(
                      item.brand,
                      style:AppTypography.caption.copyWith(
                        color: AppColors.grey69
                      )
                    ),
                    // if (item.watt > 0) ...[
                    //   AppSpacing.h2,
                    //   Text(
                    //     '${item.watt}W',
                    //     style:AppTypography.caption,
                    //   ),
                    // ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.qty} NOS',
                    style:AppTypography.body2.copyWith(
                      fontWeight: FontWeight.w600,
                        color: AppColors.grey69
                    ),
                  ),
                  AppSpacing.h2,
                  Text(
                    '${item.warranty} ',
                      style:AppTypography.caption.copyWith(
                          color: AppColors.grey69
                      )
                  ),
                ],
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                ' ${item.rating}',
                  style:AppTypography.caption.copyWith(
                      color: AppColors.grey69
                  )
              ),

              IconButton(
                padding: EdgeInsets.zero,
                icon:Image.asset(AppAssets.delete,scale: 5,),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
