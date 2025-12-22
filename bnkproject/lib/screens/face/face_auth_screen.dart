import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';


class FaceAuthScreen extends StatefulWidget {
  const FaceAuthScreen({super.key});

  @override
  State<FaceAuthScreen> createState() => _FaceAuthScreenState();
}

class _FaceAuthScreenState extends State<FaceAuthScreen> {
  CameraController? _controller;
  late final FaceDetector _detector;

  bool _busy = false;
  bool _capturing = false;

  String _hint = '얼굴을 중앙 프레임에 맞춰주세요';
  bool _turnedLeft = false;
  bool _turnedRight = false;

  @override
  void initState() {
    super.initState();
    _detector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
        enableTracking: true,
      ),
    );
    _init();
  }

  Future<void> _init() async {
    final cam = await Permission.camera.request();
    if (!cam.isGranted) {
      setState(() => _hint = '카메라 권한이 필요합니다');
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

    setState(() => _controller = controller);
  }

  Future<void> _onFrame(CameraImage image) async {
    if (_busy || _capturing || _controller == null) return;
    _busy = true;

    try {
      final input = _toInputImage(image, _controller!.description.sensorOrientation);
      final faces = await _detector.processImage(input);

      if (faces.isEmpty) {
        setState(() {
          _hint = '얼굴이 인식되지 않습니다';
          _turnedLeft = false;
          _turnedRight = false;
        });
        return;
      }

      // 가장 큰 얼굴 1개만 사용
      faces.sort((a, b) =>
          (b.boundingBox.width * b.boundingBox.height).compareTo(a.boundingBox.width * a.boundingBox.height));
      final face = faces.first;

      final w = input.metadata!.size.width;
      final h = input.metadata!.size.height;

      // 1) 얼굴 크기(너무 멀면 실패)
      final area = face.boundingBox.width * face.boundingBox.height;
      final bigEnough = area >= (w * h) * 0.12;

      // 2) 대략 중앙(너무 벗어나면 실패)
      final cx = face.boundingBox.center.dx;
      final cy = face.boundingBox.center.dy;
      final inCenter =
          (cx > w * 0.25 && cx < w * 0.75) &&
              (cy > h * 0.20 && cy < h * 0.80);

      // 3) 라이브니스(고개 좌/우) - Euler Y
      final yaw = face.headEulerAngleY ?? 0.0;
      if (yaw <= -15) _turnedLeft = true;
      if (yaw >= 15) _turnedRight = true;

      String hint = '얼굴을 중앙 프레임에 맞춰주세요';
      if (!bigEnough) hint = '조금 더 가까이 와주세요';
      else if (!inCenter) hint = '얼굴을 중앙에 맞춰주세요';
      else if (!_turnedLeft) hint = '고개를 왼쪽으로 돌려주세요';
      else if (!_turnedRight) hint = '고개를 오른쪽으로 돌려주세요';
      else hint = '확인되었습니다. 촬영합니다';

      setState(() => _hint = hint);

      final ok = bigEnough && inCenter && _turnedLeft && _turnedRight;
      if (ok) await _capture();
    } finally {
      _busy = false;
    }
  }

  InputImage _toInputImage(CameraImage image, int rotation) {
    final bytes = _concatPlanes(image.planes);

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: _rotation(rotation),
      format: InputImageFormat.yuv420,
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


  InputImageRotation _rotation(int r) {
    switch (r) {
      case 90: return InputImageRotation.rotation90deg;
      case 180: return InputImageRotation.rotation180deg;
      case 270: return InputImageRotation.rotation270deg;
      default: return InputImageRotation.rotation0deg;
    }
  }

  Future<void> _capture() async {
    if (_controller == null || _capturing) return;
    _capturing = true;

    try {
      await _controller!.stopImageStream();
      final file = await _controller!.takePicture();

      final dir = await getApplicationDocumentsDirectory();
      final saved = File('${dir.path}/face_capture.jpg');
      await File(file.path).copy(saved.path);

      if (!mounted) return;
      Navigator.pop(context, saved.path);
    } catch (_) {
      setState(() {
        _hint = '촬영 실패. 다시 시도하세요';
        _turnedLeft = false;
        _turnedRight = false;
      });
      _capturing = false;
      await _controller?.startImageStream(_onFrame);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _detector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('안면인증')),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(c),
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