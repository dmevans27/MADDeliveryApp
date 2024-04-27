import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  final bool isAcceptedTab;

  OrderDetailsPage({required this.orderId, this.isAcceptedTab = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 104, 193, 213),
        title: Text('Order Details'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('cus_orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return Center(child: Text("No data available"));
          }
          var order = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customer: ${order['customerName']}'),
                Text('User Address: ${order['userAddress']}'),
                Text('Time Placed: ${order['timestamp']}'),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => isAcceptedTab ? _completeOrder(context, orderId) : _acceptOrder(context, orderId), 
                  child: Text(isAcceptedTab ? 'Order Complete' : 'Accept Order'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _acceptOrder(BuildContext context, String orderId) async {
    try {
      String driverId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('cus_orders').doc(orderId).update({
        'status': 'on the way',
        'driverId': driverId,
      });

      // Optionally update any other relevant details or databases.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order accepted successfully!')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept order: $error')),
      );
    }
  }

  void _completeOrder(BuildContext context, String orderId) async {
    try {
      await FirebaseFirestore.instance.collection('cus_orders').doc(orderId).update({
        'status': 'delivered',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as complete!')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete order: $error')),
      );
    }
  }
}
