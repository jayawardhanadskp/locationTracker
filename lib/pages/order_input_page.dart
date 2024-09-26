import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationInputPage extends StatefulWidget {
  final Function(LatLng, LatLng) onLocationsSelected;

  const LocationInputPage({super.key, required this.onLocationsSelected});

  @override
  _LocationInputPageState createState() => _LocationInputPageState();
}

class _LocationInputPageState extends State<LocationInputPage> {
  LatLng? source;
  LatLng? destination;

  Set<Marker> _markers = {};

  void _onMapTapped(LatLng position) {
    setState(() {
      if (source == null) {
        source = position;
        _markers.add(Marker(
          markerId: const MarkerId('source'),
          position: source!,
          infoWindow: const InfoWindow(title: 'Source'),
        ));
      } else if (destination == null) {
        destination = position;
        _markers.add(Marker(
          markerId: const MarkerId('destination'),
          position: destination!,
          infoWindow: const InfoWindow(title: 'Destination'),
        ));
      } else {
        // Reset both if already set
        source = position;
        destination = null; // Reset destination to allow a new one
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('source'),
          position: source!,
          infoWindow: const InfoWindow(title: 'Source'),
        ));
      }
    });
  }

  void submitLocations() {
    if (source != null && destination != null) {
      widget.onLocationsSelected(source!, destination!);
      Navigator.pop(context);
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both locations")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Locations")),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: (GoogleMapController controller) {
                // You can set initial camera position here if needed
              },
              onTap: _onMapTapped,
              markers: _markers,
              initialCameraPosition: const CameraPosition(
                target: LatLng(6.9271, 79.9614), // Default position (adjust as needed)
                zoom: 12,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: submitLocations,
              child: const Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }
}
