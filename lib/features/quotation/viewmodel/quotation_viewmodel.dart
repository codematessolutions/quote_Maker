import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firestore_service.dart';
import '../../../core/services/pdf_service.dart';
import '../../../data/models/quotation_item.dart';

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

  void addItem(QuotationItem item) {
    state = [...state, item];
  }

  void removeItem(int index) {
    final list = [...state];
    list.removeAt(index);
    state = list;
  }

  double get grandTotal =>
      state.fold(0.0, (sum, item) => sum + item.total);

  Future<void> submitQuotation({bool clearAfter = false}) async {
    if (state.isEmpty) return;
    _currentQuotationId = await _firestoreService.saveQuotation(
      state,
      grandTotal,
      id: _currentQuotationId,
    );
    if (clearAfter) {
      state = [];
      _currentQuotationId = null;
    }
  }

  Future<void> downloadPdf() async {
    if (state.isEmpty) return;
    await _pdfService.generateQuotationPdf(state, grandTotal);
  }
}
