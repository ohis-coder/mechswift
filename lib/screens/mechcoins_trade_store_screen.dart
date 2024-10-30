import 'package:flutter/material.dart';

class MechCoinsTradeStoreScreen extends StatelessWidget {
  const MechCoinsTradeStoreScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MechCoins Trade Store"),
      ),
      body: Center(
        child: Text(
          "MechCoins store coming to you soon...",
          style: TextStyle(fontSize: 18, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
