
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quatation_making/core/utils/constants/app_spacing.dart';
import 'package:quatation_making/core/utils/constants/constants.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';
import 'package:quatation_making/core/utils/theme/app_padding.dart';
import 'package:quatation_making/core/utils/theme/app_typography.dart';
import 'package:quatation_making/features/addMaterials/application/material_state.dart';
import 'package:quatation_making/widgets/custom_textField.dart';

// lib/screens/add_material_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AddMaterialScreen extends ConsumerWidget {
  const AddMaterialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final addMaterialNotifier = ref.read(addMaterialProvider.notifier);
    final addMaterialState = ref.watch(addMaterialProvider);

    ref.listen<AsyncValue<void>>(addMaterialProvider, (previous, state) {
      state.whenOrNull(
        data: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Material added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        },
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${error.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.card,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.card,
        title: Text(
          'Add Material',
          style: AppTypography.h5,
        ),
        centerTitle: false,
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            AppSpacing.h10,
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Padding(
                      padding: AppPadding.pxy2214,
                      child: CustomTextFormField(
                        hint: 'Material Name',
                        controller: addMaterialNotifier.materialNameController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter material name';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    Padding(
                      padding: AppPadding.pxy2214,
                      child: CustomTextFormField(
                        hint: 'Brand',
                        controller: addMaterialNotifier.brandController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Brand';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    Padding(
                      padding: AppPadding.pxy2214,
                      child: CustomTextFormField(
                        hint: 'Warranty',
                        controller: addMaterialNotifier.warrantyController,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Warranty';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    Padding(
                      padding: AppPadding.pxy2214,
                      child: CustomTextFormField(
                        hint: 'Rating',
                        controller: addMaterialNotifier.ratingController,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Rating';
                          }
                          // if (double.tryParse(value) == null) {
                          //   return 'Please enter a valid number';
                          // }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                    Padding(
                      padding: AppPadding.pxy2214,
                      child: CustomTextFormField(
                        hint: 'Price',
                        controller: addMaterialNotifier.priceController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                    AppSpacing.h18,
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: AppPadding.pxy2214,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48.h,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(AppDimens.buttonRadius),
                            ),
                          ),
                          onPressed: addMaterialState.isLoading
                              ? null
                              : () {
                            if (formKey.currentState!.validate()) {
                              ref.read(addMaterialProvider.notifier).addMaterial();
                            }
                          },
                          child: addMaterialState.isLoading
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white),
                            ),
                          )
                              : Text(
                            'Submit',
                            style: AppTypography.body1.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.card,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
