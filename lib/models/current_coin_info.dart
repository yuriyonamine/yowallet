class CurrentCoinInfo {
  final String productId;
  final double price;

  const CurrentCoinInfo({required this.productId, required this.price});

  factory CurrentCoinInfo.fromJson(Map<String, dynamic> json) {
    return CurrentCoinInfo(
      productId: json['product_id'] as String,
      price: double.parse(json['price']),
    );
  }
}
