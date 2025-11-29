import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  GoogleMapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Order')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(widget.orderId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final order = snapshot.data!.data() as Map<String, dynamic>;
          final driverLocation = order['driverLocation'] as GeoPoint?;
          final pickupLocation = order['pickup'] as GeoPoint;
          final dropoffLocation = order['dropoff'] as GeoPoint;

          final initialCameraPosition = CameraPosition(
            target: LatLng(pickupLocation.latitude, pickupLocation.longitude),
            zoom: 14,
          );

          final markers = <Marker>{
            if (driverLocation != null)
              Marker(
                markerId: const MarkerId('driver'),
                position: LatLng(driverLocation.latitude, driverLocation.longitude),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                infoWindow: const InfoWindow(title: 'Driver'),
              ),
            Marker(
              markerId: const MarkerId('pickup'),
              position: LatLng(pickupLocation.latitude, pickupLocation.longitude),
              infoWindow: const InfoWindow(title: 'Pickup'),
            ),
            Marker(
              markerId: const MarkerId('dropoff'),
              position: LatLng(dropoffLocation.latitude, dropoffLocation.longitude),
              infoWindow: const InfoWindow(title: 'Drop-off'),
            ),
          };

          if (_mapController != null && driverLocation != null) {
            _mapController!.animateCamera(
              CameraUpdate.newCameraPosition(
                CameraPosition(target: LatLng(driverLocation.latitude, driverLocation.longitude), zoom: 15),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: initialCameraPosition,
                  markers: markers,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: ListTile(
                    title: Text('Status: ${order['status']}'),
                    subtitle: Text('Driver: ${order['driverName']}'),
                    trailing: Text('OTP: ${order['otp']}'),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
