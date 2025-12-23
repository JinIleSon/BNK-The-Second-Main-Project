import 'dart:io';
import 'dart:typed_data';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ DeviceOrientation
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FaceAuthResult {
  final String path;
  final DateTime capturedAt;
  final bool turnedLeft;
  final bool turnedRight;

  const FaceAuthResult({
    required this.path,
    required this.capturedAt,
    required this.turnedLeft,
    required this.turnedRight,
  });

  bool get demoPass => turnedLeft && turnedRight && path.isNotEmpty;
}

class FaceAuthScreen extends StatefulWidget {
  const FaceAuthScreen({super.key});

  @override
  State<FaceAuthScreen> createState() => _FaceAuthScreenState();
}

class _FaceAuthScreenState extends State<FaceAuthScreen>
    with WidgetsBindingObserver {
  CameraController? _controller;
  late final FaceDetector _detector;

  bool _busy = false;
  bool _capturing = false;

  bool _initDone = false;
  String? _initError;

  String _hint = '얼굴을 중앙 프레임에 맞춰주세요';
  bool _turnedLeft = false;
  bool _turnedRight = false;

  // ✅ 연속 프레임 디바운스
  int _leftHit = 0;
  int _rightHit = 0;
  static const int _hitNeed = 3;

  // 오버레이/디버그용
  Face? _lastFace;
  Size? _lastImageSize;
  InputImageRotation? _lastRotation;
  bool _isFrontCamera = true;

  String _debugText = 'NO FACE';
  DateTime _lastDebugUpdate = DateTime.fromMillisecondsSinceEpoch(0);

  // 튜닝 포인트(데모 기준)
  static const double _minFaceAreaRatio = 0.10;
  static const double _centerXMin = 0.22;
  static const double _centerXMax = 0.78;
  static const double _centerYMin = 0.18;
  static const double _centerYMax = 0.82;
  static const double _yawLeft = -10;
  static const double _yawRight = 10;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _detector = FaceDetector(
      options: FaceDetectorOptions(
        // ✅ 오버레이/랜드마크/컨투어 목적이면 accurate가 안정적
        performanceMode: FaceDetectorMode.accurate,
        enableTracking: true,
        enableContours: true,
        enableLandmarks: true,
      ),
    );

    _init();
  }

  Future<void> _init() async {
    try {
      final camStatus = await Permission.camera.request(); // ✅ 네임 충돌 방지
      if (!camStatus.isGranted) {
        if (!mounted) return;
        setState(() {
          _initError = '카메라 권한이 필요합니다';
          _initDone = true;
        });
        return;
      }

      final cameras = await availableCameras();
      final front = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _isFrontCamera = front.lensDirection == CameraLensDirection.front;

      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize().timeout(const Duration(seconds: 10));
      await controller.startImageStream(_onFrame);

      if (!mounted) return;
      setState(() {
        _controller = controller;
        _initDone = true;
        _initError = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _initError = '카메라 초기화 실패: $e';
        _initDone = true;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;

    if (state == AppLifecycleState.paused) {
      if (c.value.isStreamingImages) {
        c.stopImageStream().catchError((_) {});
      }
    } else if (state == AppLifecycleState.resumed) {
      if (!_capturing && !c.value.isStreamingImages) {
        c.startImageStream(_onFrame).catchError((_) {});
      }
    }
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_busy || _capturing || _controller == null) return;
    _busy = true;

    try {
      final input = _toInputImage(image, _controller!.description);
      final faces = await _detector.processImage(input);

      if (faces.isEmpty) {
        _updateDebug(noFace: true);

        // ✅ 감지 실패 시 진행 상태는 유지, hit 카운트만 리셋
        _leftHit = 0;
        _rightHit = 0;

        _updateUi(
          hint: '얼굴이 인식되지 않습니다',
          left: _turnedLeft,
          right: _turnedRight,
        );
        return;
      }

      faces.sort(
            (a, b) => (b.boundingBox.width * b.boundingBox.height)
            .compareTo(a.boundingBox.width * a.boundingBox.height),
      );
      final face = faces.first;

      final meta = input.metadata!;
      final w = meta.size.width;
      final h = meta.size.height;

      // yaw 계산(used)
      final yawRawVal = face.headEulerAngleY ?? 0.0;
      final yawUsedVal = _isFrontCamera ? -yawRawVal : yawRawVal;

      _updateDebug(
        noFace: false,
        face: face,
        imageSize: meta.size,
        rotation: meta.rotation,
        yawRaw: yawRawVal,
        yawUsed: yawUsedVal,
      );

      // 1) 얼굴 크기
      final area = face.boundingBox.width * face.boundingBox.height;
      final bigEnough = area >= (w * h) * _minFaceAreaRatio;

      // 2) 중앙 여부
      final cx = face.boundingBox.center.dx;
      final cy = face.boundingBox.center.dy;
      final inCenter = (cx > w * _centerXMin && cx < w * _centerXMax) &&
          (cy > h * _centerYMin && cy < h * _centerYMax);

      // 3) 라이브니스(좌/우) - ✅ 연속 프레임 만족 시 확정
      if (!_turnedLeft) {
        _leftHit = (yawUsedVal <= _yawLeft) ? (_leftHit + 1) : 0;
        if (_leftHit > _hitNeed) _leftHit = _hitNeed;
      }
      if (!_turnedRight) {
        _rightHit = (yawUsedVal >= _yawRight) ? (_rightHit + 1) : 0;
        if (_rightHit > _hitNeed) _rightHit = _hitNeed;
      }

      final left = _turnedLeft || _leftHit >= _hitNeed;
      final right = _turnedRight || _rightHit >= _hitNeed;

      String hint = '얼굴을 중앙 프레임에 맞춰주세요';
      if (!bigEnough) hint = '조금 더 가까이 와주세요';
      else if (!inCenter) hint = '얼굴을 중앙에 맞춰주세요';
      else if (!left) hint = '고개를 왼쪽으로 돌려주세요';
      else if (!right) hint = '고개를 오른쪽으로 돌려주세요';
      else hint = '확인되었습니다. 촬영합니다';

      _updateUi(hint: hint, left: left, right: right);

      final ok = bigEnough && inCenter && left && right;
      if (ok) await _capture();
    } finally {
      _busy = false;
    }
  }

  void _updateUi({
    required String hint,
    required bool left,
    required bool right,
  }) {
    if (!mounted) return;
    final changed =
        (hint != _hint) || (left != _turnedLeft) || (right != _turnedRight);
    if (!changed) return;

    setState(() {
      _hint = hint;
      _turnedLeft = left;
      _turnedRight = right;
    });
  }

  void _updateDebug({
    required bool noFace,
    Face? face,
    Size? imageSize,
    InputImageRotation? rotation,
    double? yawRaw,
    double? yawUsed,
  }) {
    final now = DateTime.now();
    if (now.difference(_lastDebugUpdate).inMilliseconds < 120) return;
    _lastDebugUpdate = now;

    if (!mounted) return;

    if (noFace) {
      setState(() {
        _debugText = 'NO FACE';
        _lastFace = null;
        _lastImageSize = null;
        _lastRotation = null;
      });
      return;
    }

    if (face == null || imageSize == null || rotation == null) return;

    final r = face.boundingBox;
    final cx = r.center.dx;
    final cy = r.center.dy;
    final nx = cx / imageSize.width;
    final ny = cy / imageSize.height;

    final yawRawS = (yawRaw ?? 0).toStringAsFixed(1);
    final yawUsedS = (yawUsed ?? 0).toStringAsFixed(1);
    final pitch = (face.headEulerAngleX ?? 0).toStringAsFixed(1);
    final roll = (face.headEulerAngleZ ?? 0).toStringAsFixed(1);

    setState(() {
      _lastFace = face;
      _lastImageSize = imageSize;
      _lastRotation = rotation;

      _debugText =
      'RECT: x=${r.left.toStringAsFixed(1)}, y=${r.top.toStringAsFixed(1)}, '
          'w=${r.width.toStringAsFixed(1)}, h=${r.height.toStringAsFixed(1)}\n'
          'CENTER(px): cx=${cx.toStringAsFixed(1)}, cy=${cy.toStringAsFixed(1)}\n'
          'CENTER(norm): nx=${nx.toStringAsFixed(3)}, ny=${ny.toStringAsFixed(3)}\n'
          'POSE: yaw(raw)=$yawRawS, yaw(used)=$yawUsedS, pitch=$pitch, roll=$roll\n'
          'HIT: L=$_leftHit/$_hitNeed R=$_rightHit/$_hitNeed  CAM: front=$_isFrontCamera\n'
          'IMG: ${imageSize.width.toStringAsFixed(0)}x${imageSize.height.toStringAsFixed(0)} rot=$rotation';
    });
  }

  /// ✅ deviceOrientation + sensorOrientation 보정 포함 (ML Kit rotation 안정화)
  InputImage _toInputImage(CameraImage image, CameraDescription desc) {
    final bytes = _concatPlanes(image.planes);

    final orientation = _controller?.value.deviceOrientation;
    int rotationDegrees = 0;

    switch (orientation) {
      case DeviceOrientation.portraitUp:
        rotationDegrees = 0;
        break;
      case DeviceOrientation.landscapeLeft:
        rotationDegrees = 90;
        break;
      case DeviceOrientation.portraitDown:
        rotationDegrees = 180;
        break;
      case DeviceOrientation.landscapeRight:
        rotationDegrees = 270;
        break;
      default:
        rotationDegrees = 0;
    }

    final sensorOrientation = desc.sensorOrientation;
    final compensation = (desc.lensDirection == CameraLensDirection.front)
        ? (sensorOrientation + rotationDegrees) % 360
        : (sensorOrientation - rotationDegrees + 360) % 360;

    final rotation =
        InputImageRotationValue.fromRawValue(compensation) ??
            InputImageRotation.rotation0deg;

    final format =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.yuv420;

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Uint8List _concatPlanes(List<Plane> planes) {
    final builder = BytesBuilder(copy: false);
    for (final p in planes) {
      builder.add(p.bytes);
    }
    return builder.takeBytes();
  }

  Future<void> _capture() async {
    if (_controller == null || _capturing) return;
    _capturing = true;

    try {
      await _controller!.stopImageStream();
      final file = await _controller!.takePicture();

      final dir = await getApplicationDocumentsDirectory();
      final saved = File(
        '${dir.path}/face_capture_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await File(file.path).copy(saved.path);

      if (!mounted) return;
      Navigator.pop(
        context,
        FaceAuthResult(
          path: saved.path,
          capturedAt: DateTime.now(),
          turnedLeft: _turnedLeft,
          turnedRight: _turnedRight,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hint = '촬영 실패. 다시 시도하세요';
        _turnedLeft = false;
        _turnedRight = false;
        _leftHit = 0;
        _rightHit = 0;
      });
      _capturing = false;

      await _controller?.startImageStream(_onFrame).catchError((_) {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.stopImageStream().catchError((_) {});
    _controller?.dispose();
    _detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initDone) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_initError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('안면인증')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_initError!),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _initDone = false;
                    _initError = null;
                  });
                  _init();
                },
                child: const Text('재시도'),
              ),
            ],
          ),
        ),
      );
    }

    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // ✅ portrait 찌그러짐 방지
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    final previewAspect =
    isPortrait ? (1 / c.value.aspectRatio) : c.value.aspectRatio;

    return Scaffold(
      appBar: AppBar(
        title: const Text('안면인증'),
        actions: [
          IconButton(
            tooltip: '취소',
            onPressed: () async {
              await _controller?.stopImageStream().catchError((_) {});
              if (!mounted) return;
              Navigator.pop(context, null);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 프리뷰 + 실제 얼굴 오버레이
          Center(
            child: AspectRatio(
              aspectRatio: previewAspect,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(c),
                  if (_lastFace != null &&
                      _lastImageSize != null &&
                      _lastRotation != null)
                    CustomPaint(
                      painter: FaceBoxLandmarkPainter(
                        face: _lastFace!,
                        imageSize: _lastImageSize!,
                        rotation: _lastRotation!,
                        isFrontCamera: _isFrontCamera,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 상단 디버그 패널
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _debugText,
                style:
                const TextStyle(color: Colors.white, fontSize: 12, height: 1.2),
              ),
            ),
          ),

          // 템플릿 오버레이 + 가이드 프레임 (감지 실패해도 항상 보임)
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: 260,
              height: 340,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomPaint(painter: TemplateFaceOverlayPainter()),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 2, color: Colors.white),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 상태표시
          Positioned(
            top: 110,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepChip(label: 'LEFT', done: _turnedLeft),
                const SizedBox(width: 8),
                _StepChip(label: 'RIGHT', done: _turnedRight),
              ],
            ),
          ),

          // 안내 문구
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _hint,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  final String label;
  final bool done;

  const _StepChip({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: done
            ? Colors.green.withOpacity(0.85)
            : Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
      ),
      child: Text(
        done ? '$label ✓' : label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 감지 실패해도 무조건 보여줄 "템플릿 얼굴 라인"(임의 좌표)
class TemplateFaceOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(0.85);

    final faceRect = Rect.fromLTWH(
      s.width * 0.12,
      s.height * 0.08,
      s.width * 0.76,
      s.height * 0.84,
    );
    canvas.drawOval(faceRect, p);

    void eye(double cx, double cy) {
      final r = Rect.fromCenter(
        center: Offset(cx, cy),
        width: s.width * 0.18,
        height: s.height * 0.06,
      );
      canvas.drawOval(r, p);
      canvas.drawCircle(Offset(cx, cy), s.width * 0.02, p);
    }

    eye(s.width * 0.35, s.height * 0.34);
    eye(s.width * 0.65, s.height * 0.34);

    final nose = Path()
      ..moveTo(s.width * 0.50, s.height * 0.40)
      ..lineTo(s.width * 0.46, s.height * 0.52)
      ..lineTo(s.width * 0.54, s.height * 0.52)
      ..close();
    canvas.drawPath(nose, p);

    final mouth = Path()
      ..moveTo(s.width * 0.38, s.height * 0.64)
      ..quadraticBezierTo(
        s.width * 0.50,
        s.height * 0.70,
        s.width * 0.62,
        s.height * 0.64,
      );
    canvas.drawPath(mouth, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 감지 성공 시, 실제 얼굴 박스/랜드마크/컨투어를 프리뷰 위에 그리는 Painter
class FaceBoxLandmarkPainter extends CustomPainter {
  final Face face;
  final Size imageSize;
  final InputImageRotation rotation;
  final bool isFrontCamera;

  FaceBoxLandmarkPainter({
    required this.face,
    required this.imageSize,
    required this.rotation,
    required this.isFrontCamera,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.lightGreenAccent.withOpacity(0.9);

    final r = face.boundingBox;
    final lt = _mapXY(r.left, r.top, size);
    final rb = _mapXY(r.right, r.bottom, size);
    final rect = Rect.fromPoints(lt, rb);
    canvas.drawRect(rect, paint);

    final cx = r.center.dx;
    final cy = r.center.dy;
    _drawText(
      canvas,
      size,
      rect.topLeft + const Offset(0, -20),
      'cx=${cx.toStringAsFixed(0)}, cy=${cy.toStringAsFixed(0)}',
    );

    void drawLandmark(FaceLandmarkType t, String label) {
      final lm = face.landmarks[t];
      if (lm == null) return;
      final p = _mapPoint(lm.position, size);
      canvas.drawCircle(p, 4, paint);
      _drawText(canvas, size, p + const Offset(6, -6), label);
    }

    drawLandmark(FaceLandmarkType.leftEye, 'L-EYE');
    drawLandmark(FaceLandmarkType.rightEye, 'R-EYE');
    drawLandmark(FaceLandmarkType.noseBase, 'NOSE');
    drawLandmark(FaceLandmarkType.leftMouth, 'L-M');
    drawLandmark(FaceLandmarkType.rightMouth, 'R-M');
    drawLandmark(FaceLandmarkType.bottomMouth, 'B-M');

    final contourTypes = <FaceContourType>[
      FaceContourType.face,
      FaceContourType.leftEye,
      FaceContourType.rightEye,
      FaceContourType.upperLipTop,
      FaceContourType.lowerLipBottom,
      FaceContourType.noseBridge,
    ];

    final contourPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withOpacity(0.85);

    for (final t in contourTypes) {
      final pts = face.contours[t]?.points;
      if (pts == null || pts.length < 2) continue;

      final path = Path();
      final first = _mapPointInt(pts.first, size);
      path.moveTo(first.dx, first.dy);

      for (int i = 1; i < pts.length; i++) {
        final p = _mapPointInt(pts[i], size);
        path.lineTo(p.dx, p.dy);
      }

      if (t == FaceContourType.face) path.close();
      canvas.drawPath(path, contourPaint);
    }
  }

  Offset _mapPoint(math.Point<int> p, Size canvasSize) {
    return _mapXY(p.x.toDouble(), p.y.toDouble(), canvasSize);
  }

  Offset _mapPointInt(math.Point<int> p, Size canvasSize) {
    return _mapXY(p.x.toDouble(), p.y.toDouble(), canvasSize);
  }

  Offset _mapXY(double px, double py, Size canvasSize) {
    double x, y;
    switch (rotation) {
      case InputImageRotation.rotation90deg:
        x = py;
        y = imageSize.width - px;
        break;
      case InputImageRotation.rotation270deg:
        x = imageSize.height - py;
        y = px;
        break;
      case InputImageRotation.rotation180deg:
        x = imageSize.width - px;
        y = imageSize.height - py;
        break;
      case InputImageRotation.rotation0deg:
      default:
        x = px;
        y = py;
        break;
    }

    final rotated = _rotatedImageSize();
    final sx = canvasSize.width / rotated.width;
    final sy = canvasSize.height / rotated.height;

    double cx = x * sx;
    final cy = y * sy;

    if (isFrontCamera) cx = canvasSize.width - cx;
    return Offset(cx, cy);
  }

  Size _rotatedImageSize() {
    if (rotation == InputImageRotation.rotation90deg ||
        rotation == InputImageRotation.rotation270deg) {
      return Size(imageSize.height, imageSize.width);
    }
    return imageSize;
  }

  void _drawText(Canvas canvas, Size s, Offset pos, String text) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: s.width);

    final bg = Paint()..color = const Color(0x88000000);
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(pos.dx, pos.dy, tp.width + 10, tp.height + 6),
      const Radius.circular(6),
    );
    canvas.drawRRect(r, bg);
    tp.paint(canvas, pos + const Offset(5, 3));
  }

  @override
  bool shouldRepaint(covariant FaceBoxLandmarkPainter oldDelegate) => true;
}
