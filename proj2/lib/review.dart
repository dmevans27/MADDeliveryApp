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
      _restaurants = snapshot.docs
    .map((doc) => (doc.data() as Map<String, dynamic>)['name'] ?? 'No Name')
    .toList()
    .cast<String>(); // Cast the list to List<String>the 'name' field of each document if it exists, otherwise use 'No Name'
      _selectedRestaurant = _restaurants.isNotEmpty ? _restaurants.first : ''; // Set the first restaurant as default
    });
  } catch (error) {
    print('Error fetching restaurants: $error');
  }
}



Widget build(BuildContext context) {
  return Scaffold(
    drawer: const Navigation(),
    appBar: AppBar(
      backgroundColor: Colors.green[200],
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

  try {
    // Query for the restaurant document based on the selected restaurant name
    QuerySnapshot restaurantQuery = await FirebaseFirestore.instance.collection('restaurants')
      .where('name', isEqualTo: _selectedRestaurant)
      .get();

    // Check if any restaurant documents match the selected name
    if (restaurantQuery.docs.isNotEmpty) {
      // Get the first matching restaurant document
      DocumentSnapshot restaurantSnapshot = restaurantQuery.docs.first;

      // Explicitly cast data to a map
      Map<String, dynamic>? data = restaurantSnapshot.data() as Map<String, dynamic>?;

      // Check if data is not null and contains the 'numberOfReviews' field
      if (data != null && data.containsKey('numberOfReviews')) {
        // Get the current number of reviews
        int numberOfReviews = data['numberOfReviews'] ?? 0;

        // Increment the number of reviews
        numberOfReviews++;

        // Add the review document to the 'reviews' subcollection of the selected restaurant document
        await restaurantSnapshot.reference.collection('reviews').doc('review$numberOfReviews').set({
          'title': title,
          'comment': comment,
          'rating': _rating,
          // Add other fields such as userId, timestamp, etc.
        });

        // Update the number of reviews in the restaurant document
        await restaurantSnapshot.reference.update({'numberOfReviews': numberOfReviews});

        // Navigate back to the home screen after submitting the review
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restaurant document is missing the numberOfReviews field.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected restaurant does not exist.')),
      );
    }
  } catch (error) {
    // Handle errors
    print('Error submitting review: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to submit review. Please try again later.')),
    );
  }
}
}