import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantDetails extends StatelessWidget {
  final String restaurantId;
  final String restaurantName;

  const RestaurantDetails({
    Key? key,
    required this.restaurantId,
    required this.restaurantName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(restaurantName),
        backgroundColor: Colors.pink[100],
      ),
      body: _buildItemsList(context),
    );
  }

  Widget _buildItemsList(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .collection('products')
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
            child: Text('No items available'),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String itemId = document.id;
            String itemName = data['name'] ?? '';
            double itemPrice =
                data['price'] != null ? data['price'].toDouble() : 0.0;
            return ListTile(
              title: Text(itemName),
              subtitle: Text('\$${itemPrice.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: Icon(Icons.shopping_cart),
                onPressed: () =>
                    _addItemToCart(context, itemId, itemName, itemPrice),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _addItemToCart(BuildContext context, String itemId, String itemName,
      double itemPrice) async {
    try {
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        // Add item to the user's cart in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc(itemId)
            .set({
          'itemName': itemName,
          'itemPrice': itemPrice,
          // Add any other item details you want to store in the cart
        });

        // Show a snackbar to indicate that the item has been added to the cart
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item added to cart')),
        );
      } else {
        // No user is logged in, prompt the user to log in
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please log in to add items to cart')),
        );
      }
    } catch (error) {
      // Show an error snackbar if adding item to cart fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item to cart: $error')),
      );
    }
  }
}
