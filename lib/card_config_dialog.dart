// card_config_dialog.dart

import 'package:flutter/cupertino.dart';
import 'card_data.dart';
import 'coin_data.dart';

class CardConfigDialog extends StatefulWidget {
  final CardData cardData;

  CardConfigDialog({required this.cardData});

  @override
  _CardConfigDialogState createState() => _CardConfigDialogState();
}

class _CardConfigDialogState extends State<CardConfigDialog> {
  late String selectedCoin;
  late String selectedCurrency;

  @override
  void initState() {
    super.initState();
    selectedCoin = widget.cardData.coin;
    selectedCurrency = widget.cardData.currency;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoActionSheet(
      title: Text('Configure Card'),
      message: Container(
        height: 250,
        child: Column(
          children: [
            // Labels
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Coin',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Currency',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            // Pickers
            Expanded(
              child: Row(
                children: [
                  // Coin Picker
                  Expanded(
                    child: CupertinoPicker(
                      backgroundColor: CupertinoColors.systemBackground,
                      itemExtent: 32.0,
                      scrollController: FixedExtentScrollController(
                        initialItem: cryptoList.indexOf(selectedCoin),
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedCoin = cryptoList[index];
                        });
                      },
                      children: cryptoList.map((coin) => Center(child: Text(coin))).toList(),
                    ),
                  ),
                  // Currency Picker
                  Expanded(
                    child: CupertinoPicker(
                      backgroundColor: CupertinoColors.systemBackground,
                      itemExtent: 32.0,
                      scrollController: FixedExtentScrollController(
                        initialItem: currenciesList.indexOf(selectedCurrency),
                      ),
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedCurrency = currenciesList[index];
                        });
                      },
                      children: currenciesList.map((currency) => Center(child: Text(currency))).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        CupertinoActionSheetAction(
          child: Text('Save'),
          onPressed: () {
            Navigator.of(context).pop(CardData(
              coin: selectedCoin,
              currency: selectedCurrency,
            ));
          },
        ),
        CupertinoActionSheetAction(
          child: Text('Cancel'),
          isDestructiveAction: true,
          onPressed: () {
            Navigator.of(context).pop(null);
          },
        ),
      ],
    );
  }
}