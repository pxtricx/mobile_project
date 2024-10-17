import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'main_page.dart'; // Import the MainPage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  PocketBase pb = PocketBase('http://127.0.0.1:8090'); // PocketBase instance

  // Predefined admin credentials
final String adminEmail = 'admin@ubu.ac.th';
final String adminPassword = 'admin@dssi';

Future<void> loginUser() async {
  try {
    // Check if the credentials match the admin's credentials
    if (_emailController.text == adminEmail && _passwordController.text == adminPassword) {
      // Admin login successful
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Admin login successful!'),
      ));

      // Navigate to MainPage as Admin
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(role: 'admin', pb: pb), // Pass 'admin' role
        ),
      );
    } else {
      // Regular user login via PocketBase
      final authData = await pb.collection('users').authWithPassword(
        _emailController.text,
        _passwordController.text,
      );

      // If login is successful for a regular user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Login successful!'),
      ));

      // Assuming you set a default role of 'member' for regular users
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(role: 'member', pb: pb), // Pass 'member' role
        ),
      );
    }
  } catch (e) {
    // If there is an error, show an error message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Login failed: $e'),
    ));
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Email Input Field
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }
                  return null;
                },
              ),
              // Password Input Field
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Login Button
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    loginUser();
                  }
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
