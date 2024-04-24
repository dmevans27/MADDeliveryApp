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
  List<String> recentOrders = [
    "Order 1",
    "Order 2",
    "Order 3",
    "Order 4",
    "Order 5"
  ];

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
          // Recent Orders
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Recent Orders',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: recentOrders.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(recentOrders[index]),
                  subtitle: const Text('Order details...'),
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
                    // Navigate to browse.dart page when a restaurant is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Browse(
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
