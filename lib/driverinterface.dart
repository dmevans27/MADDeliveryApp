import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'deliveryinfo.dart'; // Assuming this file contains the OrderDetailsPage
import 'login.dart';

class DriverPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final User? currentUser =
        FirebaseAuth.instance.currentUser; // Ensure the user is logged in

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 215, 188, 106),
          title: Text('Customer Orders'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Available Orders'),
              Tab(text: 'Accepted Orders'),
            ],
          ),
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
        body: TabBarView(
          children: [
            // Tab for Available Orders - Using the original code you provided
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('cus_orders')
                  .where('status', isEqualTo: 'preparing')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No available orders'));
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                        
                    return Card(
                      color: Colors.green[100],
                      child: ListTile(
                        title: Text('Order ID: ${document.id}'),
                        subtitle: Text(
                            'Customer: ${data['customerName']}\nAddress: ${data['userAddress']}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsPage(
                                  orderId: document.id, isAcceptedTab: false),
                            ),
                          );
                        },
                      ),
                    );
                        
                  }).toList(),
                );
              },
            ),
            // Tab for Accepted Orders - Showing only orders that are "on the way" for the current driver
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('cus_orders')
                  .where('driverId', isEqualTo: currentUser?.uid)
                  .where('status', isEqualTo: 'on the way')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No orders on the way'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;
                    return Card(
                      color: Colors.blue[100],
                      child: ListTile(
                        title: Text('Order ID: ${doc.id}'),
                        subtitle: Text(
                            'Customer: ${data['customerName']}\nAddress: ${data['userAddress']}'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderDetailsPage(
                                  orderId: doc.id, isAcceptedTab: true),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
