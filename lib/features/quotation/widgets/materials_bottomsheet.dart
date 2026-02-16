// Material Dropdown with Search
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quatation_making/core/utils/constants/app_assets.dart';
import 'package:quatation_making/core/utils/theme/app_colors.dart';
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
            labelStyle: AppTypography.caption,
            border: const OutlineInputBorder(),
            isDense: true,
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
  late List<MaterialModel> filteredMaterials;
  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredMaterials = widget.materials;
  }

  void filterMaterials(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredMaterials = widget.materials;
      } else {
        filteredMaterials = widget.materials
            .where((m) =>
        m.materialName.toLowerCase().contains(query.toLowerCase()) ||
            m.brand.toLowerCase().contains(query.toLowerCase()))
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
            child: filteredMaterials.isEmpty
                ? const Center(
              child: Text('No materials found'),
            )
                : ListView.builder(
              itemCount: filteredMaterials.length,
              itemBuilder: (context, index) {
                final material = filteredMaterials[index];
                final isSelected =
                    widget.currentSelection?.id == material.id;

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
                    child: Icon(
                      Icons.category,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    material.materialName,
                    style: AppTypography.body1.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${material.brand} • ${material.warranty}Y warranty • ⭐ ${material.rating}',
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