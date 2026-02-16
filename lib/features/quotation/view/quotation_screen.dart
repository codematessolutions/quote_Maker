import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quatation_making/core/utils/constants/app_spacing.dart';
import 'package:quatation_making/features/addMaterials/application/material_provider.dart';
import 'package:quatation_making/features/addMaterials/data/model/material_model.dart';
import 'package:quatation_making/features/drawer/view/end_drawer.dart';
import 'package:quatation_making/features/quotation/application/summary_provider.dart';
import 'package:quatation_making/features/quotation/view/payment_summary_screen.dart';
import 'package:quatation_making/features/quotation/widgets/materials_bottomsheet.dart';
import 'package:quatation_making/features/quotation/widgets/read_only_field.dart';
import 'package:quatation_making/router/app_routes.dart';

import '../../../core/utils/constants/app_assets.dart';
import '../../../core/utils/theme/app_colors.dart';
import '../../../core/utils/theme/app_typography.dart';
import '../viewmodel/quotation_viewmodel.dart';
import '../widgets/quotation_item_card.dart';
import '../../../data/models/quotation_item.dart';
import '../../../core/utils/constants/constants.dart';
import 'summary_screen.dart';
import '../../profile/view/profile_screen.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuotationScreen extends ConsumerStatefulWidget {
  const QuotationScreen({super.key});

  @override
  ConsumerState<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends ConsumerState<QuotationScreen> {
  final _formKey = GlobalKey<FormState>();
  final materialCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final qtyCtrl = TextEditingController(text: '');
  final priceCtrl = TextEditingController();
  final ratingCtrl = TextEditingController();
  final warrantyCtrl = TextEditingController();

  bool _isSubmitting = false;
  MaterialModel? selectedMaterial;

  @override
  void dispose() {
    materialCtrl.dispose();
    brandCtrl.dispose();
    qtyCtrl.dispose();
    priceCtrl.dispose();
    ratingCtrl.dispose();
    super.dispose();
  }

  void onMaterialSelected(MaterialModel? material) {
    if (material == null) return;

    setState(() {
      selectedMaterial = material;
      materialCtrl.text = material.materialName;
      brandCtrl.text = material.brand;
      warrantyCtrl.text = material.warranty;
      ratingCtrl.text = material.rating.toString();
      priceCtrl.text = material.price.toString();
    });
  }

  void addItem() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    if (selectedMaterial == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a material first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final qty = int.tryParse(qtyCtrl.text.trim()) ?? 1;

    ref.read(quotationViewModelProvider.notifier).addItem(
      QuotationItem(
        material: materialCtrl.text,
        brand: brandCtrl.text,
        qty: qty,
        price: selectedMaterial!.price,
        warranty: warrantyCtrl.text,
        rating: ratingCtrl.text,
        watt: 0,
      ),
    );

    // Clear only quantity field
    qtyCtrl.clear();

    // Optional: Clear all fields if you want to start fresh
    // materialCtrl.clear();
    // brandCtrl.clear();
    // warrantyYears = 0;
    // ratingCtrl.clear();
    // priceCtrl.clear();
    // selectedMaterial = null;

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(quotationViewModelProvider);
    final vm = ref.read(quotationViewModelProvider.notifier);
    final materialsAsync = ref.watch(materialsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer: CustomDrawer(),
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
                  builder: (_) => const BaymentProfileHeader(),
                ),
              );
            },
          ),
          Builder(
            builder: (scaffoldContext) {
              return IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(scaffoldContext).openEndDrawer();

                },
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
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimens.cardRadius),
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
            child: Form(
              key: _formKey,
              child: Container(
                color: AppColors.panel,
                padding: const EdgeInsets.all(AppDimens.screenPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MaterialDropdownField(
                            label: 'Materials',
                            controller: materialCtrl,
                            materialsAsync: materialsAsync,
                            selectedMaterial: selectedMaterial,
                            onMaterialSelected: onMaterialSelected,
                            validator: (value) {
                              if (selectedMaterial == null) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        AppSpacing.w8,
                        Expanded(
                          child: ReadOnlyField(
                            label: 'Brand',
                            controller: brandCtrl,
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h8,
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child:  ReadOnlyField(
                            label: 'Warranty',
                            controller: warrantyCtrl,
                          )
                        ),
                        AppSpacing.w6,
                        Expanded(
                          child: ReadOnlyField(
                            label: 'Rating',
                            controller: ratingCtrl,
                          ),
                        ),
                        AppSpacing.w6,
                        Expanded(
                          child: TextFormField(
                            controller: qtyCtrl,
                            style: AppTypography.body2,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Qty',
                              labelStyle: AppTypography.caption,
                              border: const OutlineInputBorder(),
                              isDense: true,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final qty = int.tryParse(value.trim());
                              if (qty == null || qty <= 0) {
                                return 'Enter valid qty';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h14,
                    SafeArea(
                      bottom: true,
                      child: Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48.h,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondaryButton,
                                  foregroundColor: AppColors.textPrimary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppDimens.buttonRadius),
                                  ),
                                ),
                                // Update the submit button onPressed in your QuotationScreen
                                onPressed: items.isEmpty || _isSubmitting
                                    ? null
                                    : () async {
                                  setState(() {
                                    _isSubmitting = true;
                                  });
                                  try {
                                    // await vm.submitQuotation();

                                    // Calculate and set total amount
                                    final totalAmount = vm.calculateTotalAmount();
                                    ref.read(summaryProvider.notifier).setTotalAmount(totalAmount);

                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Quotation saved successfully'),
                                      ),
                                    );

                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const SummaryDetailsScreen(),
                                      ),
                                    );
                                  } catch (e) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to save quotation: $e'),
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
                                    color: AppColors.primary,
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
                          AppSpacing.w12,
                          Expanded(
                            child: SizedBox(
                              height: 48.h,
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
                                child: Text('Add',
                                    style: AppTypography.body1.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.card)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}






