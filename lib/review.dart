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
  int _rating = 0; // Default rating
late String _selectedItem;

@override
void initState() {
    super.initState();
    _selectedItem = _items.first;
  }

  
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  String _selectedReviewType = 'Driver'; // Default review type
  List<String> _items = ['Driver A', 'Driver B', 'Driver C']; // Sample list of drivers, replace with actual data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Review'),
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
            _buildReviewTypeDropdown(), // Dropdown menu for selecting review type
            const SizedBox(height: 20),
            _buildItemDropdown(), // Dropdown menu for selecting specific driver or restaurant
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

  Widget _buildReviewTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedReviewType,
      items: ['Driver', 'Restaurant'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedReviewType = value!;
          // Reset selected item when review type changes
          _selectedItem = '';
        });
      },
      decoration: const InputDecoration(labelText: 'Select Review Type'),
    );
  }

  Widget _buildItemDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedItem,
      items: _selectedReviewType == 'Driver'
          ? _items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList()
          : null, // Only show dropdown if review type is 'Driver'
      onChanged: (value) {
        setState(() {
          _selectedItem = value!;
        });
      },
      decoration: InputDecoration(
        labelText: _selectedReviewType == 'Driver' ? 'Select Driver' : 'Select Restaurant',
        enabled: _selectedReviewType == 'Driver', // Disable dropdown if review type is 'Restaurant'
      ),
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
    if (title.isEmpty || comment.isEmpty || _rating == 0 || _selectedItem.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a title, comment, rating, and select a driver or restaurant.')),
      );
      return;
    }

    // Add the review to Firestore
    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'title': title,
        'comment': comment,
        'rating': _rating,
        'reviewType': _selectedReviewType,
        'item': _selectedItem,
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
