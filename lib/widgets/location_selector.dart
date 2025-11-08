import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class LocationSelector extends StatefulWidget {
  final Function(Map<String, dynamic>) onLocationSelected;

  const LocationSelector({super.key, required this.onLocationSelected});

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final String _apiKey = 'AIzaSyCwJ-S4S4sPnVdzbIuCfXo0UZ0TgZz5PwE';
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  String _sessionToken = const Uuid().v4();
  List<dynamic> _predictions = [];
  bool _isPickup = true;

  void _getPredictions(String input) async {
    if (input.isEmpty) {
      setState(() => _predictions = []);
      return;
    }
    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey&sessiontoken=$_sessionToken&components=country:in'));
    if (response.statusCode == 200) {
      setState(() => _predictions = json.decode(response.body)['predictions']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _pickupController,
          decoration: const InputDecoration(labelText: 'Pickup Location'),
          onChanged: (value) {
            _isPickup = true;
            _getPredictions(value);
          },
        ),
        TextField(
          controller: _dropController,
          decoration: const InputDecoration(labelText: 'Drop Location'),
          onChanged: (value) {
            _isPickup = false;
            _getPredictions(value);
          },
        ),
        if (_predictions.isNotEmpty)
          SizedBox(
            height: 200,
            child: ListView.builder(
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_predictions[index]['description']),
                  onTap: () {
                    if (_isPickup) {
                      _pickupController.text = _predictions[index]['description'];
                    } else {
                      _dropController.text = _predictions[index]['description'];
                    }
                    widget.onLocationSelected({
                      'isPickup': _isPickup,
                      'place_id': _predictions[index]['place_id']
                    });
                    setState(() => _predictions = []);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
