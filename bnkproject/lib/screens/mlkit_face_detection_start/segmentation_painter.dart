import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

import 'translate_util.dart';

class SegmentationPainter extends CustomPainter {
  SegmentationPainter(
      this.mask,
      this.imageSize,
      this.rotation,
      this.cameraLensDirection,
      );

  final SegmentationMask mask;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final w = mask.width;
    final h = mask.height;
    final conf = mask.confidences;

    const step = 6; // 성능용 샘플링
    final paint = Paint()..style = PaintingStyle.fill;

    final maskSize = Size(w.toDouble(), h.toDouble());

    for (int y = 0; y < h; y += step) {
      for (int x = 0; x < w; x += step) {
        final idx = y * w + x;
        final c = conf[idx];
        if (c < 0.65) continue;

        final dx = translateX(x.toDouble(), size, maskSize, rotation, cameraLensDirection);
        final dy = translateY(y.toDouble(), size, maskSize, rotation, cameraLensDirection);

        paint.color = Colors.greenAccent.withOpacity(0.18 + (c * 0.20));
        canvas.drawRect(Rect.fromLTWH(dx, dy, 4, 4), paint);
      }
    }
  }

  @override
  bool shouldRepaint(SegmentationPainter oldDelegate) => oldDelegate.mask != mask;
}
