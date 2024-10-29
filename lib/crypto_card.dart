// crypto_card.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter_dismissible_tile/flutter_dismissible_tile.dart';
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(18.0, 18.0, 18.0, 0),
      child: DismissibleTile(
        key: ValueKey(cardData),
        direction: DismissibleTileDirection.horizontal,
        padding: const EdgeInsets.symmetric(vertical: 8),
        borderRadius: BorderRadius.circular(10),
        delayBeforeResize: Duration(milliseconds: 300),

        // Swipe background for left-to-right (Edit) and right-to-left (Delete)
        ltrBackground: buildSwipeActionLeft(),
        rtlBackground: buildSwipeActionRight(),

        // Overlays for showing text and icons while swiping
        ltrOverlay: _SlidableOverlay(
          title: 'Edit',
          iconData: CupertinoIcons.pencil,
        ),
        rtlOverlay: _SlidableOverlay(
          title: 'Delete',
          iconData: CupertinoIcons.delete,
        ),

        // Confirm dismissal logic
        confirmDismiss: (DismissibleTileDirection direction) async {
          if (direction == DismissibleTileDirection.leftToRight) {
            onEdit();
            return false; // Keep the item, just open the edit action
          } else if (direction == DismissibleTileDirection.rightToLeft) {
            bool confirmDelete = await showCupertinoDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return CupertinoAlertDialog(
                  title: Text('Delete'),
                  content: Text('Are you sure you want to delete this card?'),
                  actions: [
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text('Delete'),
                    ),
                    CupertinoDialogAction(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text('Cancel'),
                    ),
                  ],
                );
              },
            ) ??
                false;

            if (confirmDelete) {
              onRemove();
              return true; // Dismiss the widget
            } else {
              return false; // Do not dismiss the widget
            }
          }
          return false;
        },
        onDismissed: (_) {
          // Additional cleanup if needed
        },
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey5,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 28.0),
              child: Text(
                '1 ${cardData.coin} = $priceText ${cardData.currency}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20.0,
                  color: CupertinoColors.label,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSwipeActionLeft() {
    // Background when swiping left-to-right for editing
    return Container(
      color: CupertinoColors.activeBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(width: 20),
          Icon(CupertinoIcons.pencil, color: CupertinoColors.white),
          SizedBox(width: 10),
          Text('Edit', style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget buildSwipeActionRight() {
    // Background when swiping right-to-left for deleting
    return Container(
      color: CupertinoColors.systemRed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text('Delete', style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold)),
          SizedBox(width: 10),
          Icon(CupertinoIcons.delete, color: CupertinoColors.white),
          SizedBox(width: 20),
        ],
      ),
    );
  }
}

class _SlidableOverlay extends StatelessWidget {
  final String title;
  final IconData iconData;

  const _SlidableOverlay({
    required this.title,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: title == 'Edit' ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: title == 'Edit' ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (title == 'Edit') ...[
            Icon(iconData, color: CupertinoColors.white),
            SizedBox(width: 10),
            Text(title, style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold)),
          ] else ...[
            Text(title, style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            Icon(iconData, color: CupertinoColors.white),
          ],
        ],
      ),
    );
  }
}