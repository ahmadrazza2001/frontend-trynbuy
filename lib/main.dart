import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tryandbuy/pages/home_page.dart';
import 'package:tryandbuy/pages/login_page.dart';
import 'package:tryandbuy/pages/vendor_page.dart';
import 'package:tryandbuy/pages/admin_page.dart';
import 'package:tryandbuy/pages/landing_page.dart'; // Make sure you have this page
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

List<CameraDescription> cameras = [];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARCore Flutter Plugin Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingScreen(), // Set LandingScreen as the default home
      routes: {
        '/login': (context) => LoginPage(),
        '/homeScreen': (context) => HomeScreen(),
        '/vendorScreen': (context) => VendorScreen(),
        '/adminScreen': (context) => AdminScreen(),
      },
    );
  }
}
