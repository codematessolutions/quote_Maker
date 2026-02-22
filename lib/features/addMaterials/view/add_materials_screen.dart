
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

    // Only react when a save finishes (loading -> data or error),
    // so adding/removing brand rows won't close the screen.
    ref.listen<AddMaterialState>(addMaterialProvider, (previous, state) {
      final prevStatus = previous?.status;
      final nextStatus = state.status;

      // Success: only when we were loading before and now have data
      if (prevStatus is AsyncLoading && nextStatus is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Materials added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }

      // Error: only when we transition into an error state
      if (nextStatus is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${nextStatus.error}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                        controller:
                            addMaterialNotifier.materialNameController,
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
                    // Dynamic list of brand variants
                    ...List.generate(
                      addMaterialState.brandInputs.length,
                      (index) {
                        final brandInput =
                            addMaterialState.brandInputs[index];
                        final isFirst = index == 0;
                        return Padding(
                          padding: AppPadding.pxy2214,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Brand Variant ${index + 1}',
                                    style: AppTypography.body2,
                                  ),
                                  if (!isFirst)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.redAccent),
                                      onPressed: () {
                                        addMaterialNotifier
                                            .removeBrandRow(index);
                                      },
                                    ),
                                ],
                              ),
                              AppSpacing.h6,
                              CustomTextFormField(
                                hint: 'Brand',
                                controller: brandInput.brandController,
                                keyboardType: TextInputType.name,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Brand';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                              ),
                              AppSpacing.h8,
                              CustomTextFormField(
                                hint: 'Warranty',
                                controller: brandInput.warrantyController,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Warranty';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                              ),
                              AppSpacing.h8,
                              CustomTextFormField(
                                hint: 'Rating',
                                controller: brandInput.ratingController,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter Rating';
                                  }
                                  return null;
                                },
                                textInputAction: TextInputAction.next,
                              ),
                              AppSpacing.h8,
                              CustomTextFormField(
                                hint: 'Price',
                                controller: brandInput.priceController,
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
                            ],
                          ),
                        );
                      },
                    ),
                    Padding(
                      padding: AppPadding.pxy2214,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: addMaterialNotifier.addBrandRow,
                          icon: const Icon(Icons.add),
                          label: const Text('Add another brand'),
                        ),
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
                          onPressed: addMaterialState.status.isLoading
                              ? null
                              : () {
                            if (formKey.currentState!.validate()) {
                              ref
                                  .read(addMaterialProvider.notifier)
                                  .addMaterials();
                            }
                          },
                          child: addMaterialState.status.isLoading
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
