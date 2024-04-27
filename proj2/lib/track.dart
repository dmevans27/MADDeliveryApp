import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'navigation.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navigation(),
      appBar: AppBar(
        title: const Text("Track Your Order"),
        backgroundColor: Colors.blue[50],
      ),
      body: _buildOrderList(),
    );
  }

  Widget _buildOrderList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('cus_orders')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No orders found'),
          );
        }

        List<DocumentSnapshot> orders = snapshot.data!.docs;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var order = orders[index];
            var orderId = order.id;
            var orderDate =
                (order['timestamp'] as Timestamp).toDate().toString();
            var orderStatus = order['status'] ?? 'Status not available';

            return ListTile(
              title: Text('Order ID: $orderId'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order Date: $orderDate'),
                  Text('Status: $orderStatus'),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
