import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'main.dart'; // Import the file where HomePage is defined

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final PocketBase pb;

  CustomAppBar({required this.title, required this.pb});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 26, // Adjust the font size as needed
          fontWeight: FontWeight.bold, // Make the text bold
          color: Colors.white, // Set text color to white
          fontFamily: 'Roboto', // Optional: Specify a custom font family
        ),
      ),
      backgroundColor: Colors.teal[600], // Set background color of AppBar
      leading: null,
      actions: [
        IconButton(
          icon: Icon(Icons.logout), // Logout icon
          onPressed: () {
            _showLogoutConfirmationDialog(context); // Show confirmation dialog
          },
        ),
      ],
    );
  }

  // Function to show logout confirmation dialog
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logout(context); // Proceed with logout
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

  // Logout function that clears session and navigates back to the main page
  void _logout(BuildContext context) {
    try {
      pb.authStore.clear(); // Clear the PocketBase auth session

      // Navigate back to the HomePage and clear all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage()), // HomePage is the first page
        (Route<dynamic> route) => false, // Clear all previous routes
      );
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
