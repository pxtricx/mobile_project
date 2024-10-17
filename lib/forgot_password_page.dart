import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'reset_password_page.dart'; // Import the ResetPasswordPage

class ForgotPasswordPage extends StatefulWidget {
  final PocketBase pb;

  ForgotPasswordPage({required this.pb});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _checkEmailExists() async {
    try {
      // Trim the email input and filter by exact match
      final emailToCheck = _emailController.text.trim();

      // Print email for debugging
      print('Checking email: $emailToCheck');

      // List all users and print their email for debugging
      final result = await widget.pb.collection('users').getList();

      // Debug: Print all emails found in the collection
      result.items.forEach((user) {
        print('Email found in users: ${user.data['email']}');
      });

      // Check if the email exists
      final filteredResult = result.items.where((user) => user.data['email'] == emailToCheck).toList();

      // Debug: Print filtered results
      print('Filtered result: $filteredResult');

      // If result.items is not empty, navigate to ResetPasswordPage
      if (filteredResult.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResetPasswordPage(pb: widget.pb, userId: filteredResult.first.id),
          ),
        );
      } else {
        // If no results are found, show an alert
        _showEmailNotFoundDialog();
      }
    } catch (e) {
      // Print error for debugging
      print('Error during email check: $e');
      _showEmailNotFoundDialog(); // Show dialog even if there's an exception
    }
  }

  void _showEmailNotFoundDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Email Not Found"),
          content: Text("This email doesn't exist."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter your email to reset your password',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _checkEmailExists();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Check Email',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
