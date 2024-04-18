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
      var faceCenter = landmarkList.landmark[1];
      double imageWidth = MediaQuery.of(context).size.width * 0.5;

      double centerX = faceCenter.x * MediaQuery.of(context).size.width;
      double centerY = faceCenter.y * MediaQuery.of(context).size.height;

      setState(() {
        arOverlay = Positioned(
          left: centerX - (imageWidth / 2),
          top: centerY - (imageWidth / 1.7),
          child: Image.network(
            widget.arUrl,
            width: imageWidth,
            fit: BoxFit.cover,
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
    List<Widget> stackChildren = [
      NativeView(onViewCreated: _onViewCreated),
    ];

    if (arOverlay != null) {
      stackChildren.add(arOverlay!);
    }

    return Scaffold(
      appBar: AppBar(title: Text("Headwear AR View")),
      body: _isPermissionGranted
          ? Stack(children: stackChildren)
          : Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void dispose() {
    if (_isPermissionGranted && controller != null) {
    }
    super.dispose();
  }
}
