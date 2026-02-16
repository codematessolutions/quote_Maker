import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quatation_making/features/addMaterials/data/model/material_model.dart' as models;
import 'package:quatation_making/features/addMaterials/repository/material_repository.dart';


final addMaterialProvider =
StateNotifierProvider.autoDispose<AddMaterialNotifier, AsyncValue<void>>(
      (ref) => AddMaterialNotifier(ref.watch(materialRepositoryProvider)),
);

class AddMaterialNotifier extends StateNotifier<AsyncValue<void>> {
  final MaterialRepository _repository;

  AddMaterialNotifier(this._repository) : super(const AsyncValue.data(null));

  final materialNameController = TextEditingController();
  final brandController = TextEditingController();
  final warrantyController = TextEditingController();
  final ratingController = TextEditingController();
  final priceController = TextEditingController();

  Future<void> addMaterial() async {
    state = const AsyncValue.loading();

    try {
      final material = models.MaterialModel(
        materialName: materialNameController.text.trim(),
        brand: brandController.text.trim(),
        warranty: warrantyController.text.trim(),
        rating:ratingController.text.trim(),
        price: double.parse(priceController.text.trim()),
        createdAt: DateTime.now(),
      );

      await _repository.addMaterial(material);
      state = const AsyncValue.data(null);

      // Clear controllers after successful submission
      _clearControllers();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void _clearControllers() {
    materialNameController.clear();
    brandController.clear();
    warrantyController.clear();
    ratingController.clear();
    priceController.clear();
  }

  void dispose() {
    materialNameController.dispose();
    brandController.dispose();
    warrantyController.dispose();
    ratingController.dispose();
    priceController.dispose();
    super.dispose();
  }
}