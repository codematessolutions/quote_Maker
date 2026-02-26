import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quatation_making/core/utils/constants/app_spacing.dart';
import 'package:quatation_making/core/utils/theme/app_radius.dart';
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
import '../../profile/view/profile_screen.dart';


class QuotationScreen extends ConsumerStatefulWidget {
  const QuotationScreen({super.key});

  @override
  ConsumerState<QuotationScreen> createState() => _QuotationScreenState();
}

class _QuotationScreenState extends ConsumerState<QuotationScreen> {
  final _formKey = GlobalKey<FormState>();
  final materialCtrl = TextEditingController();
  final brandCtrl = TextEditingController();
  final qtyCtrl = TextEditingController();
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
    warrantyCtrl.dispose(); // ✅ FIX: was missing — memory leak
    super.dispose();
  }

  void _onMaterialSelected(MaterialModel? material) {
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

  void _addItem() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

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
        material: materialCtrl.text.trim(),
        unit: selectedMaterial?.unit??"",
        brand: brandCtrl.text.trim(),
        qty: qty,
        price: selectedMaterial?.price??0,
        warranty: warrantyCtrl.text.trim(),
        rating: ratingCtrl.text.trim(),
        watt: 0,
      ),
    );

    setState(() {
      _clearAll();
    });
  }

  void _clearAll() {
    materialCtrl.clear();
    brandCtrl.clear();
    qtyCtrl.clear();
    priceCtrl.clear();
    ratingCtrl.clear();
    warrantyCtrl.clear();
    selectedMaterial = null;
    // _formKey.currentState?.reset();
  }

  // ✅ FIX: Moved out of build — no more side effects in build()
  @override
  void didUpdateWidget(covariant QuotationScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  // ✅ FIX: Use ref listener for reactive clear — not logic inside build()
  @override
  void initState() {
    super.initState();
    // Listen for list becoming empty (e.g. after save) to auto-clear form
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual(quotationViewModelProvider, (previous, next) {
        if ((previous?.isNotEmpty ?? false) && next.isEmpty) {
          if (mounted) {
            setState(() {
              _clearAll();
            });
          }
        }
      });
    });
  }

  Future<void> _onNext(List<QuotationItem> items) async {
    if (items.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final vm = ref.read(quotationViewModelProvider.notifier);
      final totalAmount = vm.calculateTotalAmount();
      ref.read(summaryProvider.notifier).setTotalAmount(totalAmount);

      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SummaryDetailsScreen()),
      );
    } catch (e, stack) {
      // ✅ FIX: Don't swallow errors silently in production
      debugPrint('Navigation error: $e\n$stack');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Read items once, pass to helpers — no side effects here
    final items = ref.watch(quotationViewModelProvider);
    final vm = ref.read(quotationViewModelProvider.notifier);
    final AsyncValue<List<MaterialModel>> materialsAsync = ref.watch(materialsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      endDrawer:CustomDrawer(),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Image.asset(AppAssets.appLogo, scale: 11),
        centerTitle: false,
        actions: [
          IconButton(
            padding: EdgeInsets.zero,
            icon: Image.asset(AppAssets.profile, scale: 6),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BaymentProfileHeader()),
            ),
          ),
          AppSpacing.w8,
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppDimens.screenPadding),
              child: items.isEmpty
                  ? _buildEmptyState()
                  : _buildItemList(items, vm),
            ),
          ),
          _buildFormPanel(items, materialsAsync),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppAssets.addQuot, scale: 5),
            AppSpacing.h4,
            Text('Please Make Your Quotation', style: AppTypography.body2),
          ],
        ),
      ),
    );
  }

  Widget _buildItemList(
      List<QuotationItem> items, QuotationViewModel vm) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 6),
      itemCount: items.length,
      itemBuilder: (_, i) => QuotationItemCard(
        item: items[i],
        onDelete: () => vm.removeItem(i),
      ),
    );
  }

  Widget _buildFormPanel(List<QuotationItem> items, AsyncValue<List<MaterialModel>> materialsAsync) {
    return SafeArea(
      top: false,
      child: Form(
        key: _formKey,
        child: Container(
          color: AppColors.panel,
          padding: const EdgeInsets.all(AppDimens.screenPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              MaterialDropdownField(
                label: 'Materials',
                controller: materialCtrl,
                materialsAsync: materialsAsync,
                selectedMaterial: selectedMaterial,
                onMaterialSelected: _onMaterialSelected,
                validator: (_) =>
                selectedMaterial == null ? 'Required' : null,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ReadOnlyField(
                        label: 'Brand', controller: brandCtrl),
                  ),
                  AppSpacing.w8,
                  Expanded(
                    child: ReadOnlyField(
                        label: 'Warranty', controller: warrantyCtrl),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ReadOnlyField(
                        label: 'Rating', controller: ratingCtrl),
                  ),
                  AppSpacing.w6,
                  Expanded(child: _buildQtyField()),
                ],
              ),
              AppSpacing.h12,
              _buildActionButtons(items),
              AppSpacing.h14,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQtyField() {
    return TextFormField(
      controller: qtyCtrl,
      style: AppTypography.body2,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Qty',
        helperText: ' ',
        errorMaxLines: 1,
        labelStyle: AppTypography.body1.copyWith(color: AppColors.grey5D),
        border: OutlineInputBorder(
          borderRadius: AppRadius.r20,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.r20,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.r20,
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.r20,
          borderSide: BorderSide.none,
        ),
        fillColor: AppColors.card,
        filled: true,
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required';
        final qty = int.tryParse(value.trim());
        if (qty == null || qty <= 0) return 'Enter valid qty';
        return null;
      },
    );
  }

  Widget _buildActionButtons(List<QuotationItem> items) {
    final isNextEnabled = items.isNotEmpty && !_isSubmitting;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48.h,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                gradient: isNextEnabled
                    ? const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.blue4D, AppColors.blueB3],
                )
                    : LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.grey.shade400,
                    Colors.grey.shade400,
                  ],
                ),
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
                  onTap: isNextEnabled ? () => _onNext(items) : null,
                  child: Center(
                    child: _isSubmitting
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      'Next',
                      style: AppTypography.body1.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
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
                backgroundColor: AppColors.card,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: AppColors.grey63, width: 0.6),
                  borderRadius:
                  BorderRadius.circular(AppDimens.buttonRadius),
                ),
              ),
              onPressed: _addItem,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: AppColors.grey63),
                  Text(
                    'Add',
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey63,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}






