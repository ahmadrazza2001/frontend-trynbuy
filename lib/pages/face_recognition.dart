// import 'dart:ui' as ui;
// import 'dart:typed_data';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:google_ml_kit/google_ml_kit.dart';
//
// import 'package:http/http.dart' as http;
// import '../main.dart';
//
// Future<ui.Image> loadImage(String imagePath) async {
//   final response = await http.get(Uri.parse(imagePath));
//   final bytes = response.bodyBytes;
//   return await decodeImageFromList(bytes);
// }
//
// class FaceDetectionView extends StatefulWidget {
//   final String arUrl;
//
//   FaceDetectionView({Key? key, required this.arUrl}) : super(key: key);
//
//   @override
//   _FaceDetectionViewState createState() => _FaceDetectionViewState();
// }
//
// class _FaceDetectionViewState extends State<FaceDetectionView> {
//   late CameraController _controller;
//   late FaceDetector _faceDetector;
//   bool isDetecting = false;
//   List<Face> faces = [];
//   ui.Image? image;
//
//   @override
//   void initState() {
//     super.initState();
//     _faceDetector = GoogleMlKit.vision.faceDetector();
//     _initializeCamera();
//     loadImage(widget.arUrl).then((loadedImage) {
//       setState(() {
//         image = loadedImage;
//       });
//     });
//   }
//
//   void _initializeCamera() async {
//     final camera = cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.front);
//     _controller = CameraController(camera, ResolutionPreset.high);
//     await _controller.initialize();
//     setState(() {});
//     _controller.startImageStream((cameraImage) async {
//       if (!isDetecting) {
//         isDetecting = true;
//         final inputImage = await _processCameraImage(cameraImage, camera.sensorOrientation);
//         final facesDetected = await _faceDetector.processImage(inputImage);
//         setState(() {
//           faces = facesDetected;
//         });
//         isDetecting = false;
//       }
//     });
//   }
//
//   Future<InputImage> _processCameraImage(CameraImage cameraImage, int sensorOrientation) async {
//     final WriteBuffer allBytes = WriteBuffer();
//     for (Plane plane in cameraImage.planes) {
//       allBytes.putUint8List(plane.bytes);
//     }
//     final bytes = allBytes.done().buffer.asUint8List();
//
//     final Size imageSize = Size(cameraImage.width.toDouble(), cameraImage.height.toDouble());
//     final imageRotation = _rotationIntToImageRotation(sensorOrientation);
//
//     final inputImageFormat = InputImageFormatMethods.fromRawValue(cameraImage.format.raw);
//     final planeData = cameraImage.planes.map(
//           (Plane plane) => InputImagePlaneMetadata(
//         bytesPerRow: plane.bytesPerRow,
//         height: plane.height,
//         width: plane.width,
//       ),
//     ).toList();
//
//     final inputImageData = InputImageData(
//       size: imageSize,
//       imageRotation: imageRotation,
//       inputImageFormat: inputImageFormat ?? InputImageFormat.nv21,
//       planeData: planeData,
//     );
//
//     return InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
//   }
//
//
//   InputImageRotation _rotationIntToImageRotation(int sensorOrientation) {
//     switch (sensorOrientation) {
//       case 0: return InputImageRotation.rotation0deg;
//       case 90: return InputImageRotation.rotation90deg;
//       case 180: return InputImageRotation.rotation180deg;
//       case 270: return InputImageRotation.rotation270deg;
//       default: return InputImageRotation.rotation0deg;
//     }
//   }
//
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _faceDetector.close();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Face Detection')),
//       body: Stack(
//         fit: StackFit.expand,
//         children: <Widget>[
//           CameraPreview(_controller),
//           if (image != null)
//             CustomPaint(
//               painter: FacePainter(faces: faces, image: image!),
//             ),
//         ],
//       ),
//     );
//   }
//
//   InputImageData({required ui.Size size, required InputImageRotation imageRotation, required InputImageFormat inputImageFormat, required List<dynamic> planeData}) {}
//
//   InputImagePlaneMetadata({required int bytesPerRow, int? height, int? width}) {}
// }
//
// class FacePainter extends CustomPainter {
//   List<Face> faces;
//   ui.Image image;
//
//   FacePainter({required this.faces, required this.image});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     for (var face in faces) {
//       final rect = face.boundingBox;
//       canvas.drawImageRect(image, rect, rect, Paint());
//     }
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }
