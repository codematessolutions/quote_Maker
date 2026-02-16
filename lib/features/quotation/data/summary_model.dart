// lib/models/summary_model.dart
class PaymentSummary {
  final double totalAmount;
  final double subsidy;
  final double payableAfterSubsidy;
  final double specialOffer;
  final double finalPayableAmount;
  final double advance;
  final double afterInstallation;

  PaymentSummary({
    required this.totalAmount,
    this.subsidy = 78000,
    double? specialOffer,
    double? advance,
  })  : payableAfterSubsidy = totalAmount - subsidy,
        specialOffer = specialOffer ?? 0,
        finalPayableAmount = (totalAmount - subsidy) - (specialOffer ?? 0),
        advance = advance ?? 0,
        afterInstallation = ((totalAmount - subsidy) - (specialOffer ?? 0)) - (advance ?? 0);

  PaymentSummary copyWith({
    double? totalAmount,
    double? subsidy,
    double? specialOffer,
    double? advance,
  }) {
    return PaymentSummary(
      totalAmount: totalAmount ?? this.totalAmount,
      subsidy: subsidy ?? this.subsidy,
      specialOffer: specialOffer ?? this.specialOffer,
      advance: advance ?? this.advance,
    );
  }
}