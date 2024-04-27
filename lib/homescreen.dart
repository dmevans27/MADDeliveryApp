import 'package:deliveryapp/browse_res.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'navigation.dart';
import 'browse.dart'; // Import the browse.dart file

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _userName = '';
  List<Map<String, String>> recommendedRestaurants = [];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchRecommendedRestaurants();
    _fetchRecentOrders();
  }

  Future<void> _fetchUserName() async {
    try {
      String userId = _auth.currentUser!.uid;
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(userId).get();

      setState(() {
        _userName = userSnapshot['username'];
      });
    } catch (e) {
      print('Error fetching username: $e');
    }
  }

  Future<void> _fetchRecommendedRestaurants() async {
    try {
      QuerySnapshot restaurantSnapshot =
          await _firestore.collection('restaurants').get();

      setState(() {
        recommendedRestaurants = restaurantSnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': doc['name'] as String,
                  'description': doc['description'] as String,
                })
            .toList();
      });
    } catch (e) {
      print('Error fetching recommended restaurants: $e');
    }
  }

  // Sample data for recent orders
  List<String> recentOrders = [];

  Future<void> _fetchRecentOrders() async {
    try {
      QuerySnapshot ordersSnapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: _auth.currentUser!.uid)
          .orderBy('timestamp', descending: true)
          .limit(5)
          .get();

      setState(() {
        recentOrders =
            ordersSnapshot.docs.map((doc) => doc['orderId'] as String).toList();
      });
    } catch (e) {
      print('Error fetching recent orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navigation(),
      appBar: AppBar(
        title: const Text("Home Screen"),
        backgroundColor: Colors.red[200],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Welcome, $_userName!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          // Orders
          const Padding(
            
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Your Orders',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            
            child: StreamBuilder(
              
              stream: _firestore
                  .collection('users')
                  .doc(_auth.currentUser!.uid)
                  .collection('orders')
                  .orderBy('timestamp', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No orders found.');
                }

                var orders = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    var orderData = orders[index].data();
                    var orderId = orders[index].id;
                    var orderDate =
                        (orderData['timestamp'] as Timestamp).toDate();

                    return ListTile(
                      title: Text('Order ID: $orderId'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Date: ${orderDate.toString()}'),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Recommended Restaurants
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recommended Restaurants',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recommendedRestaurants.length,
              itemBuilder: (context, index) {
                var restaurant = recommendedRestaurants[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to browse_res.dart page when a restaurant is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestaurantDetails(
                          restaurantId: restaurant['id']!,
                          restaurantName: restaurant['name']!,
                        ),
                      ),
                    );
                  },
                  child: ListTile(
                    title: Text(restaurant['name']!),
                    subtitle: Text(restaurant['description']!),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
