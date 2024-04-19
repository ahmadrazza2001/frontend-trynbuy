import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tryandbuy/pages/ar_screen.dart';
import 'package:tryandbuy/pages/ar_screen_headwear.dart';
import 'package:tryandbuy/pages/login_page.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(
      Uri.parse('http://192.168.1.132:8080/api/v1/product/allProducts'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      setState(() {
        _products = json.decode(response.body)['body'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        print('Failed to fetch products: ${response.body}');
      });
    }
  }

  Widget _buildMainCarousel() {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200.0,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
        pauseAutoPlayOnTouch: true,
        viewportFraction: 0.8,
      ),
      items: _products.map((product) {
        String imageUrl = (product['images'] is List) ? product['images'][0] : product['images'];
        return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(color: Colors.amber),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              );
            }
        );
      }).toList(),
    );
  }
  Widget _buildProductCard(String productName, String price, String imageUrl, String arUrl, String productType) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(imageUrl, width: double.infinity, height: 150, fit: BoxFit.cover),
            SizedBox(height: 5),
            Text(productName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(price, style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 10),
            ElevatedButton.icon(
                onPressed: () {
                  // Ensure comparison is case-insensitive
                  String type = productType.toLowerCase();
                  print('Product type is: $type'); // Debug print
                  if (type == 'glasses') {
                    print('Navigating to Glasses AR View'); // Debug print
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ArViewPage(arUrl: arUrl)));
                  } else if (type == 'headwear') {
                    print('Navigating to Headwear AR View'); // Debug print
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ArViewHeadwear(arUrl: arUrl)));
                  } else {
                    print('Product type $type is not recognized'); // Debug print
                  }
                },
                icon: Icon(Icons.visibility),
                label: Text('Try in AR')
            )
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Try'nBuy"),
        backgroundColor: Colors.orangeAccent,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text('Login', style: TextStyle(color: Colors.black))
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            _isLoading
                ? CircularProgressIndicator()
                : _buildMainCarousel(),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Featuring Now', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Container(
              height: 300,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _products.map((product) {
                  String imageUrl = (product['images'] is List) ? product['images'][0] : product['images'];
                  String arUrl = (product['arImage'] is List) ? product['arImage'][0] : product['arImage'];
                  String productType = product['productType'] ?? 'unknown';
                  return _buildProductCard(
                      product['title'],
                      product['price'].toString(),
                      imageUrl,
                      arUrl,
                      productType
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart_checkout), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile')
        ],
        selectedItemColor: Colors.amber[800],
      ),
    );
  }
}
