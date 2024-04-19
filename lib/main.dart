import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tryandbuy/pages/home_page.dart';
import 'package:tryandbuy/pages/login_page.dart';
import 'package:tryandbuy/pages/vendor_page.dart';
import 'package:tryandbuy/pages/admin_page.dart';
import 'package:tryandbuy/pages/landing_page.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Try and Buy App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingScreen(),
      routes: {
        '/login': (context) => LoginPage(),
        '/homeScreen': (context) => HomeScreen(),
        '/vendorScreen': (context) => VendorScreen(),
        '/adminScreen': (context) => AdminScreen(),
      },
    );
  }
}
