import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:intl/intl.dart'; // Import intl for number formatting
import 'edit_car_page.dart'; // Import the EditCarPage
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // Import SpeedDial for FAB

class CarDetailsPage extends StatelessWidget {
  final PocketBase pb;
  final RecordModel carRecord; // Pass the entire car record
  final String role;

  CarDetailsPage({
    required this.pb,
    required this.carRecord,
    this.role = 'member',
  });

  @override
  Widget build(BuildContext context) {
    // Create a number formatter for the price with commas
    final numberFormat = NumberFormat('#,###', 'en_US');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          carRecord.data['name'],
          style: TextStyle(fontSize: 22, color: Colors.white),
        ),
        backgroundColor: Colors.teal[400],
      ),
      body: Container(
        color: Colors.white, // Set background color to white
        child: SingleChildScrollView( // Wrap content in SingleChildScrollView to allow scrolling
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCarImage(), // Display car image
              SizedBox(height: 16),
              _buildInfoRow("Name", carRecord.data['name']),
              _buildInfoRow("Model", carRecord.data['model']),
              _buildInfoRow("Brand", carRecord.data['brand']),
              _buildInfoRow("Year", carRecord.data['year'].toString()),
              _buildInfoRow("Horsepower", "${carRecord.data['horsepower']} HP"),
              _buildInfoRow(
                  "Price", "${numberFormat.format(carRecord.data['price'])} Baht",
                  isPrice: true),
              SizedBox(height: 16),
              // Display the car's description with scrolling capability
              _buildDescriptionRow("Description", carRecord.data['description'] ?? 'No description provided'),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: role == 'admin'
          ? SpeedDial(
              icon: Icons.more_vert,
              activeIcon: Icons.close,
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              overlayOpacity: 0.3,
              overlayColor: Colors.black,
              spaceBetweenChildren: 12.0,
              children: [
                SpeedDialChild(
                  child: Icon(Icons.edit, color: Colors.white),
                  backgroundColor: Colors.orange[700],
                  label: 'Edit Car',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditCarPage(
                          pb: pb,
                          recordId: carRecord.id, // Pass the car's ID for editing
                          name: carRecord.data['name'],
                          model: carRecord.data['model'],
                          brand: carRecord.data['brand'],
                          year: carRecord.data['year'],
                          horsepower: carRecord.data['horsepower'],
                          price: carRecord.data['price'],
                          description: carRecord.data['description'], // Pass the description for editing
                        ),
                      ),
                    ).then((result) {
                      if (result == true) {
                        Navigator.pop(context, true); // Return to previous screen and indicate success
                      }
                    });
                  },
                ),
                SpeedDialChild(
                  child: Icon(Icons.delete, color: Colors.white),
                  backgroundColor: Colors.red,
                  label: 'Delete Car',
                  onTap: () {
                    _showDeleteConfirmationDialog(context);
                  },
                ),
              ],
            )
          : null, // Only show the FAB for admin role
    );
  }

  // Function to build the car image
  Widget _buildCarImage() {
    String? imageUrl;

    // Fetch the car image URL using PocketBase getFileUrl method
    if (carRecord.data.containsKey('image') && carRecord.data['image'] != null) {
      imageUrl = pb.getFileUrl(carRecord, carRecord.data['image']).toString();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              imageUrl,
              height: 200, // Adjust height
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(child: Text('Failed to load image')),
                );
              },
            )
          : Container(
              height: 200,
              color: Colors.grey[300],
              child: Center(child: Text('No Image Available')),
            ),
    );
  }

  // Function to build info row with labels
  Widget _buildInfoRow(String label, String value, {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: isPrice ? Colors.green[700] : Colors.black87,
              fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Function to build description row
  Widget _buildDescriptionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Function to show delete confirmation dialog
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Delete Car", style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text("Are you sure you want to delete this car? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("No", style: TextStyle(fontSize: 16)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteCar(context); // Proceed with delete
              },
              child: Text("Yes", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }

  // Function to delete the car
  void _deleteCar(BuildContext context) async {
    try {
      await pb.collection('cars').delete(carRecord.id); // Delete the car by its record ID
      Navigator.pop(context, true); // Go back and refresh the car list
    } catch (error) {
      print('Error deleting car: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete car')));
    }
  }
}
