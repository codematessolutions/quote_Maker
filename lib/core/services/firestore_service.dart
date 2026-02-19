import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/profile.dart';
import '../../data/models/quotation_item.dart';
import '../errors/app_exception.dart';
import 'package:quatation_making/features/quotation/data/summary_model.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  /// Creates a new quotation document when [id] is null, or updates
  /// an existing one when [id] is provided. Returns the document id.
  ///
  /// Optionally accepts a [PaymentSummary] so that the values shown in the
  /// payment summary screen are also stored along with the quotation.
  Future<String> saveQuotation(
    List<QuotationItem> items,
    double total, {
    String? id,
    PaymentSummary? summary,
  }) async {
    try {
      final data = <String, dynamic>{
        'createdAt': Timestamp.now(),
        'total': total,
        'items': items.map((e) => e.toJson()).toList(),
        if (summary != null)
          'summary': {
            'totalAmount': summary.totalAmount,
            'subsidy': summary.subsidy,
            'payableAfterSubsidy': summary.payableAfterSubsidy,
            'specialOffer': summary.specialOffer,
            'finalPayableAmount': summary.finalPayableAmount,
            'advance': summary.advance,
            'afterInstallation': summary.afterInstallation,
            'customerName': summary.customerName,
            'customerPhone': summary.customerPhone,
          },
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
