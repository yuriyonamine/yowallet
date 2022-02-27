import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class CoinbaseProHttpClient {
  String host = "https://api.exchange.coinbase.com";
  String apiKey = "";
  String secret = "";
  String passphrase = "";

  Future<Response> get(String requestPath) {
    Map<String, String> headers = getAuthenticationHeaders("GET", requestPath, "");
    Uri url = Uri.parse(host + requestPath);

    return http.get(url, headers: headers);
  }

  Map<String, String> getAuthenticationHeaders(String requestMethod, String requestPath, String requestBody) {
    int requestTimestamp = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    String message = requestTimestamp.toString() + requestMethod + requestPath + requestBody;

    List<int> apiKeyDecode = base64.decode(secret);
    Hmac hmac = Hmac(sha256, apiKeyDecode);
    Digest digest = hmac.convert(utf8.encode(message));
    String signature = base64.encode(digest.bytes);

    Map<String, String> headers = {
      "CB-ACCESS-SIGN": signature,
      "CB-ACCESS-TIMESTAMP": requestTimestamp.toString(),
      "CB-ACCESS-KEY": apiKey,
      'CB-ACCESS-PASSPHRASE': passphrase
    };

    return headers;
  }
}
