import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NewProductPage extends StatefulWidget {
  @override
  _NewProductPageState createState() => _NewProductPageState();
}

class _NewProductPageState extends State<NewProductPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _keywordsController = TextEditingController();
  String _productType = "Select Type";
  final ImagePicker _picker = ImagePicker();
  final CloudinaryPublic cloudinary = CloudinaryPublic('dicebox', 'trynbuy', cache: false);
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _isLoading = false;

  List<String> productTypes = ['Glasses', 'Watch', 'Accessory'];
  List<String> imageUrls = [];
  String? arImageUrl;

  void handleImageSelection() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      List<Future> uploadTasks = pickedFiles.map((file) => uploadImage(file.path)).toList();
      await Future.wait(uploadTasks);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> uploadImage(String imagePath) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(imagePath, resourceType: CloudinaryResourceType.Image),
      );
      imageUrls.add(response.secureUrl);
      print('Uploaded image URL: ${response.secureUrl}');
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void handleArImageSelection() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _isLoading = true;
      });
      try {
        CloudinaryResponse response = await cloudinary.uploadFile(
          CloudinaryFile.fromFile(pickedFile.path, resourceType: CloudinaryResourceType.Image),
        );
        arImageUrl = response.secureUrl;
        print('Uploaded AR image URL: $arImageUrl');
      } catch (e) {
        print('Error uploading AR image: $e');
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> createProduct() async {
    if (imageUrls.isEmpty || arImageUrl == null) {
      print('Please upload all images before creating the product.');
      return;
    }
    setState(() {
      _isLoading = true;
    });

    String? token = await FlutterSecureStorage().read(key: 'authToken');

    final url = 'http://10.0.2.2:8080/api/v1/product/createProduct';
    final response = await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'keywords': _keywordsController.text.split(',').map((s) => s.trim()).toList(),
        'images': imageUrls,
        'arImage': arImageUrl,
        'productType': _productType,
      }),
    );

    if (response.statusCode == 201) {
      print('Product created successfully!');
      Navigator.pop(context);
    } else {
      print('Failed to create product: ${response.body}');
    }
    setState(() {
      _isLoading = false;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Product'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              TextField(
                controller: _keywordsController,
                decoration: InputDecoration(labelText: 'Keywords (comma separated)'),
              ),
              DropdownButtonFormField<String>(
                value: _productType != "Select Type" ? _productType : null,
                onChanged: (String? newValue) {
                  setState(() {
                    _productType = newValue!;
                  });
                },
                items: productTypes.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Product Type',
                ),
              ),
              ElevatedButton(
                onPressed: handleImageSelection,
                child: Text('Pick Images'),
              ),
              ElevatedButton(
                onPressed: handleArImageSelection,
                child: Text('Pick AR Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: createProduct,
                child: Text('Create Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
