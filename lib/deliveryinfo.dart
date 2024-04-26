import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  OrderDetailsPage({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('cus_orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          var order = snapshot.data;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${order?['customerName']}'),
                Text('Restaurant Address: ${order?['restaurantAddress']}'),
                Text('Time Placed: ${order?['timePlaced']}'),
                // Add more details as needed
              ],
            ),
          );
        },
      ),
    );
  }
}
