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
    // Start with an empty list; user adds cards manually
  }

  void updatePrices() async {
    if (isFetching) return;
    setState(() {
      isFetching = true;
    });

    NetworkHelper networkHelper = NetworkHelper();

    try {
      Map<String, double> prices =
          await networkHelper.getMultipleCoinData(cards);
      setState(() {
        for (CardData card in cards) {
          String key =
              card.coin.toUpperCase() + '_' + card.currency.toUpperCase();
          card.price = prices[key];
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

  Widget buildAddCardButton() {
    return SizedBox(
      width: 140,
      child: CupertinoButton.filled(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        onPressed: isFetching
            ? null
            : () async {
                // Open the CardConfigDialog to configure the new card
                CardData newCard = CardData();

                CardData? configuredCard =
                    await showCupertinoModalPopup<CardData>(
                  context: context,
                  builder: (context) => CardConfigDialog(
                    cardData: newCard,
                  ),
                );

                // If the user saved the configuration, add the card and update prices
                if (configuredCard != null) {
                  setState(() {
                    cards.add(configuredCard);
                  });
                  updatePrices();
                }
              },
        child: Text(
          'Add Card',
          style: TextStyle(fontSize: 16.0),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget buildRefreshButton() {
    return SizedBox(
      width: 140,
      child: CupertinoButton.filled(
        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        onPressed: isFetching ? null : updatePrices,
        child: isFetching
            ? CupertinoActivityIndicator()
            : Text(
                'Refresh',
                style: TextStyle(fontSize: 16.0),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
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
              child: cards.isEmpty
                  ? Center(
                      child: Text(
                        'No cards added. Tap "Add Card" to get started.',
                        style: TextStyle(
                            fontSize: 18.0, color: CupertinoColors.systemGrey),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: cards.length,
                      itemBuilder: (context, index) {
                        CardData cardData = cards[index];
                        return CryptoCard(
                          cardData: cardData,
                          onTap: () {
                            // Handle tap if needed
                          },
                          onEdit: () async {
                            // Open configuration dialog to edit the card
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
                          },
                          onRemove: () {
                            setState(() {
                              cards.removeAt(index);
                            });
                            updatePrices();
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  buildAddCardButton(),
                  SizedBox(width: 10),
                  buildRefreshButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
