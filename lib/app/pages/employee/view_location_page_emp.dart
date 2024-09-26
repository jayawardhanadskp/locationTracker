import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/location_service.dart';
import 'package:location_tracker/config/config.dart';

class ViewLocationsPage extends StatefulWidget {
  const ViewLocationsPage({super.key});

  @override
  ViewLocationsPageState createState() => ViewLocationsPageState();
}

class ViewLocationsPageState extends State<ViewLocationsPage> {
  List<String> locations = [];
  LatLng? currentLocation;
  List<LatLng> polylineCoordinates = [];
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    fetchLocations();
  }

  Future<void> getCurrentLocation() async {
    Location location = Location();
    try {
      LocationData currentLocationData = await location.getLocation();
      setState(() {
        currentLocation = LatLng(
            currentLocationData.latitude!, currentLocationData.longitude!);
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> fetchLocations() async {
    locations = await LocationService().getLocations();
    for (String loc in locations) {
      await addMarkerAndPolyline(loc);
    }
    setState(() {});
  }

  Future<void> addMarkerAndPolyline(String loc) async {
    final coords = loc.split(',');
    final latLng = LatLng(double.parse(coords[0]), double.parse(coords[1]));

    markers.add(Marker(
      markerId: MarkerId(loc),
      position: latLng,
      infoWindow: InfoWindow(title: 'Location: $loc'),
    ));

    await getPolyPoints(latLng);
  }

  Future<void> getPolyPoints(LatLng destination) async {
    if (currentLocation == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    var request = PolylineRequest(
      origin: PointLatLng(currentLocation!.latitude, currentLocation!.longitude),
      destination: PointLatLng(destination.latitude, destination.longitude),
      mode: TravelMode.driving,
    );

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleApiKey: api_key,
        request: request,
      );

      // Clear the previous polyline points before adding new ones
      polylineCoordinates.clear();

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
        setState(() {}); // Refresh the UI
      } else {
        print('No points found in the route.');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  void _openGoogleMaps(double startLat, double startLng, double destLat, double destLng) async {
    final String googleMapsUrl = 'https://www.google.com/maps/dir/?api=1&origin=$startLat,$startLng&destination=$destLat,$destLng&travelmode=driving';
    
    final Uri uri = Uri.parse(googleMapsUrl); // Use Uri.parse

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $googleMapsUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Locations')),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(target: currentLocation!, zoom: 15),
                  markers: markers,
                  polylines: {
                    Polyline(
                      polylineId: const PolylineId('route'),
                      points: polylineCoordinates,
                      color: Colors.blue,
                      width: 5,
                    ),
                  },
                  myLocationEnabled: true,
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      if (currentLocation != null && locations.isNotEmpty) {
                        final lat = currentLocation!.latitude;
                        final lng = currentLocation!.longitude;

                        // Fetch the first location from the list as the destination
                        final firstLocation = locations.first.split(',');
                        final destinationLat = double.parse(firstLocation[0]);
                        final destinationLng = double.parse(firstLocation[1]);

                        print(lat.toString());
                        _openGoogleMaps(lat, lng, destinationLat, destinationLng);
                      }
                    },
                    child: const Icon(Icons.location_city),
                  ),
                ),
              ],
            ),
    );
  }
}
