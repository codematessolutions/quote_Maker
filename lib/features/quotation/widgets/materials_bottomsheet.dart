// Material Dropdown with Search
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quatation_making/core/utils/constants/app_assets.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';
import 'package:quatation_making/core/utils/theme/app_padding.dart';
import 'package:quatation_making/core/utils/theme/app_radius.dart';
import 'package:quatation_making/core/utils/theme/app_typography.dart';
import 'package:quatation_making/features/addMaterials/data/model/material_model.dart';

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
                materials: materials,
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
class MaterialSelectionSheet extends StatefulWidget {
  final List<MaterialModel> materials;
  final MaterialModel? currentSelection;

  const MaterialSelectionSheet({super.key,
    required this.materials,
    this.currentSelection,
  });

  @override
  State<MaterialSelectionSheet> createState() =>
      MaterialSelectionSheetState();
}

class MaterialSelectionSheetState extends State<MaterialSelectionSheet> {
  // Group materials by materialId instead of name for better data integrity
  late Map<String, List<MaterialModel>> groupedByMaterialId;
  late List<String> filteredMaterialIds;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _buildGroupedMaterials();
    filteredMaterialIds = groupedByMaterialId.keys.toList();
  }

  void _buildGroupedMaterials() {
    groupedByMaterialId = <String, List<MaterialModel>>{};
    for (final material in widget.materials) {
      groupedByMaterialId
          .putIfAbsent(material.materialId, () => <MaterialModel>[])
          .add(material);
    }
  }

  void filterMaterials(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMaterialIds = groupedByMaterialId.keys.toList();
      } else {
        final lowerQuery = query.toLowerCase();
        filteredMaterialIds = groupedByMaterialId.entries
            .where((entry) {
              final variants = entry.value;
              if (variants.isEmpty) return false;
              final materialName =
                  variants.first.materialName.toLowerCase();
              final hasMatchingBrand = variants.any(
                (m) => m.brand.toLowerCase().contains(lowerQuery),
              );
              return materialName.contains(lowerQuery) || hasMatchingBrand;
            })
            .map((e) => e.key)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
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
                  onChanged: filterMaterials,
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
                      final variants = groupedByMaterialId[materialId] ??
                          <MaterialModel>[];
                      if (variants.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final materialName = variants.first.materialName;
                      final isSelected =
                          widget.currentSelection?.materialId == materialId;

                      final variantCount = variants.length;
                      String subtitleText;
                      if (variantCount == 1) {
                        final m = variants.first;
                        subtitleText =
                            '${m.brand} • ${m.warranty}Y warranty • ⭐ ${m.rating}';
                      } else {
                        final brandSet = variants.map((m) => m.brand).toSet();
                        final brandsPreview = brandSet.take(3).join(', ');
                        final moreCount = brandSet.length - 3;
                        final moreText =
                            moreCount > 0 ? ' +$moreCount more' : '';
                        subtitleText =
                            '$variantCount brands • $brandsPreview$moreText';
                      }

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor:
                            AppColors.primary.withOpacity(0.1),
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.category,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          materialName,
                          style: AppTypography.body1.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        subtitle: Text(
                          subtitleText,
                          style: AppTypography.caption,
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_circle,
                                color: AppColors.primary)
                            : null,
                        onTap: () async {
                          final variantsForId =
                              groupedByMaterialId[materialId] ??
                                  <MaterialModel>[];

                          if (variantsForId.isEmpty) return;

                          // If there is only one brand for this material, select it directly.
                          if (variantsForId.length == 1) {
                            Navigator.pop(context, variantsForId.first);
                            return;
                          }

                          // Otherwise, let the user pick a brand variant.
                          final selected =
                              await showModalBottomSheet<MaterialModel>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => BrandSelectionSheet(
                              materialName: materialName,
                              variants: variantsForId,
                              currentSelection: widget.currentSelection,
                            ),
                          );

                          if (!mounted) return;

                          if (selected != null) {
                            Navigator.pop(context, selected);
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class BrandSelectionSheet extends StatelessWidget {
  final String materialName;
  final List<MaterialModel> variants;
  final MaterialModel? currentSelection;

  const BrandSelectionSheet({
    super.key,
    required this.materialName,
    required this.variants,
    this.currentSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Text(
                  'Select brand for $materialName',
                  style: AppTypography.body1.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
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
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${material.warranty}Y warranty • ⭐ ${material.rating} • ₹${material.price.toStringAsFixed(2)}',
                    style: AppTypography.caption,
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    Navigator.pop(context, material);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}