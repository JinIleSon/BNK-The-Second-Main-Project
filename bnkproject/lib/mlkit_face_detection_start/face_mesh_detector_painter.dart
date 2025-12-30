import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';

import 'translate_util.dart';

class FaceMeshDetectorPainter extends CustomPainter {
  FaceMeshDetectorPainter(
      this.meshes,
      this.imageSize,
      this.rotation,
      this.cameraLensDirection,
      );

  final List<FaceMesh> meshes;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.cyanAccent;

    for (final mesh in meshes) {
      for (final p in mesh.points) {
        final dx = translateX(p.x, size, imageSize, rotation, cameraLensDirection);
        final dy = translateY(p.y, size, imageSize, rotation, cameraLensDirection);
        canvas.drawCircle(Offset(dx, dy), 1.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(FaceMeshDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.meshes != meshes;
  }
}
