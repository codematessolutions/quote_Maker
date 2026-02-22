// lib/providers/materials_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quatation_making/features/addMaterials/data/model/material_model.dart';


final materialsProvider = StreamProvider<List<MaterialModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('materials')
      .orderBy('materialName')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => MaterialModel.fromMap(
        doc.data(), doc.id))
        .toList();
  });
});

// Provider for selected material
final selectedMaterialProvider = StateProvider<MaterialModel?>((ref) => null);
