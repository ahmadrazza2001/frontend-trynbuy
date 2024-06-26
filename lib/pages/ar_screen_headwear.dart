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
      var leftEye = landmarkList.landmark[33];
      var rightEye = landmarkList.landmark[362];
      var noseTip = landmarkList.landmark[1];
      var chin = landmarkList.landmark[152];

      double eyeDistance = rightEye.x - leftEye.x;
      double stickerWidth = eyeDistance * MediaQuery.of(context).size.width * 8;
      double stickerHeight = (chin.y - noseTip.y) * MediaQuery.of(context).size.height * 3;
      stickerHeight *= 1 + (noseTip.y - chin.y) * 1;
      double centerX = (rightEye.x + leftEye.x) / 2 * MediaQuery.of(context).size.width;
      double centerY = (noseTip.y + chin.y) / 2 * MediaQuery.of(context).size.height;
      double dampeningFactor = 0.3;
      double roll = computeRoll(leftEye, rightEye) * dampeningFactor;
      double pitch = computePitch(leftEye, rightEye, noseTip) * dampeningFactor;
      double yaw = computeYaw(noseTip) * dampeningFactor;
      double depthFactor = 1 / (1.5 + noseTip.z);

      setState(() {
        arOverlay = Positioned(
          left: centerX - stickerWidth / 2.2,
          top: centerY - stickerHeight / 0.6,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..rotateZ(roll)
              ..rotateY(-yaw)
              ..rotateX(pitch)
              ..scale(depthFactor, depthFactor),
            child: Image.network(
              widget.arUrl,
              width: stickerWidth,
              height: stickerHeight,
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
