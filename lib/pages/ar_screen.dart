import 'package:flutter/material.dart';
import 'package:flutter_mediapipe/flutter_mediapipe.dart';
import 'package:flutter_mediapipe/gen/landmark.pb.dart';
import 'package:permission_handler/permission_handler.dart';

class ArViewPage extends StatefulWidget {
  final String arUrl;

  ArViewPage({required this.arUrl});

  @override
  _ArViewPageState createState() => _ArViewPageState();
}

class _ArViewPageState extends State<ArViewPage> {
  late FlutterMediapipe controller;
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }
    if (status.isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });
    } else {
      _showError("Camera permission is denied.");
    }
  }

  void _onViewCreated(FlutterMediapipe c) {
    if (!_isPermissionGranted) {
      _showError("Camera access needed to run AR features.");
      return;
    }
    controller = c;
    controller.landMarksStream.listen(_applySticker, onError: _onError);
  }

  void _applySticker(NormalizedLandmarkList landmarkList) {
    if (landmarkList.landmark.length > 468) {
      var leftEye = landmarkList.landmark[130];
      var rightEye = landmarkList.landmark[359];
      var overlayWidth = (rightEye.x - leftEye.x) * MediaQuery.of(context).size.width;
      var overlayCenterX = (leftEye.x + rightEye.x) / 2 * MediaQuery.of(context).size.width;
      var overlayCenterY = (leftEye.y + rightEye.y) / 2 * MediaQuery.of(context).size.height;
      print("Overlay AR Image at: $overlayCenterX, $overlayCenterY with width $overlayWidth");
      // Here you would overlay the AR content using the coordinates calculated
    }
  }

  void _onError(dynamic error) {
    _showError("An error occurred in AR processing: $error");
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Product AR View")),
      body: _isPermissionGranted ? NativeView(onViewCreated: _onViewCreated) : Center(child: CircularProgressIndicator()),
    );
  }


  @override
  void dispose() {
    if (_isPermissionGranted && controller != null) {
    }
    super.dispose();
  }
}
