import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_mediapipe/flutter_mediapipe.dart';
import 'package:flutter_mediapipe/gen/landmark.pb.dart';
import 'package:permission_handler/permission_handler.dart';

class ArBodyPage extends StatefulWidget {
  final String arUrl;

  ArBodyPage({required this.arUrl});

  @override
  _ArBodyPageState createState() => _ArBodyPageState();
}

class _ArBodyPageState extends State<ArBodyPage> {
  late FlutterMediapipe controller;
  bool _isPermissionGranted = false;
  bool _cameraOn = true;
  Widget? arOverlay;
  final PositionSmoothing positionSmoothing = PositionSmoothing();

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
    controller.landMarksStream.listen(_applyBodySticker, onError: _onError);
  }

  void _applyBodySticker(NormalizedLandmarkList landmarkList) {
    if (landmarkList.landmark.isNotEmpty) {
      double screenHeight = MediaQuery.of(context).size.height;
      double screenWidth = MediaQuery.of(context).size.width;

      positionSmoothing.updatePosition(11, Offset(landmarkList.landmark[11].x * screenWidth, landmarkList.landmark[11].y * screenHeight));
      positionSmoothing.updatePosition(12, Offset(landmarkList.landmark[12].x * screenWidth, landmarkList.landmark[12].y * screenHeight));

      Offset smoothedLeftShoulder = positionSmoothing.getSmoothedPosition(11);
      Offset smoothedRightShoulder = positionSmoothing.getSmoothedPosition(12);

      double midPointX = (smoothedLeftShoulder.dx + smoothedRightShoulder.dx) / 2;
      double midPointY = (smoothedLeftShoulder.dy + smoothedRightShoulder.dy) / 2;

      double stickerScale = calculateScale(smoothedLeftShoulder, smoothedRightShoulder);

      setState(() {
        arOverlay = Stack(
          children: [
            Positioned(
              left: midPointX - stickerScale / 2,
              top: midPointY - stickerScale / 50,
              child: Image.network(
                widget.arUrl,
                width: stickerScale,
                height: stickerScale,
                fit: BoxFit.cover,
              ),
            ),
            _buildLeftMarker(smoothedLeftShoulder, "L-Shoulder"),
            _buildRightMarker(smoothedRightShoulder, "R-Shoulder"),
          ],
        );
      });
    }
  }

  double calculateScale(Offset leftPoint, Offset rightPoint) {
    double distance = (rightPoint - leftPoint).distance;
    return 100 + distance * 180;
  }

  Widget _buildLeftMarker(Offset position, String label) {
    return Positioned(
      left: position.dx - 150,
      top: position.dy + 10,
      child: Container(
        width: 40,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildRightMarker(Offset position, String label) {
    return Positioned(
      left: position.dx + 120,
      top: position.dy + 10,
      child: Container(
        width: 40,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.green,
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.bold)),
        ),
      ),
    );
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
          actions: [TextButton(child: Text("OK"), onPressed: () => Navigator.of(context).pop())],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shirt AR View")),
      body: _isPermissionGranted && _cameraOn ? Stack(children: [NativeView(onViewCreated: _onViewCreated), if (arOverlay != null) arOverlay!]) : Center(child: CircularProgressIndicator()),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _cameraOn = false;
          });
          Navigator.pop(context);
        },
        child: Icon(Icons.close),
      ),
    );
  }

  @override
  void dispose() {
    if (_isPermissionGranted && controller != null) {
      // controller.close();
    }
    super.dispose();
  }
}

class PositionSmoothing {
  Map<int, List<Offset>> history = {};
  int smoothingWindow = 10;

  void updatePosition(int index, Offset newPosition) {
    if (!history.containsKey(index)) {
      history[index] = [];
    }
    history[index]!.add(newPosition);
    if (history[index]!.length > smoothingWindow) {
      history[index]!.removeAt(0);
    }
  }

  Offset getSmoothedPosition(int index) {
    if (history.containsKey(index) && history[index]!.isNotEmpty) {
      return Offset(
          history[index]!.map((e) => e.dx).reduce((a, b) => a + b) / history[index]!.length,
          history[index]!.map((e) => e.dy).reduce((a, b) => a + b) / history[index]!.length
      );
    }
    return Offset.zero;
  }
}
