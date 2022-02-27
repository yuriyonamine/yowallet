class Transfer {
  final String id;
  final String type;
  final double amount;

  const Transfer({
    required this.id,
    required this.type,
    required this.amount,
  });

  factory Transfer.fromJson(Map<String, dynamic> json) {
    return Transfer(
      id: json['id'] as String,
      type: json['type'] as String,
      amount: double.parse(json['amount']),
    );
  }
}
