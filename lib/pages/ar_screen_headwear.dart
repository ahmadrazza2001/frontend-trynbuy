import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_mediapipe/flutter_mediapipe.dart';
import 'package:flutter_mediapipe/gen/landmark.pb.dart';
import 'package:permission_handler/permission_handler.dart';

class ArViewHeadwear extends StatefulWidget {
  final String arUrl;

  ArViewHeadwear({required this.arUrl});

  @override
  _ArViewPageState createState() => _ArViewPageState();
}

class _ArViewPageState extends State<ArViewHeadwear> {
  late FlutterMediapipe controller;
  bool _isPermissionGranted = false;
  bool _cameraOn = true; // State variable to control camera preview visibility
  Widget? arOverlay;

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
    if (landmarkList.landmark.isNotEmpty) {
      var leftEye = landmarkList.landmark[33];   // Left eye landmark
      var rightEye = landmarkList.landmark[362]; // Right eye landmark

      double eyeDistance = rightEye.x - leftEye.x;
      double overlayWidth = eyeDistance * MediaQuery.of(context).size.width * 5; // Increased size by 50%

      double centerX = (rightEye.x + leftEye.x) / 2 * MediaQuery.of(context).size.width;
      double centerY = (rightEye.y + leftEye.y) / 2 * MediaQuery.of(context).size.height;
      double angle = math.atan2(rightEye.y - leftEye.y, rightEye.x - leftEye.x);

      double topPosition = centerY - (overlayWidth / 1.2); // Adjust vertical position to center on eyes

      setState(() {
        arOverlay = Positioned(
          left: centerX - (overlayWidth / 2.2),
          top: topPosition,
          child: Transform.rotate(
            angle: angle,
            child: Image.network(
              widget.arUrl,
              width: overlayWidth,
              fit: BoxFit.cover,
            ),
          ),
        );
      });
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
      appBar: AppBar(title: Text("Headwear AR View")),
      body: _isPermissionGranted && _cameraOn
          ? Stack(children: [
        NativeView(onViewCreated: _onViewCreated),
        if (arOverlay != null) arOverlay!
      ])
          : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _cameraOn = false; // Toggle camera visibility
          });
          Navigator.pop(context); // Navigate back or to another screen
        },
        child: Icon(Icons.close),
      ),
    );
  }

  @override
  void dispose() {
    if (_isPermissionGranted && controller != null) {
    }
    super.dispose();
  }
}
