import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quatation_making/features/addMaterials/data/model/material_model.dart'
    as models;
import 'package:quatation_making/features/addMaterials/repository/material_repository.dart';

class BrandInput {
  final TextEditingController brandController;
  final TextEditingController warrantyController;
  final TextEditingController ratingController;
  final TextEditingController priceController;

  BrandInput()
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

  const AddMaterialState({
    this.status = const AsyncValue.data(null),
    this.brandInputs = const [],
  });

  AddMaterialState copyWith({
    AsyncValue<void>? status,
    List<BrandInput>? brandInputs,
  }) {
    return AddMaterialState(
      status: status ?? this.status,
      brandInputs: brandInputs ?? this.brandInputs,
    );
  }
}

final addMaterialProvider =
    StateNotifierProvider.autoDispose<AddMaterialNotifier, AddMaterialState>(
  (ref) => AddMaterialNotifier(ref.watch(materialRepositoryProvider)),
);

class AddMaterialNotifier extends StateNotifier<AddMaterialState> {
  final MaterialRepository _repository;

  AddMaterialNotifier(this._repository)
      : super(AddMaterialState(brandInputs: [BrandInput()]));

  final materialNameController = TextEditingController();

  void addBrandRow() {
    final newInputs = [...state.brandInputs, BrandInput()];
    state = state.copyWith(brandInputs: newInputs);
  }

  void removeBrandRow(int index) {
    if (state.brandInputs.length <= 1) return;
    final removed = state.brandInputs[index];
    removed.dispose();
    final newInputs = [...state.brandInputs]..removeAt(index);
    state = state.copyWith(brandInputs: newInputs);
  }

  Future<void> addMaterials() async {
    state = state.copyWith(status: const AsyncValue.loading());

    try {
      final materialName = materialNameController.text.trim();
      final now = DateTime.now();
      // Generate a stable materialId to group all brand variants for this material
      final materialId = DateTime.now().microsecondsSinceEpoch.toString();

      // Create one MaterialModel per brand row
      for (final brandInput in state.brandInputs) {
        final brand = brandInput.brandController.text.trim();
        final warranty = brandInput.warrantyController.text.trim();
        final rating = brandInput.ratingController.text.trim();
        final priceText = brandInput.priceController.text.trim();

        // Skip completely empty rows defensively
        if (brand.isEmpty &&
            warranty.isEmpty &&
            rating.isEmpty &&
            priceText.isEmpty) {
          continue;
        }

        final price = double.tryParse(priceText) ?? 0;

        final material = models.MaterialModel(
          materialId: materialId,
          materialName: materialName,
          brand: brand,
          warranty: warranty,
          rating: rating,
          price: price,
          createdAt: now,
        );

        await _repository.addMaterial(material);
      }

      state = state.copyWith(status: const AsyncValue.data(null));

      // Clear controllers after successful submission
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