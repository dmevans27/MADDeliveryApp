import 'package:flutter/material.dart';
import 'navigation.dart';

class Tracker extends StatefulWidget {
  const Tracker({super.key});

  @override
  State<Tracker> createState() => _TrackerState();
}

class _TrackerState extends State<Tracker> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Navigation(),
      appBar: AppBar(
        title: const Text("Track Your Order"),
        backgroundColor: Colors.blue[50],
      ),
    );
  }
}