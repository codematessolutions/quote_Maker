// lib/providers/summary_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quatation_making/features/quotation/data/summary_model.dart';

final summaryProvider = StateNotifierProvider<SummaryNotifier, PaymentSummary>((ref) {
  return SummaryNotifier();
});

class SummaryNotifier extends StateNotifier<PaymentSummary> {
  SummaryNotifier() : super(PaymentSummary(totalAmount: 0));

  void setTotalAmount(double amount) {
    state = state.copyWith(totalAmount: amount);
  }

  void setSpecialOffer(double offer) {
    state = state.copyWith(specialOffer: offer);
  }

  void setAdvance(double advance) {
    state = state.copyWith(advance: advance);
  }

  void reset() {
    state = PaymentSummary(totalAmount: 0);
  }
}