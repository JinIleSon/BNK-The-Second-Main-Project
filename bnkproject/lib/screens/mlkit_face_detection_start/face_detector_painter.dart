import 'dart:math';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'translate_util.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
      this.faces,
      this.imageSize,
      this.rotation,
      this.cameraLensDirection,
      );

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = Colors.redAccent;

    final pointPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.orangeAccent;

    for (final face in faces) {
      final rect = _toCanvasRect(face.boundingBox, size);
      canvas.drawRect(rect, boxPaint);

      for (final lm in face.landmarks.values) {
        if (lm == null) continue;
        final x = translateX(lm.position.x.toDouble(), size, imageSize, rotation, cameraLensDirection);
        final y = translateY(lm.position.y.toDouble(), size, imageSize, rotation, cameraLensDirection);
        canvas.drawCircle(Offset(x, y), 3.0, pointPaint);
      }

      for (final contour in face.contours.values) {
        if (contour == null) continue;
        for (final p in contour.points) {
          final x = translateX(p.x.toDouble(), size, imageSize, rotation, cameraLensDirection);
          final y = translateY(p.y.toDouble(), size, imageSize, rotation, cameraLensDirection);
          canvas.drawCircle(Offset(x, y), 1.4, pointPaint);
        }
      }

      final label = 'id:${face.trackingId ?? '-'}';
      final tp = TextPainter(
        text: TextSpan(text: label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(rect.left, max(0, rect.top - tp.height)));
    }
  }

  Rect _toCanvasRect(Rect box, Size canvasSize) {
    final left = translateX(box.left, canvasSize, imageSize, rotation, cameraLensDirection);
    final top = translateY(box.top, canvasSize, imageSize, rotation, cameraLensDirection);
    final right = translateX(box.right, canvasSize, imageSize, rotation, cameraLensDirection);
    final bottom = translateY(box.bottom, canvasSize, imageSize, rotation, cameraLensDirection);

    return Rect.fromLTRB(
      min(left, right),
      min(top, bottom),
      max(left, right),
      max(top, bottom),
    );
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}
