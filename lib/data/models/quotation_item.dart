class QuotationItem {
  final String material;
  final String brand;
  final String warranty;
  final String rating;
  final int qty;
  final int watt;
  final double price;

  const QuotationItem({
    required this.material,
    required this.brand,
    required this.warranty,
    required this.rating,
    required this.qty,
    required this.watt,
    required this.price,
  });

  double get total => qty * price;

  QuotationItem copyWith({
    String? material,
    String? brand,
    String? warranty,
    String? rating,
    int? qty,
    int? watt,
    double? price,
  }) {
    return QuotationItem(
      material: material ?? this.material,
      brand: brand ?? this.brand,
      warranty: warranty ?? this.warranty,
      rating: rating ?? this.rating,
      qty: qty ?? this.qty,
      watt: watt ?? this.watt,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toJson() => {
    'material': material,
    'brand': brand,
    'warranty': warranty,
    'rating': rating,
    'qty': qty,
    'watt': watt,
    'price': price,
    'total': total,
  };

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      material: json['material'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      warranty: json['warranty'] as String? ?? '',
      rating: json['rating'] as String? ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      watt: (json['watt'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0,
    );
  }
}

