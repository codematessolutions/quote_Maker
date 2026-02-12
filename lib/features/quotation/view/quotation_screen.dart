import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/utils/constants/app_assets.dart';
import '../../../core/utils/theme/app_colors.dart';
import '../../../core/utils/theme/app_typography.dart';
import '../viewmodel/quotation_viewmodel.dart';
import '../widgets/quotation_item_card.dart';
import '../../../data/models/quotation_item.dart';
import '../../../core/utils/constants/constants.dart';
import 'summary_screen.dart';
import '../../profile/view/profile_screen.dart';

class QuotationScreen extends ConsumerStatefulWidget {
  const QuotationScreen({super.key});

  @override
  ConsumerState<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends ConsumerState<QuotationScreen> {
  final materialCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '1');
  final priceCtrl = TextEditingController();
  final ratingCtrl = TextEditingController();
  int warrantyYears = 1;
  bool _isSubmitting = false;

  void addItem() {
    if (materialCtrl.text.isEmpty ||
        brandCtrl.text.isEmpty ||
        qtyCtrl.text.isEmpty ||
        ratingCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final qty = int.tryParse(qtyCtrl.text.trim()) ?? 1;
    final price = double.tryParse(priceCtrl.text.trim()) ?? 0;
    final rating = int.tryParse(ratingCtrl.text.trim()) ?? 0;

    ref.read(quotationViewModelProvider.notifier).addItem(
          QuotationItem(
            material: materialCtrl.text,
            brand: brandCtrl.text,
            qty: qty,
            price: price,
            warranty: warrantyYears,
            rating: rating,
            watt: 0,
          ),
        );

    materialCtrl.clear();
    brandCtrl.clear();
    qtyCtrl.text = '1';
    priceCtrl.clear();
    warrantyYears = 1;
    ratingCtrl.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(quotationViewModelProvider);
    final vm = ref.read(quotationViewModelProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Quotation',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              child: Container(
                decoration: BoxDecoration(
                  color:  AppColors.background,
                  borderRadius:
                      BorderRadius.circular(AppDimens.cardRadius),
                ),
                child: items.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Please Add your data',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 6),
                        itemCount: items.length,
                        itemBuilder: (_, i) => QuotationItemCard(
                          item: items[i],
                          onDelete: () => vm.removeItem(i),
                        ),
                      ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            bottom: true,
            child: Container(
                color: AppColors.panel,
                padding: const EdgeInsets.all(AppDimens.screenPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Row(
                  children: [
                    Expanded(
                      child: _DropdownLikeField(
                        label: 'Materials',
                        controller: materialCtrl,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _DropdownLikeField(
                        label: 'Brand',
                        controller: brandCtrl,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _WarrantyStepper(
                        years: warrantyYears,
                        onChanged: (v) =>
                            setState(() => warrantyYears = v.clamp(1, 99)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: ratingCtrl,
                        keyboardType: TextInputType.number,
                        decoration:  InputDecoration(
                          labelText: 'Rate',
                          labelStyle: AppTypography.caption,
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: qtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Qty',
                          labelStyle: AppTypography.caption,
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryButton,
                            foregroundColor: AppColors.textPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimens.buttonRadius),
                            ),
                          ),
                          onPressed: items.isEmpty || _isSubmitting
                              ? null
                              : () async {
                                  setState(() {
                                    _isSubmitting = true;
                                  });
                                  try {
                                    await vm.submitQuotation();
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text('Quotation saved successfully'),
                                      ),
                                    );

                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const SummaryScreen(),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Failed to save quotation: $e'),
                                      ),
                                    );
                                  } finally {
                                    if (mounted) {
                                      setState(() {
                                        _isSubmitting = false;
                                      });
                                    }
                                  }
                                },
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                      color: AppColors.primary
                                  ),
                                )
                              : Text(
                                  'Submit',
                                  style: AppTypography.body1.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimens.buttonRadius),
                            ),
                          ),
                          onPressed: addItem,
                          child:Text('Add',style:AppTypography.body1.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.card
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
                ),
              ),
            ),

        ],
      ),
    );
  }
}

class _DropdownLikeField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _DropdownLikeField({
    required this.label,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTypography.caption,
        border: const OutlineInputBorder(),
        isDense: true,
        suffixIcon: Image.asset(AppAssets.circleArrowBottom,scale: 4.5,),
      ),
    );
  }
}

class _WarrantyStepper extends StatelessWidget {
  final int years;
  final ValueChanged<int> onChanged;

  const _WarrantyStepper({
    required this.years,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Warranty',
           labelStyle: AppTypography.caption,
          border: const OutlineInputBorder(),
          isDense: true,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints:BoxConstraints( maxWidth: 20.w),
                onPressed: years > 1 ? () => onChanged(years - 1) : null,
                icon:Image.asset(AppAssets.circleArrowLeft,scale: 4.5,)
              ),
              Text('$years',
                textAlign: TextAlign.center,
                style: AppTypography.body2,),
              IconButton(
                padding: EdgeInsets.zero,
                constraints:  BoxConstraints(
                  maxWidth: 20.w
                ),
                onPressed: () => onChanged(years + 1),
                icon:Image.asset(AppAssets.circleArrowRight,scale: 4.5,),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _SmallField({
    required this.label,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    // No longer used; kept for potential future stepper fields.
    return const SizedBox.shrink();
  }
}
