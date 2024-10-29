// crypto_card.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'card_data.dart';

class CryptoCard extends StatelessWidget {
  final CardData cardData;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  final VoidCallback onEdit;

  CryptoCard({
    required this.cardData,
    required this.onTap,
    required this.onRemove,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    String priceText = cardData.price != null
        ? cardData.price!.toStringAsFixed(2)
        : '?';

    String changeText = '';
    Color changeColor = CupertinoColors.label;

    if (cardData.dailyChange != null) {
      changeText = cardData.dailyChange! > 0
          ? '+${cardData.dailyChange!.toStringAsFixed(2)}% (1d)'
          : '${cardData.dailyChange!.toStringAsFixed(2)}% (1d)';
      changeColor = cardData.dailyChange! > 0
          ? CupertinoColors.systemGreen
          : CupertinoColors.systemRed;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Dismissible(
        key: ValueKey(cardData),
        direction: DismissDirection.horizontal,
        background: buildSwipeActionLeft(),
        secondaryBackground: buildSwipeActionRight(),

        confirmDismiss: (DismissDirection direction) async {
          if (direction == DismissDirection.startToEnd) {
            onEdit();
            return false;
          } else if (direction == DismissDirection.endToStart) {
            return true;
          }
          return false;
        },

        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            onRemove();
          }
        },

        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(10.0),
            ),
            padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
            child: Column(
              children: [
                Text(
                  '1 ${cardData.coin} = $priceText ${cardData.currency}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20.0,
                    color: CupertinoColors.label,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  changeText,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: changeColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSwipeActionLeft() {
    return Container(
      color: CupertinoColors.activeBlue,
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(CupertinoIcons.pencil, color: CupertinoColors.white),
          SizedBox(width: 8),
          Text('Edit', style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildSwipeActionRight() {
    return Container(
      color: CupertinoColors.systemRed,
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Delete', style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Icon(CupertinoIcons.delete, color: CupertinoColors.white),
        ],
      ),
    );
  }
}