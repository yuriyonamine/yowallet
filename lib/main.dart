import 'package:flutter/material.dart';
import 'package:yowallet/providers/coinbase/coinbase_pro_provider.dart';

import 'models/current_coin_info.dart';
import 'models/wallet_summary.dart';
import 'providers/interfaces/crypto_provider.dart';

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
  //TODO include the transferences and remove the sold coins
  Map<String, double> amounts = {};
  WalletSummary investmentState = WalletSummary({});
  CryptoProvider cryptoService = CoinbaseProProvider();

  @override
  void initState() {
    super.initState();
    populateCoinPrices();
  }

  void populateCoinPrices() {
    CoinbaseProProvider().getUserAccounts().then((accounts) => {
          cryptoService
              .getWalletSummary(accounts)
              .then((walletSummary) => {
                    setState(() {
                      investmentState = walletSummary;
                    })
                  })
              .then((value) => subscribeLiveCoinsUpdate())
        });
  }

  void subscribeLiveCoinsUpdate() async {
    List<String> userCoinsJSON = investmentState.coinState.values.map((coin) => coin.productId).toList();
    void update(CurrentCoinInfo currentCoinInfo) => {
          setState(() {
            double coinsQuantity = investmentState.coinState[currentCoinInfo.productId]!.coinsQuantity;
            double currentValue = coinsQuantity * currentCoinInfo.price;
            amounts[currentCoinInfo.productId] = currentValue;
          })
        };
    cryptoService.subscribeLiveCoinsUpdate(userCoinsJSON, update);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Column(children: [
      Expanded(
          child: DataTable(
        columns: const [
          DataColumn(label: Text("Product Id", style: TextStyle(fontSize: 18))),
          DataColumn(label: Text("Invested", style: TextStyle(fontSize: 18))),
          DataColumn(label: Text("Value", style: TextStyle(fontSize: 18))),
        ],
        rows: [
          for (var investment in investmentState.coinState.values)
            DataRow(cells: [
              DataCell(Text(investment.productId, style: const TextStyle(fontSize: 18))),
              DataCell(Text(investment.totalInvested.toStringAsFixed(2), style: const TextStyle(fontSize: 18))),
              DataCell(Text(amounts[investment.productId] != null ? amounts[investment.productId]!.toStringAsFixed(2) : "not available",
                  style: const TextStyle(fontSize: 18))),
            ])
        ],
      )),
    ]));
  }
}
