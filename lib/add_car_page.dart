import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:typed_data'; // For Uint8List used in web
import 'dart:io'; // For File handling on mobile
import 'package:flutter/foundation.dart' show kIsWeb; // To check if it's web
import 'package:http/http.dart' as http; // Use http package for MultipartFile
import 'package:pocketbase/pocketbase.dart'; // For PocketBase handling

class AddCarPage extends StatefulWidget {
  final PocketBase pb;

  AddCarPage({required this.pb});

  @override
  _AddCarPageState createState() => _AddCarPageState();
}

class _AddCarPageState extends State<AddCarPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _year = 2021;
  String _model = '';
  String _brand = '';
  int _horsepower = 100;
  double _price = 0.0;
  String _description = ''; // New field for description
  File? _image;
  Uint8List? _webImage;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      if (kIsWeb) {
        final bytes = await pickedImage.readAsBytes();
        setState(() {
          _webImage = bytes;
        });
      } else {
        setState(() {
          _image = File(pickedImage.path);
        });
      }
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        List<http.MultipartFile> files = [];
        if (!kIsWeb && _image != null) {
          files.add(await http.MultipartFile.fromPath('image', _image!.path));
        } else if (kIsWeb && _webImage != null) {
          files.add(http.MultipartFile.fromBytes('image', _webImage!, filename: 'car_image.png'));
        }

        final record = await widget.pb.collection('cars').create(
          body: {
            'name': _name,
            'year': _year,
            'model': _model,
            'brand': _brand,
            'horsepower': _horsepower,
            'price': _price,
            'description': _description,
          },
          files: files,
        );

        print('Car added successfully: ${record.id}');
        Navigator.pop(context, true);
      } catch (error) {
        print('Error adding car: $error');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to add car: ${error.toString()}'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Car'),
        backgroundColor: Colors.teal, // Matching the overall color scheme
      ),
      backgroundColor: Colors.white, // Set the background color to white
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (value) => _year = int.parse(value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Model', border: OutlineInputBorder()),
                onSaved: (value) => _model = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Brand', border: OutlineInputBorder()),
                onSaved: (value) => _brand = value!,
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Horsepower', border: OutlineInputBorder()),
                keyboardType: TextInputType.number,
                onSaved: (value) => _horsepower = int.parse(value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Price', border: OutlineInputBorder()),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onSaved: (value) => _price = double.parse(value!),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                maxLines: 4,
                onSaved: (value) => _description = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text(
                  'Pick Image',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 10),
              if (_webImage != null)
                Image.memory(_webImage!, height: 200, width: double.infinity, fit: BoxFit.cover)
              else if (_image != null)
                Image.file(_image!, height: 200, width: double.infinity, fit: BoxFit.cover)
              else
                Text('No image selected', style: TextStyle(fontSize: 16)),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
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
                    'Add Car',
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
