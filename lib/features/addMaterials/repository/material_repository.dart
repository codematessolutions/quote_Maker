// lib/repositories/material_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quatation_making/features/addMaterials/data/model/material_model.dart';



// ✅ TOP LEVEL — outside everything
final materialRepositoryProvider = Provider<MaterialRepository>((ref) {
  return MaterialRepository(FirebaseFirestore.instance);
});

// ✅ TOP LEVEL — outside everything
final materialsProvider = StreamProvider<List<MaterialModel>>((ref) {
  return ref.read(materialRepositoryProvider).getMaterials();
});

// ✅ Class stays clean — no providers inside
class MaterialRepository {
  final FirebaseFirestore _firestore;

  MaterialRepository(this._firestore);

  CollectionReference get _materialsCollection =>
      _firestore.collection('materials');

  Future<void> addMaterial(MaterialModel material) async {
    try {
      String id = DateTime.now().millisecondsSinceEpoch.toString();
      await _materialsCollection.doc(id).set(
        {
          ...material.toMap(),
          "id": id,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      throw Exception('Failed to add material: $e');
    }
  }

  Future<void> updateMaterial(String id, MaterialModel material) async {
    try {
      await _materialsCollection.doc(id).update(material.toMap());
    } catch (e) {
      throw Exception('Failed to update material: $e');
    }
  }
  Future<void> loopMaterial() async {
    try {
      _materialsCollection.get().then((value){
        for(var doc in value.docs){
          _materialsCollection.doc(doc.id).set({'isDeleted': false}, SetOptions(merge: true));
        }
      });
    } catch (e) {
      throw Exception('Failed to update material: $e');
    }
  }

  Future<void> deleteMaterial(String id) async {
    try {
      // Soft delete: update isDeleted flag
      await _materialsCollection.doc(id).set({'isDeleted': true}, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to delete material: $e');
    }
  }

  Stream<List<MaterialModel>> getMaterials() {
    return _materialsCollection
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MaterialModel.fromMap(
          doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

}