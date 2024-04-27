import 'package:deliveryapp/firebase_options.dart';
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
              const Text("Login to application"),
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
