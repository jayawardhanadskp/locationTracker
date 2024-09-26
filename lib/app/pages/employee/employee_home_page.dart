import 'package:flutter/material.dart';
import 'view_location_page_emp.dart';

class EmployeeHomePage extends StatelessWidget {
  const EmployeeHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Employee Home')),
      body: Center(
        child: ElevatedButton(
          child: const Text('View Locations'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ViewLocationsPage()),
            );
          },
        ),
      ),
    );
  }
}
