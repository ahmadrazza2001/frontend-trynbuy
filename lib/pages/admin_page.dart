import 'package:flutter/material.dart';
import 'package:tryandbuy/pages/login_page.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Try'nBuy"),
        backgroundColor: Colors.white,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text('Login', style: TextStyle(color: Colors.white)))
        ],
      ),
    );
  }
}