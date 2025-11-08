import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../widgets/location_selector.dart';
import '../widgets/side_bar.dart';
import '../widgets/top_nav.dart';
import '../widgets/vehicle_selection.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _apiKey = 'AIzaSyCKVcmoBtJMFWHBRDF_TxvB5UCmW-w5rOg';
  String _sessionToken = const Uuid().v4();
  GoogleMapController? _mapController;
  LatLng? _pickupLocation;
  LatLng? _dropLocation;
  final Set<Polyline> _polylines = {};
  String? _distanceText;
  double _distanceValue = 0;
  bool _isConfirmed = false;
  Map<String, dynamic>? _selectedVehicle;

  void _onLocationSelected(Map<String, dynamic> locationData) async {
    final placeId = locationData['place_id'];
    final isPickup = locationData['isPickup'];

    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey&sessiontoken=$_sessionToken');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final details = data['result'];
          final lat = details['geometry']['location']['lat'];
          final lng = details['geometry']['location']['lng'];

          setState(() {
            if (isPickup) {
              _pickupLocation = LatLng(lat, lng);
            } else {
              _dropLocation = LatLng(lat, lng);
            }
            _sessionToken = const Uuid().v4(); // Reset session token

            if (_pickupLocation != null && _dropLocation != null) {
              _getDirections();
            }
          });
        } else {
          debugPrint('Google Places API Error: ${data["error_message"]}');
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching location details: $e');
    }
  }

  void _getDirections() async {
    final origin = '${_pickupLocation!.latitude},${_pickupLocation!.longitude}';
    final destination = '${_dropLocation!.latitude},${_dropLocation!.longitude}';
    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$_apiKey');

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK') {
          final routes = data['routes'] as List;
          final overviewPolyline = routes[0]['overview_polyline']['points'];
          final distanceText = routes[0]['legs'][0]['distance']['text'];
          final distanceValue = routes[0]['legs'][0]['distance']['value'];

          final polylinePoints = PolylinePoints();
          final polylineCoordinates = polylinePoints
              .decodePolyline(overviewPolyline)
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();

          setState(() {
            _distanceText = distanceText;
            _distanceValue = distanceValue / 1000.0; // Convert to km
            _polylines.add(Polyline(
              polylineId: const PolylineId('route'),
              color: Colors.blue,
              width: 5,
              points: polylineCoordinates,
            ));
          });

          // Auto-zoom the map
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  _pickupLocation!.latitude < _dropLocation!.latitude
                      ? _pickupLocation!.latitude
                      : _dropLocation!.latitude,
                  _pickupLocation!.longitude < _dropLocation!.longitude
                      ? _pickupLocation!.longitude
                      : _dropLocation!.longitude,
                ),
                northeast: LatLng(
                  _pickupLocation!.latitude > _dropLocation!.latitude
                      ? _pickupLocation!.latitude
                      : _dropLocation!.latitude,
                  _pickupLocation!.longitude > _dropLocation!.longitude
                      ? _pickupLocation!.longitude
                      : _dropLocation!.longitude,
                ),
              ),
              50.0,
            ),
          );
        } else {
          debugPrint('Directions API Error: ${data["error_message"]}');
        }
      } else {
        debugPrint('HTTP Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
    } catch (e) {
      debugPrint('Error fetching directions: $e');
    }
  }

  void _reset() {
    setState(() {
      _pickupLocation = null;
      _dropLocation = null;
      _polylines.clear();
      _distanceText = null;
      _distanceValue = 0;
      _isConfirmed = false;
      _selectedVehicle = null;
    });
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
              if (!_isConfirmed) LocationSelector(onLocationSelected: _onLocationSelected),
              const SizedBox(height: 20),
              if (_pickupLocation != null && _dropLocation != null)
                Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: _isConfirmed ? 150 : 300, // Animate height change
                      child: GoogleMap(
                        onMapCreated: (controller) => _mapController = controller,
                        initialCameraPosition: CameraPosition(
                          target: _pickupLocation!,
                          zoom: 12,
                        ),
                        markers: {
                          Marker(markerId: const MarkerId('pickup'), position: _pickupLocation!),
                          Marker(markerId: const MarkerId('drop'), position: _dropLocation!),
                        },
                        polylines: _polylines,
                      ),
                    ),
                    if (_distanceText != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Distance: $_distanceText', style: const TextStyle(fontSize: 16)),
                      ),
                    const SizedBox(height: 20),
                    if (!_isConfirmed)
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isConfirmed = true;
                          });
                        },
                        child: const Text('Confirm'),
                      ),
                    if (_isConfirmed)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Select Vehicle:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: _reset,
                            child: const Text('Modify Location'),
                          ),
                        ],
                      ),
                    if (_isConfirmed)
                      VehicleSelection(
                        distanceInKm: _distanceValue,
                        onVehicleSelected: (vehicle) {
                          setState(() {
                            _selectedVehicle = vehicle;
                          });
                        },
                      ),
                    const SizedBox(height: 20),
                    if (_isConfirmed)
                      ElevatedButton(
                        onPressed: _selectedVehicle != null
                            ? () {
                                // Handle booking logic
                              }
                            : null, // Button is disabled if no vehicle is selected
                        child: const Text('Book Now'),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
