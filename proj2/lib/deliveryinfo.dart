import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;

  OrderDetailsPage({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 104, 193, 213),
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
                Text('User Address: ${order?['userAddress']}'),
                Text('Time Placed: ${order?['timestamp']}'),
        
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _acceptOrder(context, orderId); 
                  },
                  child: Text('Accept Order'),
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
    // Get the current user's ID
    String driverId = FirebaseAuth.instance.currentUser!.uid;

    // Update the status of the order to "on the way" and set the driver ID
    await FirebaseFirestore.instance.collection('cus_orders').doc(orderId).update({
      'status': 'on the way',
      'driverId': driverId,
    });

    // Add the order to the driver's accepted orders
    await FirebaseFirestore.instance.collection('drivers').doc(driverId).collection('accepted_orders').doc(orderId).set({
      'orderId': orderId,
      'acceptedTimestamp': Timestamp.now(),
    });

    // Show a success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order accepted successfully!')),
    );
  } catch (error) {
    // Show an error message if something goes wrong
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to accept order: $error')),
    );
  }
}
}