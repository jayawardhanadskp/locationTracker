import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location_tracker/config/config.dart';
import 'order_input_page.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? sourceLocation;
  LatLng? destination;
  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;

  void getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }
    }

    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        print('Location permission denied.');
        return;
      }
    }

    try {
      currentLocation = await location.getLocation();
      setState(() {});

      location.onLocationChanged.listen((newLoc) {
        currentLocation = newLoc;
        final googleMapController = _controller.future;
        googleMapController.then((controller) {
          // Update camera position to follow current location
          controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(newLoc.latitude!, newLoc.longitude!),
              zoom: 15, // Keep a reasonable zoom level
            ),
          ));
        });
        setState(() {});
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> getPolyPoints() async {
    if (sourceLocation == null || destination == null) return;

    PolylinePoints polylinePoints = PolylinePoints();
    var request = PolylineRequest(
      origin: PointLatLng(sourceLocation!.latitude, sourceLocation!.longitude),
      destination: PointLatLng(destination!.latitude, destination!.longitude),
      mode: TravelMode.driving,
    );

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: api_key, request: request);

      polylineCoordinates.clear(); // Clear previous coordinates
      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        });
        setState(() {});
      } else {
        print('No points found in the route.');
      }
    } catch (e) {
      print('Exception: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  void openLocationInput() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationInputPage(
          onLocationsSelected: (source, dest) {
            setState(() {
              sourceLocation = source;
              destination = dest;
            });
            getPolyPoints(); // Fetch new polyline points if locations are set
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track Order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_location),
            onPressed: openLocationInput,
          ),
        ],
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (sourceLocation != null)
                        Text(
                          'Source Location: (${sourceLocation!.latitude}, ${sourceLocation!.longitude})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      if (destination != null)
                        Text(
                          'Destination: (${destination!.latitude}, ${destination!.longitude})',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: GoogleMap(
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                      // Set the initial camera position with zoom level 15
                      controller.moveCamera(CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                          zoom: 15, // Start at zoom level 15
                        ),
                      ));
                    },
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                      zoom: 15, // Start at zoom level 15
                    ),
                    polylines: {
                      Polyline(
                        polylineId: const PolylineId("route"),
                        points: polylineCoordinates,
                        color: Colors.black,
                        width: 8,
                      ),
                    },
                    markers: {
                      if (sourceLocation != null)
                        Marker(
                          markerId: const MarkerId("source"),
                          position: sourceLocation!,
                        ),
                      if (destination != null)
                        Marker(
                          markerId: const MarkerId("destination"),
                          position: destination!,
                        ),
                      Marker(
                        markerId: const MarkerId('currentLocation'),
                        position: LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
                      ),
                    },
                    myLocationEnabled: true, // Enable location tracking
                    zoomGesturesEnabled: true, // Allow zoom gestures
                    scrollGesturesEnabled: true, // Allow scroll gestures
                  ),
                ),
              ],
            ),
    );
  }
}
