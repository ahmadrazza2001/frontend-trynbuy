import 'package:flutter/material.dart';
import 'package:tryandbuy/api/auth_api.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    var result = await AuthApi.login(email, password);

    if (result['success']) {
      switch (result['role']) {
        case 'user':
          Navigator.pushReplacementNamed(context, '/homeScreen');
          break;
        case 'vendor':
          Navigator.pushReplacementNamed(context, '/vendorScreen');
          break;
        case 'admin':
          Navigator.pushReplacementNamed(context, '/adminScreen');
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Unexpected user role received.'),
          ));
          break;
      }
    } else {
      // Display error message from the login result
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result['error']),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleLogin,
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
