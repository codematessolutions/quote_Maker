class QuotationItem {
  final String material;
  final String brand;
  final int warranty;
  final int rating;
  final int qty;
  final int watt;
  final double price;

  QuotationItem({
    required this.material,
    required this.brand,
    required this.warranty,
    required this.rating,
    required this.qty,
    required this.watt,
    required this.price,
  });

  double get total => qty * price;

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
}
