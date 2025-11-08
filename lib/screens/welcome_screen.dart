import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../widgets/location_selector.dart';
import '../widgets/map_view.dart';
import '../widgets/side_bar.dart';
import '../widgets/top_nav.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _apiKey = 'AIzaSyCwJ-S4S4sPnVdzbIuCfXo0UZ0TgZz5PwE';
  String _sessionToken = const Uuid().v4();
  LatLng? _pickupLocation;
  LatLng? _dropLocation;

  void _onLocationSelected(Map<String, dynamic> locationData) async {
    final placeId = locationData['place_id'];
    final isPickup = locationData['isPickup'];

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey&sessiontoken=$_sessionToken'));

    if (response.statusCode == 200) {
      final details = json.decode(response.body)['result'];
      final lat = details['geometry']['location']['lat'];
      final lng = details['geometry']['location']['lng'];

      setState(() {
        if (isPickup) {
          _pickupLocation = LatLng(lat, lng);
        } else {
          _dropLocation = LatLng(lat, lng);
        }
        _sessionToken = const Uuid().v4(); // Reset session token
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: TopNav(scaffoldKey: _scaffoldKey),
      drawer: const SideBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              LocationSelector(onLocationSelected: _onLocationSelected),
              const SizedBox(height: 20),
              if (_pickupLocation != null || _dropLocation != null)
                MapView(pickup: _pickupLocation, drop: _dropLocation),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle confirm logic
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
