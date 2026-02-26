import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quatation_making/features/addMaterials/data/model/material_model.dart'
    as models;
import 'package:quatation_making/features/addMaterials/repository/material_repository.dart';

class BrandInput {
  final String? id; // doc id
  final TextEditingController brandController;
  final TextEditingController warrantyController;
  final TextEditingController ratingController;
  final TextEditingController priceController;

  BrandInput({this.id})
      : brandController = TextEditingController(),
        warrantyController = TextEditingController(),
        ratingController = TextEditingController(),
        priceController = TextEditingController();

  void dispose() {
    brandController.dispose();
    warrantyController.dispose();
    ratingController.dispose();
    priceController.dispose();
  }
}

class AddMaterialState {
  final AsyncValue<void> status;
  final List<BrandInput> brandInputs;
  final String? editingMaterialId;
  final List<String> deletedBrandIds;
  final String selectedUnit;

  const AddMaterialState({
    this.status = const AsyncValue.data(null),
    this.brandInputs = const [],
    this.editingMaterialId,
    this.deletedBrandIds = const [],
    this.selectedUnit = 'Nos',
  });

  AddMaterialState copyWith({
    AsyncValue<void>? status,
    List<BrandInput>? brandInputs,
    String? editingMaterialId,
    List<String>? deletedBrandIds,
    String? selectedUnit,
  }) {
    return AddMaterialState(
      status: status ?? this.status,
      brandInputs: brandInputs ?? this.brandInputs,
      editingMaterialId: editingMaterialId ?? this.editingMaterialId,
      deletedBrandIds: deletedBrandIds ?? this.deletedBrandIds,
      selectedUnit: selectedUnit ?? this.selectedUnit,
    );
  }
}

final addMaterialProvider =
    StateNotifierProvider<AddMaterialNotifier, AddMaterialState>(
  (ref) => AddMaterialNotifier(ref.watch(materialRepositoryProvider)),
);

class AddMaterialNotifier extends StateNotifier<AddMaterialState> {
  final MaterialRepository _repository;

  AddMaterialNotifier(this._repository)
      : super(const AddMaterialState(brandInputs: [])) {
    if (state.brandInputs.isEmpty) {
      addBrandRow();
    }
  }

  final materialNameController = TextEditingController();

  void addBrandRow() {
    final newInputs = [...state.brandInputs, BrandInput()];
    state = state.copyWith(brandInputs: newInputs);
  }

  void removeBrandRow(int index) {
    if (state.brandInputs.length <= 1) return;
    final removed = state.brandInputs[index];
    
    final List<String> newDeletedIds = [...state.deletedBrandIds];
    if (removed.id != null) {
      newDeletedIds.add(removed.id!);
    }

    removed.dispose();
    final newInputs = [...state.brandInputs]..removeAt(index);
    state = state.copyWith(
      brandInputs: newInputs,
      deletedBrandIds: newDeletedIds,
    );
  }

  void setUnit(String unit) {
    state = state.copyWith(selectedUnit: unit);
  }

  void setEditMaterial(String materialId, List<models.MaterialModel> variants) {
    for (var input in state.brandInputs) {
      input.dispose();
    }

    materialNameController.text = variants.isNotEmpty ? variants.first.materialName : '';
    
    final newInputs = variants.map((v) {
      final input = BrandInput(id: v.id);
      input.brandController.text = v.brand;
      input.warrantyController.text = v.warranty;
      input.ratingController.text = v.rating;
      input.priceController.text = v.price.toString();
      return input;
    }).toList();

    state = state.copyWith(
      brandInputs: newInputs,
      editingMaterialId: materialId,
      deletedBrandIds: [],
      selectedUnit: variants.isNotEmpty ? variants.first.unit : 'Nos',
    );
  }

  void clearForNewEntry() {
    _clearControllers();
    for (var input in state.brandInputs) {
      input.dispose();
    }
    state = const AddMaterialState(brandInputs: []);
    addBrandRow();
  }

  Future<void> saveMaterials() async {
    state = state.copyWith(status: const AsyncValue.loading());

    try {
      final materialName = materialNameController.text.trim();
      final now = DateTime.now();
      final unit = state.selectedUnit;
      
      final materialId = state.editingMaterialId ?? 
          DateTime.now().microsecondsSinceEpoch.toString();

      for (final id in state.deletedBrandIds) {
        await _repository.deleteMaterial(id);
      }

      for (final brandInput in state.brandInputs) {
        final brand = brandInput.brandController.text.trim();
        final warranty = brandInput.warrantyController.text.trim();
        final rating = brandInput.ratingController.text.trim();
        final priceText = brandInput.priceController.text.trim();

        if (brand.isEmpty &&
            warranty.isEmpty &&
            rating.isEmpty &&
            priceText.isEmpty) {
          continue;
        }

        final price = double.tryParse(priceText) ?? 0;

        final material = models.MaterialModel(
          id: brandInput.id,
          materialId: materialId,
          materialName: materialName,
          unit: unit,
          brand: brand,
          warranty: warranty,
          rating: rating,
          price: price,
          createdAt: now,
        );

        if (brandInput.id != null) {
          await _repository.updateMaterial(brandInput.id!, material);
        } else {
          await _repository.addMaterial(material);
        }
      }

      state = state.copyWith(status: const AsyncValue.data(null));
      _clearControllers();
    } catch (e, stack) {
      state = state.copyWith(status: AsyncValue.error(e, stack));
    }
  }

  void _clearControllers() {
    materialNameController.clear();
    for (final input in state.brandInputs) {
      input.brandController.clear();
      input.warrantyController.clear();
      input.ratingController.clear();
      input.priceController.clear();
    }
  }

  @override
  void dispose() {
    materialNameController.dispose();
    for (final input in state.brandInputs) {
      input.dispose();
    }
    super.dispose();
  }
}
