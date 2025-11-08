import 'package:flutter/material.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
      ),
      body: ListView(
        children: const [
          ListTile(
            leading: Icon(Icons.card_giftcard),
            title: Text('Order #12345'),
            subtitle: Text('Delivered'),
          ),
          ListTile(
            leading: Icon(Icons.card_giftcard),
            title: Text('Order #67890'),
            subtitle: Text('In Transit'),
          ),
        ],
      ),
    );
  }
}
