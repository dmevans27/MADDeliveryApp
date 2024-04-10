import "package:flutter/material.dart";
import "navigation.dart";

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navigation(),
      appBar: AppBar(
        title: const Text("User Profile"),
        backgroundColor: Colors.orange[100],
      ),
    );
  }
}