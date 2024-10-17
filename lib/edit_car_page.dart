import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class EditCarPage extends StatefulWidget {
  final PocketBase pb;
  final String recordId;
  final String name;
  final String model;
  final String brand;
  final int year;
  final int horsepower;
  final double price;
  final String description; // Field for description

  EditCarPage({
    required this.pb,
    required this.recordId,
    required this.name,
    required this.model,
    required this.brand,
    required this.year,
    required this.horsepower,
    required this.price,
    required this.description, // Initialize description
  });

  @override
  _EditCarPageState createState() => _EditCarPageState();
}

class _EditCarPageState extends State<EditCarPage> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _model;
  late String _brand;
  late int _year;
  late int _horsepower;
  late double _price;
  late String _description; // New field for description

  @override
  void initState() {
    super.initState();
    _name = widget.name;
    _model = widget.model;
    _brand = widget.brand;
    _year = widget.year;
    _horsepower = widget.horsepower;
    _price = widget.price;
    _description = widget.description; // Initialize description
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await widget.pb.collection('cars').update(
          widget.recordId,
          body: {
            'name': _name,
            'model': _model,
            'brand': _brand,
            'year': _year,
            'horsepower': _horsepower,
            'price': _price,
            'description': _description, // Update description
          },
        );
        Navigator.pop(context, true);
      } catch (error) {
        print('Error updating car: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to update car: ${error.toString()}'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Car'),
        backgroundColor: Colors.teal, // Consistent color scheme with AddCarPage
      ),
      backgroundColor: Colors.white, // White background for a clean look
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _model,
                decoration: InputDecoration(
                  labelText: 'Model',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _model = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _brand,
                decoration: InputDecoration(
                  labelText: 'Brand',
                  border: OutlineInputBorder(),
                ),
                onSaved: (value) => _brand = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _year.toString(),
                decoration: InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _year = int.parse(value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _horsepower.toString(),
                decoration: InputDecoration(
                  labelText: 'Horsepower',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onSaved: (value) => _horsepower = int.parse(value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _price.toString(),
                decoration: InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) => _price = double.parse(value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                initialValue: _description, // Set initial value for description
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                onSaved: (value) => _description = value!,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity, // Make the button full-width
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Changes',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
