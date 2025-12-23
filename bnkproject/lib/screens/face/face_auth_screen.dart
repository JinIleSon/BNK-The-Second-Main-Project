import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'face_auth_result.dart';

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

  String _hint = '얼굴을 중앙에 맞추세요';
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
    final camPerm = await Permission.camera.request();
    if (!camPerm.isGranted) {
      if (mounted) Navigator.pop(context, null);
      return;
    }

    final cameras = await availableCameras();
    final front = cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    final ctrl = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await ctrl.initialize();
    _controller = ctrl;

    await _controller!.startImageStream(_onCameraImage);

    if (mounted) setState(() {});
  }

  Future<void> _onCameraImage(CameraImage image) async {
    if (_busy || _capturing) return;
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    _busy = true;
    try {
      final input = _toInputImage(image, ctrl);
      final faces = await _detector.processImage(input);

      if (faces.isEmpty) {
        _hint = '얼굴이 안 보입니다. 화면 중앙으로';
        if (mounted) setState(() {});
        return;
      }

      final face = faces.first;

      // =========================
      // ✅ LEFT/RIGHT 판정 개선
      // - 프론트 카메라: 좌우가 뒤집히는 경우가 많아 yaw 부호 반전
      // - 임계치 완화(12 -> 8)
      // =========================
      final rawYaw = face.headEulerAngleY ?? 0.0;
      final yaw = (ctrl.description.lensDirection == CameraLensDirection.front)
          ? -rawYaw
          : rawYaw;

      const t = 8.0;

      if (yaw < -t) _turnedLeft = true;
      if (yaw > t) _turnedRight = true;

      if (!_turnedLeft) {
        _hint = '고개를 왼쪽으로 돌려주세요 (yaw=${yaw.toStringAsFixed(1)})';
      } else if (!_turnedRight) {
        _hint = '고개를 오른쪽으로 돌려주세요 (yaw=${yaw.toStringAsFixed(1)})';
      } else {
        _hint = '확인 완료. 촬영합니다 (yaw=${yaw.toStringAsFixed(1)})';
        if (mounted) setState(() {});
        await _captureAndReturn();
        return;
      }

      if (mounted) setState(() {});
    } catch (_) {
      // MVP: 예외 무시 (실서비스면 로그 필요)
    } finally {
      _busy = false;
    }
  }

  InputImage _toInputImage(CameraImage image, CameraController controller) {
    final bytesBuilder = BytesBuilder(copy: false);
    for (final plane in image.planes) {
      bytesBuilder.add(plane.bytes);
    }
    final Uint8List bytes = bytesBuilder.toBytes();

    final rotation =
        InputImageRotationValue.fromRawValue(controller.description.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final format =
        InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.nv21;

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Future<void> _captureAndReturn() async {
    final ctrl = _controller;
    if (ctrl == null || _capturing) return;

    _capturing = true;

    try {
      await ctrl.stopImageStream();

      final xfile = await ctrl.takePicture();
      final dir = await getTemporaryDirectory();
      final savedPath = '${dir.path}/face_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(xfile.path).copy(savedPath);

      if (!mounted) return;

      Navigator.pop(
        context,
        FaceAuthResult(
          path: savedPath,
          capturedAt: DateTime.now(),
          turnedLeft: _turnedLeft,
          turnedRight: _turnedRight,
        ),
      );
    } catch (_) {
      if (mounted) Navigator.pop(context, null);
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
    final ctrl = _controller;

    return Scaffold(
      appBar: AppBar(
        title: const Text('안면인증'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, null),
        ),
      ),
      body: ctrl == null || !ctrl.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          CameraPreview(ctrl),

          // =========================
          // ✅ 중앙 오버레이 가이드(복구)
          // =========================
          Align(
            alignment: Alignment.center,
            child: IgnorePointer(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.72,
                height: MediaQuery.of(context).size.height * 0.45,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.85),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_hint, style: const TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _FlagChip(label: 'LEFT', ok: _turnedLeft),
                      const SizedBox(width: 8),
                      _FlagChip(label: 'RIGHT', ok: _turnedRight),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlagChip extends StatelessWidget {
  final String label;
  final bool ok;

  const _FlagChip({required this.label, required this.ok});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ok ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
