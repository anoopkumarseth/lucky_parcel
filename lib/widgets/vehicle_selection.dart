import 'package:flutter/material.dart';

class VehicleSelection extends StatefulWidget {
  final double distanceInKm;
  final Function(Map<String, dynamic>?) onVehicleSelected;

  const VehicleSelection(
      {super.key, required this.distanceInKm, required this.onVehicleSelected});

  @override
  State<VehicleSelection> createState() => _VehicleSelectionState();
}

class _VehicleSelectionState extends State<VehicleSelection> {
  int? _selectedIndex;

  final List<Map<String, dynamic>> _vehicles = [
    {'name': 'Motorbike', 'icon': Icons.two_wheeler_outlined, 'rate': 8.0},
    {'name': '3-Wheeler', 'icon': Icons.auto_awesome_outlined, 'rate': 12.0},
    {'name': 'Mini Truck', 'icon': Icons.local_shipping_outlined, 'rate': 18.0},
    {'name': 'Big Truck', 'icon': Icons.fire_truck_outlined, 'rate': 25.0},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _vehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _vehicles[index];
        final price = widget.distanceInKm * vehicle['rate'];
        final isSelected = _selectedIndex == index;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: isSelected ? Colors.blue.shade50 : null,
          child: ListTile(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              widget.onVehicleSelected({
                'name': vehicle['name'],
                'price': price,
              });
            },
            leading: Icon(vehicle['icon'], size: 40, color: Theme.of(context).primaryColor),
            title: Text(vehicle['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            trailing: Text('₹${price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        );
      },
    );
  }
}
