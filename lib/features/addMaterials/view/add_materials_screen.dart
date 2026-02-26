import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quatation_making/core/utils/constants/app_assets.dart';
import 'package:quatation_making/core/utils/constants/app_spacing.dart';
import 'package:quatation_making/core/utils/constants/constants.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';
import 'package:quatation_making/core/utils/theme/app_padding.dart';
import 'package:quatation_making/core/utils/theme/app_typography.dart';
import 'package:quatation_making/features/addMaterials/application/material_state.dart';
import 'package:quatation_making/widgets/custom_textField.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddMaterialScreen extends ConsumerWidget {
  const AddMaterialScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final addMaterialNotifier = ref.read(addMaterialProvider.notifier);
    final addMaterialState = ref.watch(addMaterialProvider);
    final isEditing = addMaterialState.editingMaterialId != null;

    final List<String> unitList = [
      // Length
      "Meter",
      "Feet",
      "Km",
      // Quantity
      "Nos",
      "Set",
      "Pair",
      "Box",
      "Packet",
      // Weight
      "Kg",
      "Gram",
      "Ton",
      // Electrical
      "Watt",
      "kW",
      "kVA",
      "Ampere",
      "Volt",
      "Ah",
      // Area
      "Sq.ft",
      "Sq.m",
      // Volume
      "Litre",
      "Bag",
    ];

    ref.listen<AddMaterialState>(addMaterialProvider, (previous, state) {
      final prevStatus = previous?.status;
      final nextStatus = state.status;

      if (prevStatus is AsyncLoading && nextStatus is AsyncData) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEditing ? 'Materials updated successfully!' : 'Materials added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }

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
          isEditing ? 'Edit Material' : 'Add Material',
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
                    Padding(
                      padding: AppPadding.pxy2214,
                      child: DropdownButtonFormField<String>(
                        isDense: true,
                        dropdownColor: AppColors.background,
                        value: unitList.contains(addMaterialState.selectedUnit) 
                            ? addMaterialState.selectedUnit 
                            : unitList.first,
                        decoration: InputDecoration(
                          hintText: 'Select Unit',
                          filled: true,
                          fillColor: AppColors.greyF8,
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                        ),
                        items: unitList.map((String unit) {
                          return DropdownMenuItem<String>(
                            value: unit,
                            child: Text(unit, style: AppTypography.body1),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            addMaterialNotifier.setUnit(newValue);
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a unit';
                          }
                          return null;
                        },
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
                                      icon: Image.asset(AppAssets.delete, color: Colors.red, width: 22.w),
                                      onPressed: () {
                                        addMaterialNotifier.removeBrandRow(index);
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
              bottom: true,
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
                              addMaterialNotifier.saveMaterials();
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
                            isEditing ? 'Update' : 'Submit',
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
            AppSpacing.h16,
          ],
        ),
      ),
    );
  }
}
