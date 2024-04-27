import 'package:deliveryapp/login.dart';
import 'package:deliveryapp/profile.dart';
import 'package:flutter/material.dart';
import 'homescreen.dart';
import 'browse.dart';
import 'browse_res.dart';
import 'placeorder.dart';
import 'track.dart';
import 'review.dart';

class Navigation extends StatelessWidget {
  const Navigation({super.key});

  @override
  Widget build(BuildContext context) {
    //Navigation Drawer
    return Drawer(
        child: SingleChildScrollView(
            child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        buildHeader(context), //header builder
        buildMenuItems(context), //items builder
      ],
    )));
  }

  Widget buildHeader(BuildContext context) {
    //If we want to add a header we can, this is here for that
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
      ),
    );
  }

  Widget buildMenuItems(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Wrap(
        runSpacing: 16,
        children: [
          ListTile(
            tileColor: Colors.red[200],
            iconColor: Colors.black87,
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          ),
          const Divider(color: Colors.black54),
          ListTile(
            tileColor: Colors.pink[100],
            iconColor: Colors.black87,
            leading: const Icon(Icons.search),
            title: const Text('Browse'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => Browse(),
                ),
              );
            },
          ),
          const Divider(color: Colors.black54),
          ListTile(
            tileColor: Colors.purple[100],
            iconColor: Colors.black87,
            leading: const Icon(Icons.shopping_cart),
            title: const Text('Place Order'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const PlaceOrder(),
                ),
              );
            },
          ),
          const Divider(color: Colors.black54),
          ListTile(
            tileColor: Colors.blue[50],
            iconColor: Colors.black87,
            leading: const Icon(Icons.track_changes),
            title: const Text('Track Your Order'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const Tracker(),
                ),
              );
            },
          ),
          const Divider(color: Colors.black54),
          ListTile(
            tileColor: Colors.green[200],
            iconColor: Colors.black87,
            leading: const Icon(Icons.star),
            title: const Text('Reviews'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ReviewPage(),
                ),
              );
            },
          ),
          const Divider(color: Colors.black54),
          ListTile(
            tileColor: Colors.orange[100],
            iconColor: Colors.black87,
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
                ),
              );
            },
          ),
          const Divider(color: Colors.black54),
          ListTile(
            tileColor: Colors.orange[100],
            iconColor: Colors.black87,
            leading: const Icon(Icons.person),
            title: const Text('Login'), // Change the title to 'Login'
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      const LoginPage(), // Navigate to the LoginScreen
                ),
              );
            },
          ),
          const Divider(color: Colors.black54),
        ],
      ),
    );
  }
}
