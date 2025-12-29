import 'dart:convert';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:lucky_parcel/common/constants/api_keys.dart';

class GoogleMapsService {
  final String sessionToken;

  GoogleMapsService({required this.sessionToken});

  Future<List<dynamic>> getPredictions(String input) async {
    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=${ApiKeys.googleApiKey}&sessiontoken=$sessionToken&components=country:in');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['predictions'];
        }
      }
    } catch (e) {
      print('Error fetching predictions: $e');
    }
    return [];
  }

  Future<Map<String, dynamic>?> getPlaceDetails(String placeId) async {
    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=${ApiKeys.googleApiKey}&sessiontoken=$sessionToken');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['result'];
        }
      }
    } catch (e) {
      print('Error fetching place details: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>> getDirections(LatLng origin, LatLng destination) async {
    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=${ApiKeys.googleApiKey}');

    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          return data['routes'][0];
        }
      }
    } catch (e) {
      print('Error fetching directions: $e');
    }
    return {};
  }

  Future<String> getGeocodedAddress(double lat, double lng) async {
    final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=${ApiKeys.googleApiKey}');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          return result['formatted_address'] as String;
        }
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
    return 'Lat $lat, Lng $lng';
  }
}
