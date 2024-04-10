import 'package:flutter/material.dart';
import 'navigation.dart';

class Browse extends StatefulWidget {
  const Browse({super.key});

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Navigation(),
      appBar: AppBar(
        title: const Text("Browse Restaurant"),
        backgroundColor: Colors.pink[100],
      ),
    );
  }
}
