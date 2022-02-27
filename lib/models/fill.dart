class Fill {
  final String productId;
  final double price;
  final double size;
  final double fee;
  final String side;

  const Fill({
    required this.productId,
    required this.price,
    required this.size,
    required this.fee,
    required this.side,
  });

  factory Fill.fromJson(Map<String, dynamic> json) {
    return Fill(
      productId: json['product_id'] as String,
      price: double.parse(json['price']),
      size: double.parse(json['size']),
      fee: double.parse(json['fee']),
      side: json['side'] as String,
    );
  }
}
