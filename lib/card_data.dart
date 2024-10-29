// card_data.dart

class CardData {
  final String coin;
  final String currency;
  double? price;
  double? dailyChange; // New field for the daily change

  CardData({this.coin = 'BTC', this.currency = 'USD', this.price, this.dailyChange});
}