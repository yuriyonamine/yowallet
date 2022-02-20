import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Yo Wallet'),
          ),
          body: const MainPage()),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  double coinsQuantity = 0;
  double totalInvested = 0;
  String apiKey = "";
  String secret = "";
  String passphrase = "";

  // ISO 8601
  void value() async {
    CryptoProvider cryptoService = CryptoProvider();
    InvestmentState? investmentState = cryptoService.getInvestimentsState();

    String requestMethod = "GET";
    String requestPath =
        "/fills?product_id=ETH-GBP&profile_id=default&limit=100";
    String requestBody = "";
    int requestTimestamp =
        DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    String message =
        requestTimestamp.toString() + requestMethod + requestPath + requestBody;

    List<int> apiKeyDecode = base64.decode(secret);
    Hmac hmac = Hmac(sha256, apiKeyDecode);
    Digest digest = hmac.convert(utf8.encode(message));
    String signature = base64.encode(digest.bytes);

    Uri url = Uri.parse('https://api.exchange.coinbase.com' + requestPath);
    Map<String, String> headers = {
      "CB-ACCESS-SIGN": signature,
      "CB-ACCESS-TIMESTAMP": requestTimestamp.toString(),
      "CB-ACCESS-KEY": apiKey,
      'CB-ACCESS-PASSPHRASE': passphrase
    };
    var response = await http.get(url, headers: headers);

    final parsed = jsonDecode(response.body).cast<Map<String, dynamic>>();
    var fills = parsed.map<Fill>((json) => Fill.fromJson(json)).toList();
    double totalSize = 0;
    double totalPrice = 0;
    for (Fill fill in fills) {
      totalSize += fill.size;
      totalPrice += fill.price * fill.size;
    }

    setState(() {
      coinsQuantity = totalSize;
      totalInvested = totalPrice;
    });
    print(totalSize);
    print((2896.03 - totalPrice) * 100 / 2894.95);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Ethereum', style: TextStyle(fontSize: 20)),
        Text('Coins quantity: $coinsQuantity', style: TextStyle(fontSize: 20)),
        Text('Total invested: $totalInvested', style: TextStyle(fontSize: 20)),
        Text('Current amount:', style: TextStyle(fontSize: 20)),
        TextButton(
          onPressed: () {
            value();
          },
          child: Text('Update'),
        ),
      ],
    );
  }
}

class InvestmentState {
  List<CoinState> coinState;

  InvestmentState(this.coinState);
}

class CoinState {
  String coinName;
  double coinsQuantity;
  double totalInvested;

  CoinState(this.coinName, this.coinsQuantity, this.totalInvested);
}

class CryptoProvider {
  InvestmentState? getInvestimentsState() {
    return null;
  }
}

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
