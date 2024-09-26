import 'package:flutter/material.dart';
import 'add_location_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Home')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Add Location'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddLocationPage()),
            );
          },
        ),
      ),
    );
  }
}
