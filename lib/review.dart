import 'package:deliveryapp/homescreen.dart';
import 'package:deliveryapp/navigation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({Key? key});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage>
{
 final TextEditingController _titleController = TextEditingController();
final TextEditingController _commentController = TextEditingController();
int _rating = 0; // Default rating
String _selectedRestaurant = ''; // Default selected restaurant
List<String> _restaurants = []; // List of restaurants from Firestore

@override
void initState() {
  super.initState();
  _fetchRestaurants(); // Fetch restaurants from Firestore when the widget initializes
}

Future<void> _fetchRestaurants() async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('restaurants').get();
    setState(() {
      _restaurants = snapshot.docs.map((doc) => doc.id).toList(); // Get the document IDs (restaurant names)
      _selectedRestaurant = _restaurants.isNotEmpty ? _restaurants.first : ''; // Set the first restaurant as default
    });
  } catch (error) {
    print('Error fetching restaurants: $error');
  }
}

Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Submit Restaurant Review'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _commentController,
            decoration: const InputDecoration(labelText: 'Comment'),
            maxLines: null, // Allow multiline input
          ),
          const SizedBox(height: 20),
          _buildRestaurantDropdown(), // Dropdown menu for selecting restaurant
          const SizedBox(height: 20),
          _buildRatingBar(), // Rating bar widget
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _submitReview(context);
            },
            child: const Text('Submit Review'),
          ),
        ],
      ),
    ),
  );
}

Widget _buildRestaurantDropdown() {
  return DropdownButtonFormField<String>(
    value: _selectedRestaurant,
    items: _restaurants.map((String restaurant) {
      return DropdownMenuItem<String>(
        value: restaurant,
        child: Text(restaurant),
      );
    }).toList(),
    onChanged: (value) {
      setState(() {
        _selectedRestaurant = value!;
      });
    },
    decoration: const InputDecoration(labelText: 'Select Restaurant'),
  );
}

Widget _buildRatingBar() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text('Rating: '),
      IconButton(
        icon: Icon(Icons.star, color: _rating >= 1 ? Colors.orange : Colors.grey),
        onPressed: () {
          setState(() {
            _rating = 1;
          });
        },
      ),
      IconButton(
        icon: Icon(Icons.star, color: _rating >= 2 ? Colors.orange : Colors.grey),
        onPressed: () {
          setState(() {
            _rating = 2;
          });
        },
      ),
      IconButton(
        icon: Icon(Icons.star, color: _rating >= 3 ? Colors.orange : Colors.grey),
        onPressed: () {
          setState(() {
            _rating = 3;
          });
        },
      ),
      IconButton(
        icon: Icon(Icons.star, color: _rating >= 4 ? Colors.orange : Colors.grey),
        onPressed: () {
          setState(() {
            _rating = 4;
          });
        },
      ),
      IconButton(
        icon: Icon(Icons.star, color: _rating >= 5 ? Colors.orange : Colors.grey),
        onPressed: () {
          setState(() {
            _rating = 5;
          });
        },
      ),
    ],
  );
}

void _submitReview(BuildContext context) async {
  // Retrieve form data
  String title = _titleController.text.trim();
  String comment = _commentController.text.trim();

  // Validate input
  if (title.isEmpty || comment.isEmpty || _rating == 0 || _selectedRestaurant.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please provide a title, comment, rating, and select a restaurant.')),
    );
    return;
  }

  // Add the review to Firestore
  try {
    await FirebaseFirestore.instance.collection('restaurants').doc(_selectedRestaurant).collection('reviews').add({
      'title': title,
      'comment': comment,
      'rating': _rating,
      // Add other fields such as userId, timestamp, etc.
    });
    Navigator.pop(context); // Return to the previous page
  } catch (error) {
    // Handle errors
    print('Error submitting review: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit review. Please try again later.')),
    );
  }
}
}