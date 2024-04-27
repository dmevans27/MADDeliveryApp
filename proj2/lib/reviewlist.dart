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
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('restaurants').snapshots(),
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
            children: snapshot.data!.docs.map((DocumentSnapshot restaurantDoc) {
              Map<String, dynamic> restaurantData =
                  restaurantDoc.data() as Map<String, dynamic>;

              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('restaurants')
                    .doc(restaurantDoc.id)
                    .collection('reviews')
                    .snapshots(),
                builder: (context, reviewSnapshot) {
                  if (reviewSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (reviewSnapshot.hasError) {
                    return Center(
                        child: Text('Error: ${reviewSnapshot.error}'));
                  }
                  if (!reviewSnapshot.hasData ||
                      reviewSnapshot.data!.docs.isEmpty) {
                    return SizedBox.shrink(); // No reviews for this restaurant
                  }

                  // Only display the restaurant name if it has at least one review
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: Text(
                          'Reviews for ${restaurantData['name']}',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      ...reviewSnapshot.data!.docs
                          .map((DocumentSnapshot reviewDoc) {
                        Map<String, dynamic> reviewData =
                            reviewDoc.data() as Map<String, dynamic>;
                        int rating = reviewData['rating'];
                        String title = reviewData['title'];

                        return Card(
                          margin: EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 16.0),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: List.generate(
                                    rating,
                                    (index) =>
                                        Icon(Icons.star, color: Colors.yellow),
                                  ),
                                ),
                                SizedBox(height: 8),
                                Text(reviewData['comment']),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
