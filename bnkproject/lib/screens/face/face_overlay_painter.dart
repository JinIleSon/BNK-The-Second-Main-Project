import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceOverlayPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final bool isFrontCamera;

  FaceOverlayPainter({
    required this.faces,
    required this.imageSize,
    required this.isFrontCamera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final boxPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 단순 스케일 매핑(AspectRatio를 CameraPreview와 동일하게 맞춘다는 전제)
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    Offset mapPoint(Offset p) {
      double dx = p.dx * scaleX;
      double dy = p.dy * scaleY;
      if (isFrontCamera) {
        dx = size.width - dx; // 미러 보정
      }
      return Offset(dx, dy);
    }

    Rect mapRect(Rect r) {
      final leftTop = mapPoint(Offset(r.left, r.top));
      final rightBottom = mapPoint(Offset(r.right, r.bottom));
      return Rect.fromPoints(leftTop, rightBottom);
    }

    for (final face in faces) {
      // 얼굴 박스
      canvas.drawRRect(
        RRect.fromRectAndRadius(mapRect(face.boundingBox), const Radius.circular(16)),
        boxPaint,
      );

      // 윤곽선(눈썹/눈/입술/얼굴 외곽 등) - GIF 느낌의 핵심
      for (final type in FaceContourType.values) {
        final contour = face.contours[type];
        final points = contour?.points;
        if (points == null || points.isEmpty) continue;

        final path = Path()..moveTo(mapPoint(points.first).dx, mapPoint(points.first).dy);
        for (int i = 1; i < points.length; i++) {
          final pt = mapPoint(points[i]);
          path.lineTo(pt.dx, pt.dy);
        }
        // 닫을지 여부(입술/얼굴 윤곽은 닫아도 되고, 눈썹은 보통 안 닫음)
        canvas.drawPath(path, linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant FaceOverlayPainter oldDelegate) {
    return oldDelegate.faces != faces ||
        oldDelegate.imageSize != imageSize ||
        oldDelegate.isFrontCamera != isFrontCamera;
  }
}
