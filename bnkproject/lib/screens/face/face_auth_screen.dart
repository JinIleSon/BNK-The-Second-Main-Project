import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
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

class _FaceAuthScreenState extends State<FaceAuthScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  late final FaceDetector _detector;

  bool _busy = false;
  bool _capturing = false;

  bool _initDone = false;
  String? _initError;

  String _hint = '얼굴을 중앙 프레임에 맞춰주세요';
  bool _turnedLeft = false;
  bool _turnedRight = false;

  // 튜닝 포인트
  static const double _minFaceAreaRatio = 0.12; // 화면 대비 얼굴 최소 비율
  static const double _centerXMin = 0.25;
  static const double _centerXMax = 0.75;
  static const double _centerYMin = 0.20;
  static const double _centerYMax = 0.80;
  static const double _yawLeft = -15;
  static const double _yawRight = 15;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableTracking: true,
        enableContours: true,
        enableLandmarks: true, // 선택
      ),
    );

    _init();
  }

  Future<void> _init() async {
    try {
      final cam = await Permission.camera.request();
      if (!cam.isGranted) {
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

      final controller = CameraController(
        front,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await controller.initialize();
      await controller.startImageStream(_onFrame);

      if (!mounted) return;
      setState(() {
        _controller = controller;
        _initDone = true;
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
      c.stopImageStream().catchError((_) {});
    } else if (state == AppLifecycleState.resumed) {
      if (!_capturing) {
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
        _updateUi(
          hint: '얼굴이 인식되지 않습니다',
          left: false,
          right: false,
        );
        return;
      }

      // 가장 큰 얼굴 1개만 사용
      faces.sort((a, b) =>
          (b.boundingBox.width * b.boundingBox.height).compareTo(a.boundingBox.width * a.boundingBox.height));
      final face = faces.first;

      final meta = input.metadata!;
      final w = meta.size.width;
      final h = meta.size.height;

      // 1) 얼굴 크기
      final area = face.boundingBox.width * face.boundingBox.height;
      final bigEnough = area >= (w * h) * _minFaceAreaRatio;

      // 2) 중앙 여부
      final cx = face.boundingBox.center.dx;
      final cy = face.boundingBox.center.dy;
      final inCenter =
          (cx > w * _centerXMin && cx < w * _centerXMax) &&
              (cy > h * _centerYMin && cy < h * _centerYMax);

      // 3) 라이브니스 (고개 좌/우)
      final yaw = face.headEulerAngleY ?? 0.0;
      final left = _turnedLeft || (yaw <= _yawLeft);
      final right = _turnedRight || (yaw >= _yawRight);

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

  void _updateUi({required String hint, required bool left, required bool right}) {
    if (!mounted) return;

    // 프레임마다 setState 난사 방지: 바뀐 값만 반영
    final changed = (hint != _hint) || (left != _turnedLeft) || (right != _turnedRight);
    if (!changed) return;

    setState(() {
      _hint = hint;
      _turnedLeft = left;
      _turnedRight = right;
    });
  }

  InputImage _toInputImage(CameraImage image, CameraDescription desc) {
    final bytes = _concatPlanes(image.planes);

    final rotation = InputImageRotationValue.fromRawValue(desc.sensorOrientation) ??
        InputImageRotation.rotation0deg;

    final format = InputImageFormatValue.fromRawValue(image.format.raw) ??
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
      final saved = File('${dir.path}/face_capture_${DateTime.now().millisecondsSinceEpoch}.jpg');
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
      });
      _capturing = false;

      // 스트림 재개
      await _controller?.startImageStream(_onFrame);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initDone) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_initError != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('안면인증')),
        body: Center(child: Text(_initError!)),
      );
    }

    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('안면인증'),
        actions: [
          IconButton(
            tooltip: '취소',
            onPressed: () => Navigator.pop(context, null),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(c),

          // 프레임
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 260,
              height: 340,
              decoration: BoxDecoration(
                border: Border.all(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // 상태표시 (좌/우 완료)
          Positioned(
            top: 16,
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
                style: const TextStyle(color: Colors.white),
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
        color: done ? Colors.green.withOpacity(0.8) : Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.8)),
      ),
      child: Text(
        done ? '$label ✓' : label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}
