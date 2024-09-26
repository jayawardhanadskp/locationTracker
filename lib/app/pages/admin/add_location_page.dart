import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../services/location_service.dart';

class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  final TextEditingController _locationController = TextEditingController();
  LatLng? _selectedLocation;

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  void addLocation() {
    final location = _locationController.text;
    if (_selectedLocation != null) {
      // Call the location service to add the location
      LocationService().addLocation(location, _selectedLocation!.latitude, _selectedLocation!.longitude);
      Navigator.pop(context);
    } else {
      // Show an error if no location is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location on the map.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Location')),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onTap: _onMapTapped,
              initialCameraPosition: const CameraPosition(
                target: LatLng(37.7749, -122.4194), // Default to San Francisco
                zoom: 10,
              ),
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: const MarkerId('selectedLocation'),
                        position: _selectedLocation!,
                      ),
                    }
                  : {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
          ),
          ElevatedButton(
            onPressed: addLocation,
            child: const Text('Add Location'),
          ),
        ],
      ),
    );
  }
}
