import 'dart:math';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceOverlayPainter extends CustomPainter {
  FaceOverlayPainter({
    required this.faces,
    required this.imageSize,
    required this.imageRotation,
    required this.cameraLensDirection,
  });

  final List<Face> faces;
  final Size imageSize;
  final InputImageRotation imageRotation;
  final CameraLensDirection cameraLensDirection;

  // ✅ final 필드로 두지 말고 getter로 계산
  bool get isFrontCamera => cameraLensDirection == CameraLensDirection.front;

  // ✅ Point<int> -> Offset (캔버스 좌표로 매핑)
  Offset mapPoint(Point<int> p, Size canvasSize) {
    double x = p.x.toDouble();
    double y = p.y.toDouble();

    double imgW = imageSize.width;
    double imgH = imageSize.height;

    double tx, ty;

    switch (imageRotation) {
      case InputImageRotation.rotation90deg:
        tx = y;
        ty = imgW - x;
        final tmp = imgW;
        imgW = imgH;
        imgH = tmp;
        break;

      case InputImageRotation.rotation270deg:
        tx = imgH - y;
        ty = x;
        final tmp = imgW;
        imgW = imgH;
        imgH = tmp;
        break;

      case InputImageRotation.rotation180deg:
        tx = imgW - x;
        ty = imgH - y;
        break;

      case InputImageRotation.rotation0deg:
      default:
        tx = x;
        ty = y;
        break;
    }

    final scaleX = canvasSize.width / imgW;
    final scaleY = canvasSize.height / imgH;

    double cx = tx * scaleX;
    final cy = ty * scaleY;

    if (isFrontCamera) {
      cx = canvasSize.width - cx; // ✅ 전면카메라 미러
    }
    return Offset(cx, cy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final face in faces) {
      // 예시: 얼굴 윤곽(contour) 라인 그리기
      final contour = face.contours[FaceContourType.face];
      final points = contour?.points;
      if (points == null || points.isEmpty) continue;

      final first = mapPoint(points.first, size);
      final path = Path()..moveTo(first.dx, first.dy);

      for (int i = 1; i < points.length; i++) {
        final pt = mapPoint(points[i], size);
        path.lineTo(pt.dx, pt.dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant FaceOverlayPainter oldDelegate) {
    return oldDelegate.faces != faces ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.imageRotation != imageRotation ||
        oldDelegate.cameraLensDirection != cameraLensDirection;
  }
}
