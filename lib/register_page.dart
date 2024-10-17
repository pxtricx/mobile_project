import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  PocketBase pb = PocketBase('http://127.0.0.1:8090'); // PocketBase instance

  Future<void> registerUser() async {
    try {
      // Creating the user in the 'users' collection
      final body = {
        'email': _emailController.text,
        'password': _passwordController.text,
        'passwordConfirm': _passwordController.text,
        'emailPublic': true, // Add this line to set the email to public
      };
      
      await pb.collection('users').create(body: body);

      // If successful, show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User registered successfully!'),
      ));

      // Clear the fields
      _emailController.clear();
      _passwordController.clear();

      // Optionally, navigate back to the Login page
      Navigator.pop(context);
    } catch (error) {
      // If there is an error, show an error message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Registration failed: $error'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Account'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      backgroundColor: Colors.white, // Set background color to white
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Register your account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Fill the details below to create a new account.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 30),
                // Email Input Field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.email),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Password Input Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: Icon(Icons.lock),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password should be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 40),
                // Register Button
                SizedBox(
                  width: double.infinity, // Full width button
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        registerUser();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal, // Updated from 'primary' to 'backgroundColor'
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Back to Login option
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Navigate back to login
                    },
                    child: Text(
                      'Already have an account? Login',
                      style: TextStyle(color: Colors.teal),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
