// main.dart

import 'package:flutter/cupertino.dart';
import 'new_price_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Coin Ticker',
      theme: CupertinoThemeData(
        primaryColor: CupertinoColors.activeBlue,
      ),
      home: PriceScreen(),
    );
  }
}