// networking.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'card_data.dart';

const Map<String, String> cryptoCoinGeckoIds = {
  'BTC': 'bitcoin',
  'ETH': 'ethereum',
  'LTC': 'litecoin',
  // Add more coins as needed
};

class NetworkHelper {
  Future<Map<String, double>> getMultipleCoinData(List<CardData> cards) async {
    // Map coin symbols to CoinGecko IDs and collect unique coin IDs and currencies
    Set<String> coinIdsSet = {};
    Set<String> currenciesSet = {};
    Map<String, String> symbolToIdMap = {};

    for (CardData card in cards) {
      String symbol = card.coin.toUpperCase();
      String currency = card.currency.toLowerCase();
      String? coinId = cryptoCoinGeckoIds[symbol];
      if (coinId != null) {
        symbolToIdMap[symbol] = coinId;
        coinIdsSet.add(coinId);
      } else {
        throw 'Unsupported coin symbol: $symbol';
      }
      currenciesSet.add(currency);
    }

    String coinIdsParam = coinIdsSet.join(',');
    String currenciesParam = currenciesSet.join(',');

    String requestURL =
        'https://api.coingecko.com/api/v3/simple/price?ids=$coinIdsParam&vs_currencies=$currenciesParam';

    http.Response response = await http.get(Uri.parse(requestURL));

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);

      Map<String, double> prices = {};
      for (CardData card in cards) {
        String symbol = card.coin.toUpperCase();
        String currency = card.currency.toLowerCase();
        String coinId = symbolToIdMap[symbol]!;
        dynamic priceData = decodedData[coinId][currency];
        if (priceData != null) {
          double price = priceData + 0.0;
          prices[symbol + '_' + currency.toUpperCase()] = price;
        } else {
          prices[symbol + '_' + currency.toUpperCase()] = 0.0; // Handle missing data
        }
      }
      return prices;
    } else {
      print('Failed to get data: ${response.statusCode}');
      throw 'Problem with the get request';
    }
  }
}