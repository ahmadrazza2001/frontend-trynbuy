import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_mediapipe/flutter_mediapipe.dart';
import 'package:flutter_mediapipe/gen/landmark.pb.dart';
import 'package:permission_handler/permission_handler.dart';

class ArViewFacemask extends StatefulWidget {
  final String arUrl;

  ArViewFacemask({required this.arUrl});

  @override
  _ArViewFacemaskState createState() => _ArViewFacemaskState();
}

class _ArViewFacemaskState extends State<ArViewFacemask> {
  late FlutterMediapipe controller;
  bool _isPermissionGranted = false;
  bool _cameraOn = true;
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

  double computeYaw(NormalizedLandmark nose) {
    return (0.5 - nose.x) * 2 * math.pi;
  }

  double computeRoll(NormalizedLandmark leftEye, NormalizedLandmark rightEye) {
    return math.atan2(rightEye.y - leftEye.y, rightEye.x - leftEye.x);
  }


  double computePitch(NormalizedLandmark leftEye, NormalizedLandmark rightEye, NormalizedLandmark nose) {
    double midPointX = (leftEye.x + rightEye.x) / 2;
    double midPointY = (leftEye.y + rightEye.y) / 2;
    double verticalDistance = nose.y - midPointY;
    return math.atan2(verticalDistance, (nose.x - midPointX).abs());
  }
  void _applySticker(NormalizedLandmarkList landmarkList) {
    if (landmarkList.landmark.isNotEmpty) {
      var leftEye = landmarkList.landmark[33];   // Left eye landmark
      var rightEye = landmarkList.landmark[362]; // Right eye landmark
      var noseTip = landmarkList.landmark[1];    // Nose tip landmark

      // Compute eye distance for scaling and adjust the width to cover the face more broadly
      double eyeDistance = rightEye.x - leftEye.x;
      double overlayWidth = eyeDistance * MediaQuery.of(context).size.width;

      // Center the sticker between the eyes but adjust for full face width
      double centerX = (rightEye.x + leftEye.x) / 2 * MediaQuery.of(context).size.width;
      double centerY = (rightEye.y + leftEye.y) / 2 * MediaQuery.of(context).size.height;

      // Compute rotations with a dampening factor to reduce sensitivity
      double dampeningFactor = 0.5; // Reduce this factor to make transformations less sensitive
      double roll = computeRoll(leftEye, rightEye) * dampeningFactor;
      double pitch = computePitch(leftEye, rightEye, noseTip) * dampeningFactor;
      double yaw = computeYaw(noseTip) * dampeningFactor;

      // Adjust depth factor and apply it to both width and height
      double depthFactor = 1 / (1 + noseTip.z);
      double scaledWidth = overlayWidth * depthFactor * 2; // Increase the width by 100% to stretch to chin
      double scaledHeight = scaledWidth * 0.9;  // Adjust height proportionally based on design needs

      // Compute vertical position to align the sticker with the nose
      double noseY = noseTip.y * MediaQuery.of(context).size.height;
      double stickerTop = noseY - (scaledHeight / 1.4);

      setState(() {
        arOverlay = Positioned(
          left: centerX - (scaledWidth / 2.5),
          top: stickerTop,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ(roll)   // Roll rotation around the Z axis
              ..rotateY(-yaw)   // Yaw rotation around the Y axis
              ..rotateX(pitch)  // Pitch rotation around the X axis
              ..scale(depthFactor, depthFactor), // Scale down based on depth
            child: Image.network(
              widget.arUrl,
              width: scaledWidth,
              height: scaledHeight,
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
      appBar: AppBar(title: Text("Facemask AR View")),
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
      // Properly dispose of the controller if needed
    }
    super.dispose();
  }
}
