import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatelessWidget {
  final LatLng? pickup;
  final LatLng? drop;

  const MapView({super.key, this.pickup, this.drop});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0), // Default location
          zoom: 2,
        ),
        markers: _createMarkers(),
      ),
    );
  }

  Set<Marker> _createMarkers() {
    final markers = <Marker>{};
    if (pickup != null) {
      markers.add(Marker(
        markerId: const MarkerId('pickup'),
        position: pickup!,
        infoWindow: const InfoWindow(title: 'Pickup'),
      ));
    }
    if (drop != null) {
      markers.add(Marker(
        markerId: const MarkerId('drop'),
        position: drop!,
        infoWindow: const InfoWindow(title: 'Drop'),
      ));
    }
    return markers;
  }
}
