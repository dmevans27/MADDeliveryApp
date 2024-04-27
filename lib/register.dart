import 'package:deliveryapp/driverinterface.dart';
import 'package:deliveryapp/firebase_options.dart';
import 'package:deliveryapp/homescreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login.dart';
import 'homescreen.dart';
import 'driverinterface.dart';


enum UserRole {customer, driver}

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {

    
    final TextEditingController _registerEmailController = TextEditingController();
    final TextEditingController _registerPasswordController = TextEditingController();
    final TextEditingController _registerFirstName=TextEditingController();
    final TextEditingController _registerLastName=TextEditingController();
    final TextEditingController _registerUsername=TextEditingController();
   
   UserRole? _selectedRole;
   String? _errorMessage;

   Future<void> _register(BuildContext context) async {
      try {
        await Firebase.initializeApp();
        UserCredential user = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _registerEmailController.text,
          password: _registerPasswordController.text,
        );

        // Store user's email in Firestore along with their UID
        CollectionReference users = FirebaseFirestore.instance.collection('users');
        if (_selectedRole == UserRole.customer){
        await users.doc(user.user!.uid).set({
          'Email': _registerEmailController.text,
          'FirstName':_registerFirstName.text,
          'LastName':_registerLastName.text,
          'Role':  'customer',
          'UserAddress': _registerAddressController.text,
          'RegistrationDateTime': Timestamp.now(),
          'Username': _registerUsername.text,
          
          
          });
        }
        else{
         await FirebaseFirestore.instance.collection('drivers').doc(user.user!.uid).set({
          'Email': _registerEmailController.text,
          'FirstName':_registerFirstName.text,
          'LastName':_registerLastName.text,
          'Role': 'driver',
          'UserAddress': _registerAddressController.text,
          'RegistrationDateTime': Timestamp.now(),
          'Username': _registerUsername.text,
          
          
          });
        }
 if (_selectedRole == UserRole.customer) {
     Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (context) => DriverPage()));
    }

      }on FirebaseAuthException catch (error) {
        
        // Handle registration errors
        setState(() {
      if (error.code == 'email-already-in-use') {
          _errorMessage = 'The email address is already in use by another account.';
        } else if (error.code == 'invalid-email') {
          _errorMessage = 'The email address is invalid.';
        } else {
          _errorMessage = 'An error occurred. Please try again later.';
        }
});
      }
    }
    @override
    void dispose() {
      _registerEmailController.dispose();
      _registerPasswordController.dispose();
      _registerFirstName.dispose();
      _registerLastName.dispose();
      _registerUsername.dispose();
      super.dispose();
    }
final TextEditingController _registerAddressController=TextEditingController();
@override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 203, 116, 219),
          title: const Text('Register'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
                const Text("Register for application"),
                TextFormField(
                  controller: _registerEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: _registerPasswordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                 TextFormField(
                  controller: _registerFirstName,
                  decoration: const InputDecoration(labelText: 'First Name'),
                  obscureText: false,
                ), TextFormField(
                  controller: _registerLastName,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                  obscureText: false,
                ),
                 TextFormField(
                  controller: _registerUsername,
                  decoration: const InputDecoration(labelText: 'Username'),
                  obscureText: false,
                ),
                TextFormField(
                controller: _registerAddressController,
                decoration: const InputDecoration(labelText: 'Address'),
                obscureText: false,
                ),
            
                 DropdownButtonFormField<UserRole>(
              value: _selectedRole,
              items: const  [
                DropdownMenuItem(
                  value: UserRole.customer,
                  child: Text('Customer'),
                ),
                DropdownMenuItem(
                  value: UserRole.driver,
                  child: Text('Driver'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
              decoration: const InputDecoration(labelText: 'Select Role'),
            ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () => _register(context),
                  child: const Text('Register'),
                ),
                ElevatedButton(
                  onPressed: ()=>Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage())),
                  child: const Text("Already have an account? Sign in here!"),
                )
              ]
            ),
          )
        )
      );
    }
  }
  