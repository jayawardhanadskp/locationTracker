import 'package:cloud_firestore/cloud_firestore.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add a new location
  Future<void> addLocation(String location, double latitude, double longitude) async {
    await _firestore.collection('locations').add({
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // Method to fetch locations
  Future<List<String>> getLocations() async {
    List<String> locationsList = [];
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('locations').get();
      for (var doc in querySnapshot.docs) {
        String location = doc['location'];
        double latitude = doc['latitude'];
        double longitude = doc['longitude'];
        // Assuming you're storing as "latitude,longitude" format
        locationsList.add('$latitude,$longitude');
      }
    } catch (e) {
      print('Error fetching locations: $e');
    }
    return locationsList;
  }
}
