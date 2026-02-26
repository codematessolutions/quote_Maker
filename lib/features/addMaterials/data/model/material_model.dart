// lib/models/material_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialModel {
  final String? id;
  // Grouping id to link multiple brand variants under one logical material
  final String materialId;
  final String materialName;
  final String unit;
  final String brand;
  final String warranty;
  final String rating;
  final double price;
  final DateTime createdAt;
  final bool isDeleted;

  MaterialModel({
    this.id,
    required this.materialId,
    required this.materialName,
    required this.unit,
    required this.brand,
    required this.warranty,
    required this.rating,
    required this.price,
    required this.createdAt,
    this.isDeleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'unit': unit,
      'brand': brand,
      'warranty': warranty,
      'rating': rating,
      'price': price,
      'createdAt': Timestamp.fromDate(createdAt),
      'isDeleted': isDeleted,
    };
  }

  factory MaterialModel.fromMap(Map<String, dynamic> map, String id) {
    return MaterialModel(
      id: id,
      materialId: map['materialId'] as String? ?? id, // fallback for old data
      materialName: map['materialName'] ?? '',
      unit: map['unit'] ?? '',
      brand: map['brand'] ?? '',
      warranty: map['warranty'] ?? '0',
      rating: map['rating'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isDeleted: map['isDeleted'] as bool? ?? false,
    );
  }

  @override
  String toString() => materialName;
}