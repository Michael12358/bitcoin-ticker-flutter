// networking.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'card_data.dart';

const Map<String, String> cryptoCoinGeckoIds = {
  'BTC': 'bitcoin',
  'ETH': 'ethereum',
  'LTC': 'litecoin',
};

class NetworkHelper {
  Future<Map<String, CardData>> getMultipleCoinData(List<CardData> cards) async {
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
      }
      currenciesSet.add(currency);
    }

    String coinIdsParam = coinIdsSet.join(',');
    String currenciesParam = currenciesSet.join(',');

    String requestURL = 'https://api.coingecko.com/api/v3/simple/price?ids=$coinIdsParam&vs_currencies=$currenciesParam&include_24hr_change=true';

    http.Response response = await http.get(Uri.parse(requestURL));

    if (response.statusCode == 200) {
      var decodedData = jsonDecode(response.body);

      Map<String, CardData> prices = {};
      for (CardData card in cards) {
        String symbol = card.coin.toUpperCase();
        String currency = card.currency.toLowerCase();
        String coinId = symbolToIdMap[symbol]!;

        dynamic priceData = decodedData[coinId][currency];
        dynamic dailyChangeData = decodedData[coinId]['${currency}_24h_change'];

        if (priceData != null) {
          card.price = priceData + 0.0;
          card.dailyChange = dailyChangeData != null ? dailyChangeData + 0.0 : null;
          prices[symbol + '_' + currency.toUpperCase()] = card;
        }
      }
      return prices;
    } else {
      print('Failed to get data: ${response.statusCode}');
      throw 'Problem with the get request';
    }
  }
}