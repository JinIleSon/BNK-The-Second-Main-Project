import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:image_picker/image_picker.dart';

class FaceDetectorApp extends StatefulWidget {
  const FaceDetectorApp({super.key});

  @override
  State<FaceDetectorApp> createState() => _FaceDetectorAppState();
}

class _FaceDetectorAppState extends State<FaceDetectorApp> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("얼굴 인식 앱"),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: reset state
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(),
    );
  }

  Future _getImage(ImageSource source) async {}

  Future _processFile(String path) async {}

  Future<void> _processImage(InputImage inputImage) async {}
}
