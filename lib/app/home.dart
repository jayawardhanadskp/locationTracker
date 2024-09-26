import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:location_tracker/app/pages/admin/admin_home_page.dart';
import 'package:location_tracker/app/pages/employee/employee_home_page.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => AdminHomePage() ));
          }, child: Text('Admin')),
          const SizedBox(height: 30,),
           ElevatedButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => EmployeeHomePage() ));
          }, child: Text('Employee'))
        ],
      ),
    );
  }
}