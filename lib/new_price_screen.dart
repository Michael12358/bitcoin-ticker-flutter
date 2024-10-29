// new_price_screen.dart

import 'package:flutter/cupertino.dart';
import 'card_data.dart';
import 'networking.dart';
import 'crypto_card.dart';
import 'card_config_dialog.dart';

class PriceScreen extends StatefulWidget {
  @override
  _PriceScreenState createState() => _PriceScreenState();
}

class _PriceScreenState extends State<PriceScreen> {
  List<CardData> cards = [];
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
    cards.add(CardData());
    updatePrices();
  }

  void updatePrices() async {
    if (isFetching) return;
    setState(() {
      isFetching = true;
    });

    NetworkHelper networkHelper = NetworkHelper();

    try {
      Map<String, CardData> updatedData = await networkHelper.getMultipleCoinData(cards);

      setState(() {
        for (CardData card in cards) {
          String key = card.coin.toUpperCase() + '_' + card.currency.toUpperCase();
          if (updatedData.containsKey(key)) {
            card.price = updatedData[key]!.price;
            card.dailyChange = updatedData[key]!.dailyChange;
          }
        }
      });
    } catch (e) {
      print('Error fetching prices: $e');
      showCupertinoDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text('Error'),
          content: Text('Error fetching prices. Please try again later.'),
          actions: [
            CupertinoDialogAction(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        isFetching = false;
      });
    }
  }

  void openEditDialog(CardData cardData, int index) async {
    CardData? updatedCardData = await showCupertinoModalPopup<CardData>(
      context: context,
      builder: (context) => CardConfigDialog(
        cardData: cardData,
      ),
    );

    if (updatedCardData != null) {
      setState(() {
        cards[index] = updatedCardData;
      });
      updatePrices();
    }
  }

  Widget buildAddCardButton() {
    return CupertinoButton.filled(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      onPressed: isFetching ? null : () {
        setState(() {
          cards.add(CardData());
        });
        updatePrices();
      },
      child: Text(
        'Add Card',
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  Widget buildRefreshButton() {
    return CupertinoButton.filled(
      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      onPressed: isFetching ? null : updatePrices,
      child: isFetching
          ? CupertinoActivityIndicator()
          : Text(
        'Refresh',
        style: TextStyle(fontSize: 16.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Coin Ticker'),
      ),
      child: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: isFetching && cards.isEmpty
                  ? Center(child: CupertinoActivityIndicator())
                  : ListView.builder(
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  CardData cardData = cards[index];
                  return CryptoCard(
                    cardData: cardData,
                    onTap: () => openEditDialog(cardData, index),
                    onRemove: () {
                      setState(() {
                        cards.removeAt(index);
                      });
                      updatePrices();
                    },
                    onEdit: () => openEditDialog(cardData, index), // Trigger edit dialog
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: buildAddCardButton()),
                  SizedBox(width: 10),
                  Expanded(child: buildRefreshButton()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}