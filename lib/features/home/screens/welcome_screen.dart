import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lucky_parcel/common/widgets/gradient_background.dart';
import 'package:lucky_parcel/common/widgets/side_bar.dart';
import 'package:lucky_parcel/common/widgets/top_nav.dart';
import 'package:lucky_parcel/features/home/widgets/location_selector.dart';
import 'package:lucky_parcel/features/home/widgets/vehicle_selection.dart';
import 'package:uuid/uuid.dart';

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
            _sessionToken = const Uuid().v4();

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
            _distanceValue = distanceValue / 1000.0;
            _polylines.add(Polyline(
              polylineId: const PolylineId('route'),
              color: Colors.blueAccent,
              width: 5,
              points: polylineCoordinates,
            ));
          });

          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  _pickupLocation!.latitude < _dropLocation!.latitude ? _pickupLocation!.latitude : _dropLocation!.latitude,
                  _pickupLocation!.longitude < _dropLocation!.longitude ? _pickupLocation!.longitude : _dropLocation!.longitude,
                ),
                northeast: LatLng(
                  _pickupLocation!.latitude > _dropLocation!.latitude ? _pickupLocation!.latitude : _dropLocation!.latitude,
                  _pickupLocation!.longitude > _dropLocation!.longitude ? _pickupLocation!.longitude : _dropLocation!.longitude,
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

  Future<void> _bookParcel() async {
    final driversSnapshot = await FirebaseFirestore.instance.collection('drivers').get();
    DocumentSnapshot? nearestDriver;
    double? minDistance;

    for (var driverDoc in driversSnapshot.docs) {
      final driverData = driverDoc.data();
      final locationParts = driverData['location'].split(',');
      if (locationParts.length == 2) {
        final lat = double.tryParse(locationParts[0]);
        final lng = double.tryParse(locationParts[1]);
        if (lat != null && lng != null) {
          final distance = Geolocator.distanceBetween(
              _pickupLocation!.latitude, _pickupLocation!.longitude, lat, lng);
          if (minDistance == null || distance < minDistance) {
            minDistance = distance;
            nearestDriver = driverDoc;
          }
        }
      }
    }

    if (nearestDriver == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No drivers available.')));
      return;
    }

    final otp = (1000 + Random().nextInt(9000)).toString();

    await FirebaseFirestore.instance.collection('orders').add({
      'pickup': GeoPoint(_pickupLocation!.latitude, _pickupLocation!.longitude),
      'dropoff': GeoPoint(_dropLocation!.latitude, _dropLocation!.longitude),
      'distance': _distanceText,
      'vehicle': _selectedVehicle,
      'driverId': nearestDriver.id,
      'driverName': nearestDriver['name'],
      'otp': otp,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'userId': FirebaseAuth.instance.currentUser!.uid,
    });

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Confirmed!'),
        content: Text('Driver ${nearestDriver!['name']} has been assigned.\nYour OTP is: $otp'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    
    Navigator.pushNamed(context, '/orders');
    _reset();
  }

  void _repeatRide(GeoPoint pickup, GeoPoint drop) {
    setState(() {
      _pickupLocation = LatLng(pickup.latitude, pickup.longitude);
      _dropLocation = LatLng(drop.latitude, drop.longitude);
      if (_pickupLocation != null && _dropLocation != null) {
        _getDirections();
      }
    });
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
    final bool hasFullRoute = _pickupLocation != null && _dropLocation != null;

    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      appBar: TopNav(scaffoldKey: _scaffoldKey),
      drawer: const SideBar(),
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              if (!hasFullRoute)
                LocationSelector(onLocationSelected: _onLocationSelected),
              if (_pickupLocation == null && _dropLocation == null)
                RecentRides(onRideSelected: _repeatRide),
              if (hasFullRoute)
                Column(
                  children: [
                    Card(
                      elevation: 4,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          SizedBox(
                            height: _isConfirmed ? 180 : 300,
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
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Text('Distance: $_distanceText', style: Theme.of(context).textTheme.titleMedium),
                                  TextButton(onPressed: _reset, child: const Text('Change')),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (_isConfirmed)
                      Card(
                        margin: const EdgeInsets.only(top: 20),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text('Select Vehicle', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 10),
                              VehicleSelection(
                                distanceInKm: _distanceValue,
                                onVehicleSelected: (vehicle) => setState(() => _selectedVehicle = vehicle),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: hasFullRoute
          ? FloatingActionButton.extended(
              onPressed: _isConfirmed
                  ? (_selectedVehicle != null ? _bookParcel : null)
                  : () => setState(() => _isConfirmed = true),
              label: Text(_isConfirmed ? 'Book Now' : 'Confirm'),
              icon: Icon(_isConfirmed ? Icons.check : Icons.arrow_forward),
            )
          : null,
    );
  }
}

class RecentRides extends StatelessWidget {
  final Function(GeoPoint, GeoPoint) onRideSelected;
  const RecentRides({super.key, required this.onRideSelected});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 24.0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final order = snapshot.data!.docs[index];
            return RecentRideTile(order: order, onSelected: onRideSelected);
          },
        );
      },
    );
  }
}

class RecentRideTile extends StatefulWidget {
  final DocumentSnapshot order;
  final Function(GeoPoint, GeoPoint) onSelected;
  const RecentRideTile({super.key, required this.order, required this.onSelected});

  @override
  State<RecentRideTile> createState() => _RecentRideTileState();
}

class _RecentRideTileState extends State<RecentRideTile> {
  String? _dropoffAddressMain;
  String? _dropoffAddressSecondary;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    final dropoffPoint = widget.order['dropoff'] as GeoPoint;
    final dropoffAddrParts = await _getGeocodedAddress(dropoffPoint);

    if (mounted) {
      setState(() {
        _dropoffAddressMain = dropoffAddrParts[0];
        _dropoffAddressSecondary = dropoffAddrParts[1];
      });
    }
  }

  Future<List<String>> _getGeocodedAddress(GeoPoint point) async {
    final apiKey = 'AIzaSyCKVcmoBtJMFWHBRDF_TxvB5UCmW-w5rOg';
    final uri = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=${point.latitude},${point.longitude}&key=$apiKey');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final components = result['address_components'] as List;
          
          String? mainText;
          String? secondaryText;

          for (var component in components) {
            final types = component['types'] as List;
            if (types.contains('sublocality_level_2') || types.contains('sublocality')) {
              mainText = component['short_name'];
              break;
            }
          }
          mainText ??= result['formatted_address'].split(',')[0];

          final fullAddress = result['formatted_address'] as String;
          final parts = fullAddress.split(',');
          if (parts.length > 1) {
            secondaryText = parts.sublist(1).join(',').trim();
          }
          
          return [mainText ?? '', secondaryText ?? ''];
        }
      }
    } catch (e) {
      debugPrint('Error fetching address: $e');
    }
    return ['Lat ${point.latitude.toStringAsFixed(2)}', 'Lng ${point.longitude.toStringAsFixed(2)}'];
  }

  @override
  Widget build(BuildContext context) {
    final pickup = widget.order['pickup'] as GeoPoint;
    final dropoff = widget.order['dropoff'] as GeoPoint;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0, left: 8.0, right: 8.0),
      child: InkWell(
        onTap: () => widget.onSelected(pickup, dropoff),
        child: Row(
          children: [
            SvgPicture.asset('assets/icons/history.svg', width: 24, height: 24, colorFilter: ColorFilter.mode(Theme.of(context).primaryColor, BlendMode.srcIn)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _dropoffAddressMain ?? 'Loading...',
                    style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).primaryColor),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_dropoffAddressSecondary != null && _dropoffAddressSecondary!.isNotEmpty)
                    Text(
                      _dropoffAddressSecondary!,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
