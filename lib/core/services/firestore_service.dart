import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/profile.dart';
import '../../data/models/quotation_item.dart';
import '../errors/app_exception.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  /// Creates a new quotation document when [id] is null, or updates
  /// an existing one when [id] is provided. Returns the document id.
  Future<String> saveQuotation(
    List<QuotationItem> items,
    double total, {
    String? id,
  }) async {
    try {
      final data = <String, dynamic>{
        'createdAt': Timestamp.now(),
        'total': total,
        'items': items.map((e) => e.toJson()).toList(),
      };

      if (id == null) {
        final doc = await _db.collection('quotations').add(data);
        return doc.id;
      } else {
        await _db.collection('quotations').doc(id).set(data);
        return id;
      }
    } catch (e) {
      throw AppException.from(e);
    }
  }

  /// PROFILE
  Future<Profile?> fetchProfile() async {
    try {
      final doc = await _db.collection('profiles').doc('default').get();
      if (!doc.exists) return null;
      return Profile.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw AppException.from(e);
    }
  }

  Future<void> saveProfile(Profile profile) async {
    try {
      await _db.collection('profiles').doc('default').set(profile.toJson());
    } catch (e) {
      throw AppException.from(e);
    }
  }
}
