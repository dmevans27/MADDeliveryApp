import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navigation.dart';

class Browse extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;

  const Browse({
    Key? key,
    required this.restaurantId,
    required this.restaurantName,
  }) : super(key: key);

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurantName),
        backgroundColor: Colors.pink[100],
      ),
      body: _buildItemsList(),
    );
  }

  Widget _buildItemsList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('restaurants')
          .doc(widget.restaurantId)
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
            String itemName = data['name'] ?? '';
            double itemPrice =
                data['price'] != null ? data['price'].toDouble() : 0.0;
            return ListTile(
              title: Text(itemName),
              subtitle: Text('\$${itemPrice.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: Icon(Icons.add_shopping_cart),
                onPressed: () => _addItemToCart(document.id),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  void _addItemToCart(String itemId) async {
    try {
      // Get the currently logged-in user
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        String userId = user.uid;

        // Add item to the user's cart
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('carts')
            .doc(itemId)
            .set({
          'itemId': itemId,
          // Add any other item details you want to store in the cart
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item added to cart')),
        );
      } else {
        // No user is logged in
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user logged in')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add item to cart: $error')),
      );
    }
  }
}
