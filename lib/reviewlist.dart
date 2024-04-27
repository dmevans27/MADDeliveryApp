import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'deliveryinfo.dart'; // Assuming this file contains the OrderDetailsPage
import 'login.dart';
import 'navigation.dart';
import 'reviewlistdetails.dart';

class ReviewList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
        drawer: Navigation(),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 215, 188, 106),
          title: Text('Restaurant Reviews'),
          
         
        ),
        body:       
            // Tab for Available Orders - Using the original code you provided
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('restaurants')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No restaurants'));
                }

                return ListView(
                  children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return Card(
                      color: Colors.green[100],
                      child: ListTile(
                        title: Text('Restaurant: ${document.id}'),
                        subtitle: Text(
                            'Restaurant: ${data['name']}\nAddress: ${data['description']}'),
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
            
          
        );
      
  }
}
