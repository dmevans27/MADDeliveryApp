import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'deliveryinfo.dart';
class DriverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Customer Orders'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('cus_orders').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          var orders = snapshot.data?.docs;
          return ListView.builder(
            itemCount: orders?.length,
            itemBuilder: (context, index) {
              var order = orders?[index];
              return ListTile(
                title: Text('Order ID: ${order?.id}'),
                subtitle: Text('Customer: ${order?['customerName']}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsPage(orderId: order!.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}