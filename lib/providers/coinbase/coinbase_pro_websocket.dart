import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:yowallet/models/current_coin_info.dart';

class CoinbaseProWebSocket {
  final coinbaseProWS = 'wss://ws-feed.pro.coinbase.com';

  void subscribeLiveCoinsUpdate(List<String> userCoinsJSON, Function update) {
    final channel = WebSocketChannel.connect(
      Uri.parse(coinbaseProWS),
    );

    channel.sink.add(
      jsonEncode(
        {
          "type": "subscribe",
          "channels": [
            {"name": "ticker", "product_ids": userCoinsJSON}
          ]
        },
      ),
    );

    channel.stream.listen(
      (data) {
        Map<String, dynamic> parsed = jsonDecode(data);
        if (parsed["type"] == "ticker") {
          CurrentCoinInfo currentCoinInfo = CurrentCoinInfo.fromJson(parsed);
          update(currentCoinInfo);
        }
      },
      onError: (error) => print(error),
    );
  }
}
