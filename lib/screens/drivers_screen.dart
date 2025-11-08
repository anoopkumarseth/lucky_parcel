import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  String _name = '';

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Widget _buildProfileImage() {
    if (_profileImage != null) {
      return CircleAvatar(backgroundImage: FileImage(_profileImage!), radius: 50);
    } else {
      return CircleAvatar(
        radius: 50,
        child: Text(
          _name.isNotEmpty
              ? _name.trim().split(' ').map((l) => l[0]).take(2).join()
              : ' ',
          style: const TextStyle(fontSize: 40),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Driver')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildProfileImage(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.camera),
                    label: const Text('Camera'),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Gallery'),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) => setState(() => _name = value),
              ),
              TextFormField(decoration: const InputDecoration(labelText: 'Phone')),
              TextFormField(decoration: const InputDecoration(labelText: 'Current Location (Lat, Lng)')),
              TextFormField(decoration: const InputDecoration(labelText: 'Vehicle Number')),
              TextFormField(decoration: const InputDecoration(labelText: 'Vehicle Type')),
              TextFormField(decoration: const InputDecoration(labelText: 'Vehicle Capacity (kg)')),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle registration logic
                },
                child: const Text('Register Driver'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
