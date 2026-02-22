import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firestore_service.dart';
import '../../../core/services/pdf_service.dart';
import '../../../data/models/profile.dart';
import '../../../data/models/quotation_item.dart';
import 'package:quatation_making/features/quotation/data/summary_model.dart';

/// PROVIDER
final quotationViewModelProvider =
NotifierProvider<QuotationViewModel, List<QuotationItem>>(
  QuotationViewModel.new,
);

/// VIEWMODEL
class QuotationViewModel extends Notifier<List<QuotationItem>> {
  late final FirestoreService _firestoreService;
  late final PdfService _pdfService;
  String? _currentQuotationId;

  @override
  List<QuotationItem> build() {
    _firestoreService = FirestoreService();
    _pdfService = PdfService();
    return [];
  }

  void addItem(QuotationItem newItem) {
    final items = [...state];

    final index = items.indexWhere((i) => isSameItem(i, newItem));

    if (index != -1) {
      // Item already exists → increase quantity
      items[index] = items[index].copyWith(
        qty: items[index].qty + newItem.qty,
      );
    } else {
      // New item → add
      items.add(newItem);
    }

    state = items;
  }

  bool isSameItem(QuotationItem a, QuotationItem b) {
    return a.material == b.material &&
        a.brand == b.brand &&
        a.price == b.price;
  }


  void removeItem(int index) {
    final list = [...state];
    list.removeAt(index);
    state = list;
  }

  double get grandTotal =>
      state.fold(0.0, (sum, item) => sum + item.total);

  Future<void> submitQuotation({
    bool clearAfter = false,
    PaymentSummary? summary,
  }) async {
    if (state.isEmpty) return;
    _currentQuotationId = await _firestoreService.saveQuotation(
      state,
      grandTotal,
      id: _currentQuotationId,
      summary: summary,
    );
    if (clearAfter) {
      state = [];
      _currentQuotationId = null;
    }
  }
  double calculateTotalAmount() {
    double total = 0;
    for (var item in state) {
      total += item.price * item.qty;
    }
    return total;
  }
  Future<void> downloadPdf({required PaymentSummary summary}) async {
    try {
      if (state.isEmpty) {
        throw Exception('No quotation items found');
      }
      await _pdfService.generateQuotationPdf(
        state,
        grandTotal,
        summary: summary,
      );
    } catch (e) {
      rethrow;
    }
  }

  void clearQuotation() {
    state = [];
    _currentQuotationId = null;
  }
}
