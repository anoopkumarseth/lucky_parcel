import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  bool _isListVisible = true;
  DocumentSnapshot? _editingDriver;

  void _showList() {
    setState(() {
      _isListVisible = true;
      _editingDriver = null; // Clear any edits
    });
  }

  void _showForm([DocumentSnapshot? driver]) {
    setState(() {
      _isListVisible = false;
      _editingDriver = driver;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isListVisible ? 'Drivers' : (_editingDriver == null ? 'Register Driver' : 'Edit Driver')),
        actions: [
          if (_isListVisible)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showForm(),
            ),
        ],
      ),
      body: _isListVisible ? DriverList(onEdit: _showForm) : DriverForm(driver: _editingDriver, onFormClose: _showList),
    );
  }
}

class DriverList extends StatefulWidget {
  final Function(DocumentSnapshot) onEdit;
  const DriverList({super.key, required this.onEdit});

  @override
  State<DriverList> createState() => _DriverListState();
}

class _DriverListState extends State<DriverList> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            decoration: const InputDecoration(
              labelText: 'Search Drivers',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('drivers').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Text('Something went wrong');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs.where((doc) {
                final name = doc['name'] as String;
                return name.toLowerCase().contains(_searchQuery.toLowerCase());
              }).toList();

              if (docs.isEmpty) return const Center(child: Text('No drivers found.'));

              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final driver = docs[index];
                  return ListTile(
                    onTap: () => widget.onEdit(driver),
                    leading: CircleAvatar(
                      child: Text(driver['name'].trim().split(' ').map((l) => l[0]).take(2).join()),
                    ),
                    title: Text(driver['name']),
                    subtitle: Text(driver['vehicleType'] ?? ''),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class DriverForm extends StatefulWidget {
  final DocumentSnapshot? driver;
  final VoidCallback onFormClose;

  const DriverForm({super.key, this.driver, required this.onFormClose});

  @override
  State<DriverForm> createState() => _DriverFormState();
}

class _DriverFormState extends State<DriverForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _locationController = TextEditingController();
  final _vehicleNumController = TextEditingController();
  String? _selectedVehicleType;
  String? _selectedCapacity;

  final List<String> _vehicleTypes = ['Motorbike', '3-Wheeler', 'Mini Truck', 'Big Truck'];
  final List<String> _capacities = ['5-10 kg', '10-15 kg', '15-25 kg', '25-50 kg', '50-100 kg', '100-200 kg', '200-500 kg', '500-1000 kg', '1 Ton', '2 Ton', '5 Ton', '10 Ton'];

  @override
  void initState() {
    super.initState();
    if (widget.driver != null) {
      final data = widget.driver!.data() as Map<String, dynamic>;
      _nameController.text = data['name'];
      _phoneController.text = data['phone'];
      _locationController.text = data['location'];
      _vehicleNumController.text = data['vehicleNumber'];
      _selectedVehicleType = data['vehicleType'];
      _selectedCapacity = data['vehicleCapacity'];
    }
  }

  Future<void> _saveDriver() async {
    if (!_formKey.currentState!.validate()) return;

    final driverData = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'location': _locationController.text,
      'vehicleNumber': _vehicleNumController.text,
      'vehicleType': _selectedVehicleType,
      'vehicleCapacity': _selectedCapacity,
    };

    if (widget.driver == null) {
      await FirebaseFirestore.instance.collection('drivers').add(driverData);
    } else {
      await widget.driver!.reference.update(driverData);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Driver saved successfully!')),
    );

    widget.onFormClose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name'), validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Required' : null),
            TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Current Location (Lat, Lng)')),
            TextFormField(controller: _vehicleNumController, decoration: const InputDecoration(labelText: 'Vehicle Number')),
            DropdownButtonFormField<String>(
              value: _selectedVehicleType,
              decoration: const InputDecoration(labelText: 'Vehicle Type'),
              items: _vehicleTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (v) => setState(() => _selectedVehicleType = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            DropdownButtonFormField<String>(
              value: _selectedCapacity,
              decoration: const InputDecoration(labelText: 'Vehicle Capacity'),
              items: _capacities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCapacity = v),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveDriver,
              child: Text(widget.driver == null ? 'Register Driver' : 'Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
