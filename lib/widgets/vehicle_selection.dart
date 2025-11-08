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

  // Vehicle data: name, icon, and rate per km in rupees
  final List<Map<String, dynamic>> _vehicles = [
    {'name': 'Motorbike', 'icon': Icons.two_wheeler, 'rate': 8.0},
    {'name': '3-Wheeler', 'icon': Icons.auto_awesome, 'rate': 12.0},
    {'name': 'Mini Truck', 'icon': Icons.local_shipping, 'rate': 18.0},
    {'name': 'Big Truck', 'icon': Icons.fire_truck, 'rate': 25.0},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Vehicle:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = _vehicles[index];
              final price = widget.distanceInKm * vehicle['rate'];
              final isSelected = _selectedIndex == index;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  widget.onVehicleSelected({
                    'name': vehicle['name'],
                    'price': price,
                  });
                },
                child: Container(
                  width: 110,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(vehicle['icon'], size: 40, color: Colors.blue.shade800),
                      const SizedBox(height: 8),
                      Text(vehicle['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text('₹${price.toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
