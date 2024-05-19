import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:tryandbuy/api/network_util.dart';
import 'package:tryandbuy/pages/ar_screen.dart';
import 'package:tryandbuy/pages/ar_screen_facemask.dart';
import 'package:tryandbuy/pages/ar_screen_headwear.dart';
import 'package:tryandbuy/pages/ar_screen_body.dart';
import 'package:tryandbuy/pages/login_page.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  List<dynamic> _products = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    final response = await NetworkUtil.tryRequest('/api/v1/product/allProducts', headers: {'Content-Type': 'application/json'});
    if (response != null && response.statusCode == 200) {
      setState(() {
        _products = json.decode(response.body)['body'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
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
                  String type = productType.toLowerCase();
                  if (type.contains('glasses')) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ArViewPage(arUrl: arUrl)));
                  } else if (type.contains('headwear')) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ArViewHeadwear(arUrl: arUrl)));
                  } else if (type.contains('facemask')) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ArViewFacemask(arUrl: arUrl)));
                  }
                  else if (type.contains('shirt')) {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ArBodyPage(arUrl: arUrl)));
                  }

                },
                icon: Icon(Icons.visibility, color: Colors.green),
                label: Text('AR View', style: TextStyle(color: Colors.green),)
            ),
            SizedBox(height: 5),
            ElevatedButton.icon(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
            },
            icon: Icon(Icons.add_shopping_cart, color: Colors.black),
              label: Text('Add to cart', style: TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
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
                decoration: BoxDecoration(color: Colors.green[200]),
                child: Image.network(imageUrl, fit: BoxFit.cover),
              );
            }
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Try'nBuy", style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.green,
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              },
              child: Text('Login', style: TextStyle(color: Colors.white))
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10),
            _isLoading ? CircularProgressIndicator() : _buildMainCarousel(),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('New Arrivals', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Container(
              height: 330,
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
        currentIndex: _currentIndex,
        onTap: (index) => _onTapItem(context, index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.green[200],
      ),
    );
  }

  void _onTapItem(BuildContext context, int index) {
    setState(() {
      _currentIndex = index;
    });
    if (_currentIndex == 1 || _currentIndex == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}
