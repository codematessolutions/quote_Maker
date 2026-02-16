// lib/models/material_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MaterialModel {
  final String? id;
  final String materialName;
  final String brand;
  final String warranty;
  final String rating;
  final double price;
  final DateTime createdAt;

  MaterialModel({
    this.id,
    required this.materialName,
    required this.brand,
    required this.warranty,
    required this.rating,
    required this.price,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'materialName': materialName,
      'brand': brand,
      'warranty': warranty,
      'rating': rating,
      'price': price,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MaterialModel.fromMap(Map<String, dynamic> map, String id) {
    return MaterialModel(
      id: id,
      materialName: map['materialName'] ?? '',
      brand: map['brand'] ?? '',
      warranty: map['warranty'] ?? '0',
      rating: map['rating'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }

  @override
  String toString() => materialName;
}