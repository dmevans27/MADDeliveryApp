import 'package:deliveryapp/driverinterface.dart';
import 'package:deliveryapp/firebase_options.dart';
import 'package:deliveryapp/homescreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'register.dart';

  class LoginPage extends StatefulWidget {
    const LoginPage({Key? key});

    @override
    State<LoginPage> createState() => _LoginPageState();
  }

  class _LoginPageState extends State<LoginPage> {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
    final TextEditingController _signInEmailController = TextEditingController();
    final TextEditingController _signInPasswordController = TextEditingController();
  

   
    Future<void> _signIn(BuildContext context) async {
      try {
        await Firebase.initializeApp();
        UserCredential user = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _signInEmailController.text,
          password: _signInPasswordController.text,
        );
DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.user!.uid).get();

    if (userDoc.exists) {
      String role = userDoc['Role'];
      if (role == 'user') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      } else if (role == 'driver') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DriverPage()));
      } else {
        // Handle unknown role
        print('Unknown role: $role');
      }
    } else {
      // Handle user document not found
      print('User document not found for user ID: ${user.user!.uid}');
    }
        
      } catch (error) {
        // Handle sign-in errors
        print("Sign-in error: $error");
      }
    }

    @override
    void dispose() {
      _signInEmailController.dispose();
      _signInPasswordController.dispose();
      super.dispose();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 203, 116, 219),
          title: const Text('Login'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              const Card( // Title Card
            elevation: 3,
            color: Color.fromARGB(255, 203, 116, 219),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "Welcome to EvansLomini Deliveries!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
            const SizedBox(height:50),
            const Text('Login'),
            TextFormField(
                controller: _signInEmailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _signInPasswordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => _signIn(context),
                child: const Text('Sign In'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationPage())),
                child: const Text("Need to create an account? Register Here!"),
              )
            ]
          )
        )
      );
    }
  }
