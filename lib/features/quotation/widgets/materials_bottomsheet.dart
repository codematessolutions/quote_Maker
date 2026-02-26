// Material Dropdown with Search
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quatation_making/core/utils/constants/app_assets.dart';
import 'package:quatation_making/core/utils/constants/app_spacing.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';
import 'package:quatation_making/core/utils/theme/app_padding.dart';
import 'package:quatation_making/core/utils/theme/app_radius.dart';
import 'package:quatation_making/core/utils/theme/app_typography.dart';
import 'package:quatation_making/features/addMaterials/application/material_state.dart';
import 'package:quatation_making/features/addMaterials/data/model/material_model.dart';
import 'package:quatation_making/features/addMaterials/repository/material_repository.dart';
import 'package:quatation_making/features/addMaterials/view/add_materials_screen.dart';

class MaterialDropdownField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final AsyncValue<List<MaterialModel>> materialsAsync;
  final MaterialModel? selectedMaterial;
  final Function(MaterialModel?) onMaterialSelected;
  final String? Function(String?)? validator;

  const MaterialDropdownField({super.key,
    required this.label,
    required this.controller,
    required this.materialsAsync,
    required this.selectedMaterial,
    required this.onMaterialSelected,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return materialsAsync.when(
      data: (materials) {
        return TextFormField(
          controller: controller,
          style: AppTypography.body2,
          readOnly: true,
          validator: validator,
          onTap: () async {
            final selected = await showModalBottomSheet<MaterialModel>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => MaterialSelectionSheet(
                currentSelection: selectedMaterial,
              ),
            );

            if (selected != null) {
              onMaterialSelected(selected);
            }
          },
          decoration: InputDecoration(
            labelText: label,
            labelStyle: AppTypography.body1.copyWith(
              color: AppColors.grey5D
            ),
            border: OutlineInputBorder(borderRadius: AppRadius.r12,borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(borderRadius: AppRadius.r12,borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: AppRadius.r12,borderSide: BorderSide.none),
            disabledBorder: OutlineInputBorder(borderRadius: AppRadius.r12,borderSide: BorderSide.none),
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            helperText: ' ',        // 👈 critical
            errorMaxLines: 1,
            filled: true,
            fillColor: AppColors.card,
            suffixIcon: Image.asset(
              AppAssets.circleArrowBottom,
              scale: 4.5,
            ),
          ),
        );
      },
      loading: () => TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTypography.caption,
          border: const OutlineInputBorder(),
          isDense: true,
          filled: true,
          fillColor: AppColors.card,
          suffixIcon: const SizedBox(
            width: 20,
            height: 20,
            child: Padding(
              padding: EdgeInsets.all(12.0),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
      error: (error, stack) => TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTypography.caption,
          border: const OutlineInputBorder(),
          isDense: true,
          errorText: 'Failed to load materials',
        ),
      ),
    );
  }
}

// Material Selection Bottom Sheet
class MaterialSelectionSheet extends ConsumerStatefulWidget {
  final MaterialModel? currentSelection;

  const MaterialSelectionSheet({super.key,
    this.currentSelection,
  });

  @override
  ConsumerState<MaterialSelectionSheet> createState() =>
      MaterialSelectionSheetState();
}

class MaterialSelectionSheetState extends ConsumerState<MaterialSelectionSheet> {
  final searchController = TextEditingController();
  String searchQuery = '';

