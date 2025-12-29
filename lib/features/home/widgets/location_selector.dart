import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucky_parcel/common/constants/api_keys.dart';
import 'package:lucky_parcel/common/widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class LocationSelector extends StatefulWidget {
  final Function(Map<String, dynamic>) onLocationSelected;

  const LocationSelector({super.key, required this.onLocationSelected});

  @override
  State<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends State<LocationSelector> {
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final String _sessionToken = const Uuid().v4();
  List<dynamic> _predictions = [];
  bool _isPickup = true;

  void _getPredictions(String input) async {
    if (input.isEmpty) {
      setState(() => _predictions = []);
      return;
    }

    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${ApiKeys.googleApiKey}&sessiontoken=$_sessionToken&components=country:in');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() => _predictions = data['predictions']);
        } else {
          debugPrint('Google Places API Error: ${data["error_message"]}');
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching predictions: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is required to use this feature.')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text('Location permission has been permanently denied. Please go to your app settings to enable it.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await Geolocator.openAppSettings();
                  Navigator.of(context).pop();
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      final uri = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=${ApiKeys.googleApiKey}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final firstResult = data['results'][0];
          _pickupController.text = firstResult['formatted_address'];
          widget.onLocationSelected({
            'isPickup': true,
            'place_id': firstResult['place_id'],
          });
        }
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          CustomTextField(
            controller: _pickupController,
            labelText: 'Pickup Location',
            prefixIcon: SvgPicture.asset('assets/icons/location-pin.svg', colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn)),
            suffixIcon: IconButton(
              icon: SvgPicture.asset('assets/icons/location-select.svg', colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn)),
              onPressed: _getCurrentLocation,
            ),
            onChanged: (value) {
              _isPickup = true;
              _getPredictions(value);
            },
          ),
          CustomTextField(
            controller: _dropController,
            labelText: 'Drop Location',
            prefixIcon: SvgPicture.asset('assets/icons/location-pin.svg', colorFilter: ColorFilter.mode(primaryColor, BlendMode.srcIn)),
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
      ),
    );
  }
}
