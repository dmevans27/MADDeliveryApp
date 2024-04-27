import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'deliveryinfo.dart';
import 'login.dart';

class DriverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 215, 188, 106),
        title: Text('Customer Orders'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
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

              // Determine the status of the order
              var status = order?['status'];


              if (status == 'accepted') {
                return Card(
                  color: Colors.blue[100],
                  child: ListTile(
                    title: Text('Order ID: ${order?.id}'),
                    subtitle: Text('Customer: ${order?['customerName']}\nAddress: ${order?['userAddress']}'),
                  ),
                );
              } else {
                return Card(
                  color: Colors.green[100],
                  child: ListTile(
                    title: Text('Order ID: ${order?.id}'),
                    subtitle: Text('Customer: ${order?['customerName']}\nAddress: ${order?['userAddress']}'),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailsPage(orderId: order!.id),
                        ),
                      );
                    },
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