  Future<void> _confirmDelete(BuildContext context, List<MaterialModel> variants, String materialName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:AppColors.background,
        title: Text('Delete Material', style: AppTypography.h5),
        content: Text(
          variants.length > 1
            ? 'Are you sure you want to delete "$materialName" and all its ${variants.length} brand variants?'
            : 'Are you sure you want to delete "$materialName"?',
          style: AppTypography.body2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',style:AppTypography.body1 ,),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child:Text('Delete',style:AppTypography.body1.copyWith(
              color: Colors.red
            )),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        for (var variant in variants) {
          if (variant.id != null) {
            await ref.read(materialRepositoryProvider).deleteMaterial(variant.id!);
          }
        }
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Material deleted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  void _editMaterial(BuildContext context, String materialId, List<MaterialModel> variants) {
    ref.read(addMaterialProvider.notifier).setEditMaterial(materialId, variants);
    Navigator.pop(context); // Close sheet
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMaterialScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final materialsAsync = ref.watch(materialsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: materialsAsync.when(
        data: (materials) {
          // Grouping logic inside build to ensure it updates when data changes
          final Map<String, List<MaterialModel>> groupedByMaterialId = {};
          for (final material in materials) {
            groupedByMaterialId
                .putIfAbsent(material.materialId, () => <MaterialModel>[])
                .add(material);
          }

          final lowerQuery = searchQuery.toLowerCase();
          final filteredMaterialIds = groupedByMaterialId.entries
              .where((entry) {
                final variants = entry.value;
                if (variants.isEmpty) return false;
                final materialName = variants.first.materialName.toLowerCase();
                final hasMatchingBrand = variants.any(
                  (m) => m.brand.toLowerCase().contains(lowerQuery),
                );
                return materialName.contains(lowerQuery) || hasMatchingBrand;
              })
              .map((e) => e.key)
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: searchController,
                      onChanged: (value) => setState(() => searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search materials...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        isDense: true,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredMaterialIds.isEmpty
                    ? const Center(
                        child: Text('No materials found'),
                      )
                    : ListView.builder(
                        itemCount: filteredMaterialIds.length,
                        itemBuilder: (context, index) {
                          final materialId = filteredMaterialIds[index];
                          final variants = groupedByMaterialId[materialId] ?? [];
                          if (variants.isEmpty) return const SizedBox.shrink();

                          final materialName = variants.first.materialName;
                          final isSelected = widget.currentSelection?.materialId == materialId;
                          final variantCount = variants.length;

                          String subtitleText;
                          if (variantCount == 1) {
                            final m = variants.first;
                            subtitleText = '${m.brand} • ${m.warranty}Y warranty • ⭐ ${m.rating}';
                          } else {
                            final brandSet = variants.map((m) => m.brand).toSet();
                            final brandsPreview = brandSet.take(3).join(', ');
                            final moreCount = brandSet.length - 3;
                            subtitleText = '$variantCount brands • $brandsPreview${moreCount > 0 ? ' +$moreCount more' : ''}';
                          }

                          return ListTile(
                            selected: isSelected,
                            selectedTileColor: AppColors.primary.withOpacity(0.1),
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(Icons.category, color: AppColors.primary, size: 20),
                            ),
                            title: Text(
                              materialName,
                              style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(subtitleText, style: AppTypography.caption),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isSelected) Icon(Icons.check_circle, color: AppColors.primary),
                                PopupMenuButton<String>(
                                  color: AppColors.background,
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(Icons.more_vert, color: Colors.grey),
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _editMaterial(context, materialId, variants);
                                    } else if (value == 'delete') {
                                      _confirmDelete(context, variants, materialName);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                                          AppSpacing.w8,
                                           Text('Edit',style: AppTypography.body1,),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Image.asset(AppAssets.delete, color: Colors.red, width: 20.w),
                                          AppSpacing.w8,
                                          Text('Delete', style: AppTypography.body1.copyWith(
                                            color: Colors.red
                                          ),),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () async {
                              if (variants.length == 1) {
                                Navigator.pop(context, variants.first);
                                return;
                              }

                              final selected = await showModalBottomSheet<MaterialModel>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => BrandSelectionSheet(
                                  materialId: materialId,
                                  materialName: materialName,
                                  currentSelection: widget.currentSelection,
                                ),
                              );

                              if (mounted && selected != null) {
                                Navigator.pop(context, selected);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class BrandSelectionSheet extends ConsumerWidget {
  final String materialId;
  final String materialName;
  final MaterialModel? currentSelection;

  const BrandSelectionSheet({
    super.key,
    required this.materialId,
    required this.materialName,
    this.currentSelection,
  });

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, MaterialModel material) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor:AppColors.background,
        title:Text('Delete Brand Variant',style: AppTypography.h5),
        content: Text('Are you sure you want to delete the brand "${material.brand}" for "$materialName"?',style: AppTypography.body2),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel',style:AppTypography.body1 ,),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child:Text('Delete',style:AppTypography.body1.copyWith(
                color: Colors.red
            )),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (material.id != null) {
          await ref.read(materialRepositoryProvider).deleteMaterial(material.id!);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Brand variant deleted successfully')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _editMaterial(BuildContext context, WidgetRef ref, String materialId, List<MaterialModel> variants) {
    ref.read(addMaterialProvider.notifier).setEditMaterial(materialId, variants);
    // Pop both the BrandSelectionSheet and the MaterialSelectionSheet
    Navigator.of(context).pop(); 
    Navigator.of(context).pop(); 
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMaterialScreen()),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final materialsAsync = ref.watch(materialsProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: materialsAsync.when(
        data: (allMaterials) {
          final variants = allMaterials.where((m) => m.materialId == materialId).toList();
          
          if (variants.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) Navigator.pop(context);
            });
            return const SizedBox.shrink();
          }

          return Column(
            children: [
              Padding(
                padding: AppPadding.p16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    AppSpacing.h16,
                    Text(
                      'Select brand for $materialName',
                      style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: variants.length,
                  itemBuilder: (context, index) {
                    final material = variants[index];
                    final isSelected = currentSelection?.id == material.id;
                    return ListTile(
                      selected: isSelected,
                      selectedTileColor: AppColors.primary.withOpacity(0.1),
                      title: Text(
                        material.brand,
                        style: AppTypography.body1.copyWith(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${material.warranty}Y warranty • ⭐ ${material.rating} • ₹${material.price.toStringAsFixed(2)}',
                        style: AppTypography.caption,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) Icon(Icons.check_circle, color: AppColors.primary),
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.more_vert, color: Colors.grey),
                            onSelected: (value) {
                              if (value == 'edit') {
                                _editMaterial(context, ref, materialId, variants);
                              } else if (value == 'delete') {
                                _confirmDelete(context, ref, material);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    const Icon(Icons.edit, size: 20, color: AppColors.primary),
                                    AppSpacing.w8,
                                    const Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    const Icon(Icons.delete, size: 20, color: Colors.red),
                                    AppSpacing.w8,
                                    const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context, material);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
