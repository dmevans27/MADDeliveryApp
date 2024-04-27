import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'navigation.dart';

class PlaceOrder extends StatefulWidget {
  const PlaceOrder({super.key});

  @override
  State<PlaceOrder> createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navigation(),
      appBar: AppBar(
        title: const Text("Check Order"),
        backgroundColor: Colors.purple[100],
      ),
      body: _buildCartList(),
    );
  }

  Widget _buildCartList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('cart')
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
            child: Text('No items in cart'),
          );
        }

        List<DocumentSnapshot> cartItems = snapshot.data!.docs;

        // Calculate total price
        double totalPrice = 0;
        for (var item in cartItems) {
          totalPrice += (item['itemPrice'] as num).toDouble();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (context, index) {
                  var item = cartItems[index];
                  return ListTile(
                    title: Text(item['itemName']),
                    subtitle: Text('\$${item['itemPrice'].toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Total: \$${totalPrice.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 20), // Adjust the width as needed
                  ElevatedButton(
                    onPressed: () {
                      _placeOrder(cartItems, totalPrice);
                    },
                    child: Text('Place Order'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _placeOrder(List<DocumentSnapshot> cartItems, double totalPrice) async {
    try {
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userData = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    String userName = userData['FirstName'] + ' ' + userData['LastName'];
      CollectionReference ordersCollection =
          FirebaseFirestore.instance.collection('cus_orders');
      

      // Create a new order document with status 'preparing'
      DocumentReference newOrderRef = await ordersCollection.add({
        'customerName': userName,
        'totalPrice': totalPrice,
        'status': 'preparing', // Set the status here
        'items': cartItems.map((item) => item.data()).toList(),
        'timestamp': Timestamp.now(),
      });

      // Store the reference to the order document in the user's collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders')
          .doc(newOrderRef.id) // Use the order document ID as the reference
          .set({
        'orderId': newOrderRef.id,
        'timestamp': Timestamp.now(),
      });

      // Delete items from the user's cart
      await Future.forEach(cartItems, (item) async {
        await item.reference.delete();
      });

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order placed successfully!')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to place order: $error')),
      );
    }
  }
}
