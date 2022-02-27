class Account {
  final String currency;
  final double balance;

  const Account({
    required this.currency,
    required this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(currency: json['currency'] as String, balance: double.parse(json['balance']));
  }
}
