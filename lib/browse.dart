import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navigation.dart';
import 'browse_res.dart';

class Browse extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurants'),
        backgroundColor: Colors.pink[100],
      ),
      drawer: Navigation(), // Add the Navigation widget here
      body: _buildRestaurantsList(context),
    );
  }

  Widget _buildRestaurantsList(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('restaurants').snapshots(),
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
            child: Text('No restaurants available'),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String restaurantName = data['name'] ?? '';
            String restaurantId = document.id;
            return ListTile(
              title: Text(restaurantName),
              onTap: () {
                // Navigate to a new page showing restaurant details
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantDetails(
                      restaurantId: restaurantId,
                      restaurantName: restaurantName,
                    ),
                  ),
                );
              },
            );
          }).toList(),
        );
      },
    );
  }
}
