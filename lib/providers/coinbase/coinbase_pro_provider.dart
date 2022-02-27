import 'dart:convert';

import 'package:yowallet/models/account.dart';
import 'package:yowallet/models/fill.dart';
import 'package:yowallet/models/transfer.dart';
import 'package:yowallet/models/user_coin.dart';
import 'package:yowallet/models/wallet_summary.dart';
import 'package:yowallet/providers/coinbase/coinbase_http_client_pro.dart';
import 'package:yowallet/providers/interfaces/crypto_provider.dart';

import 'coinbase_pro_websocket.dart';

class CoinbaseProProvider implements CryptoProvider {
  CoinbaseProHttpClient providerHttpClient = CoinbaseProHttpClient();
  CoinbaseProWebSocket coinbaseProWebSocket = CoinbaseProWebSocket();

  Future<WalletSummary> getWalletSummary(List<Account> accounts) async {
    // List<String> coins = getCoins();
    Map<String, UserCoin> userCoins = {};

    const userCurrency = "GBP";
    for (Account account in accounts) {
      if (userCurrency != account.currency) {
        String productId = buildProductId(account, userCurrency);
        Future<List<Fill>> fillsFuture = getFills(productId);
        // Future<List<Transfer>> transfersFuture = getTransfers();

        List<Fill> fills = await fillsFuture;

        //Remove this hack once the functionality to detect transfers are implemented
        if (account.currency == "ETH") {
          fills.add(Fill(productId: "ETH-GBP", price: 2573.40, size: 0.11210473, side: "buy", fee: 11.51));
        }

        userCoins[productId] = calculateSpentAmount(fills, productId, userCoins);
      }
    }

    return WalletSummary(userCoins);
  }

  UserCoin calculateSpentAmount(List<Fill> fills, String productId, Map<String, UserCoin> userCoins) {
    double totalSize = 0;
    double totalPrice = 0;
    double totalFee = 0;

    for (Fill fill in fills) {
      if (fill.side == "buy") {
        totalSize += fill.size;
        totalFee += fill.fee;
        totalPrice += (fill.price * fill.size) + fill.fee;
        productId = fill.productId;
      }
    }

    // List<Transfer> transfers = await transfersFuture;
    // for (Transfer transfer in transfers) {}
    return UserCoin(productId, totalSize, totalPrice, totalFee);
  }

  String buildProductId(Account account, String userCurrency) => account.currency + "-" + userCurrency;

  Future<List<Account>> getUserAccounts() async {
    String requestPath = "/accounts";

    var response = await providerHttpClient.get(requestPath);
    var accountsJSON = jsonDecode(response.body).cast<Map<String, dynamic>>();
    List<Account> accounts = accountsJSON.map<Account>((accountJSON) => Account.fromJson(accountJSON)).toList();
    List<Account> userAccounts = accounts.where((account) => account.balance > 0).toList();

    return userAccounts;
  }

  Future<List<Fill>> getFills(productId) async {
    String requestPath = "/fills?product_id=" + productId + "&profile_id=default&limit=100";

    var response = await providerHttpClient.get(requestPath);
    var fillsJSON = jsonDecode(response.body).cast<Map<String, dynamic>>();
    List<Fill> fills = fillsJSON.map<Fill>((fillJSON) => Fill.fromJson(fillJSON)).toList();

    return fills;
  }

  Future<List<Transfer>> getTransfers() async {
    String requestPath = "/transfers";

    var response = await providerHttpClient.get(requestPath);
    var transfersJSON = jsonDecode(response.body).cast<Map<String, dynamic>>();
    List<Transfer> transfers = transfersJSON.map<Transfer>((transferJSON) => Transfer.fromJson(transferJSON)).toList();

    return transfers;
  }

  void subscribeLiveCoinsUpdate(List<String> userCoinsJSON, Function update) {
    coinbaseProWebSocket.subscribeLiveCoinsUpdate(userCoinsJSON, update);
  }
}
