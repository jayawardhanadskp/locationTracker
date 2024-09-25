import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:location_tracker/config/config.dart';

class OrderTrackingPage extends StatefulWidget {
  const OrderTrackingPage({super.key});

  @override
  State<OrderTrackingPage> createState() => OrderTrackingPageState();
}

class OrderTrackingPageState extends State<OrderTrackingPage> {
  final Completer<GoogleMapController> _controller = Completer();
  static const LatLng sourceLocation =
      LatLng(6.799159447323775, 79.88897666972109);
  static const LatLng destination = LatLng(6.788013, 79.885105);
  List<LatLng> polylineCoordinates = [];

  LocationData? currentLocation;

  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  void getCurrentLocation() async {
    Location location = Location();

    // Check if the location service is enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // If the service is not enabled, request the user to enable it
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        print('Location services are disabled.');
        return;
      }
    }

    // Check for permission
    PermissionStatus permissionStatus = await location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        print('Location permission denied.');
        return;
      }
    }

    // Try to get the current location
    try {
      currentLocation = await location.getLocation();
      print(currentLocation);
      setState(() {});

      GoogleMapController googleMapController = await _controller.future;

      location.onLocationChanged.listen((newLoc) {
        currentLocation = newLoc;

        googleMapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(newLoc.latitude!, newLoc.longitude!),
                zoom: 14.5),
          ),
        );
        setState(() {});
      });
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  Future<void> getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();

    var request = PolylineRequest(
      origin: PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      destination: PointLatLng(destination.latitude, destination.longitude),
      mode: TravelMode.driving,
    );

    try {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
          googleApiKey: api_key, request: request);

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
    getPolyPoints();
    getCurrentLocation();
  }

  void setInitialCameraPosition(GoogleMapController controller) async {
    LatLngBounds bounds = LatLngBounds(
      southwest: LatLng(
        sourceLocation.latitude < destination.latitude
            ? sourceLocation.latitude
            : destination.latitude,
        sourceLocation.longitude < destination.longitude
            ? sourceLocation.longitude
            : destination.longitude,
      ),
      northeast: LatLng(
        sourceLocation.latitude > destination.latitude
            ? sourceLocation.latitude
            : destination.latitude,
        sourceLocation.longitude > destination.longitude
            ? sourceLocation.longitude
            : destination.longitude,
      ),
    );

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Track Order",
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      ),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator.adaptive())
          : GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
                setInitialCameraPosition(controller);
              },
              initialCameraPosition: CameraPosition(
                target: LatLng(
                    currentLocation!.latitude!, currentLocation!.longitude!),
                zoom: 15,
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
                Marker(
                  markerId: const MarkerId('currentLocation'),
                  position: LatLng(
                      currentLocation!.latitude!, currentLocation!.longitude!),
                ),
                const Marker(
                    markerId: MarkerId("source"), position: sourceLocation),
                const Marker(
                    markerId: MarkerId("destination"), position: destination),
              },
            ),
    );
  }
}
