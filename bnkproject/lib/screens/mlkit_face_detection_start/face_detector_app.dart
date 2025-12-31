// lib/mlkit_face_detection_start/face_detector_app.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

import 'camera_view_page.dart';
import 'face_detector_painter.dart' show FaceDetectorPainter;
import 'face_mesh_detector_painter.dart' show FaceMeshDetectorPainter;
import 'segmentation_painter.dart' show SegmentationPainter;

enum _DetectorMode { face, mesh, segmentation }

class FaceDetectorApp extends StatefulWidget {
  const FaceDetectorApp({
    super.key,
    this.onVerified,
  });

  /// ✅ 외부(회원가입 플로우)에서 push로 들어왔을 때,
  /// 얼굴이 감지되면 1회 호출되도록 하는 콜백.
  /// (Navigator.pop은 바깥 EntryPage에서 처리)
  final VoidCallback? onVerified;

  @override
  State<FaceDetectorApp> createState() => _FaceDetectorAppState();
}

class _FaceDetectorAppState extends State<FaceDetectorApp> {
  late final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableLandmarks: true,
      enableContours: true,
      enableClassification: true,
      enableTracking: true,
      minFaceSize: 0.1,
    ),
  );

  late final FaceMeshDetector _faceMeshDetector = FaceMeshDetector(
    option: FaceMeshDetectorOptions.faceMesh,
  );

  late final SelfieSegmenter _segmenter = SelfieSegmenter(
    mode: SegmenterMode.stream,
  );

  _DetectorMode _mode = _DetectorMode.mesh;

  CustomPaint? _customPaint;
  String _info = '';
  bool _isBusy = false;

  Size _imageSize = Size.zero;
  InputImageRotation _rotation = InputImageRotation.rotation0deg;
  CameraLensDirection _lensDirection = CameraLensDirection.front;

  // ✅ 인증 콜백 1회성 + 안정화(연속 감지 프레임)
  bool _reportedVerified = false;
  int _verifyStreak = 0;
  static const int _verifyStreakTarget = 3;

  @override
  void dispose() {
    _faceDetector.close();
    _faceMeshDetector.close();
    _segmenter.close();
    super.dispose();
  }

  void _reset() {
    setState(() {
      _customPaint = null;
      _info = '';
      _isBusy = false;

      _reportedVerified = false;
      _verifyStreak = 0;
    });
  }

  void _notifyVerifiedOnce() {
    if (_reportedVerified) return;
    _reportedVerified = true;

    // ✅ 프레임 처리 중 pop이 발생해도 setState/stream 충돌 최소화
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onVerified?.call();
    });
  }

  void _handleAutoVerify({required bool detected}) {
    if (widget.onVerified == null) return; // 단독 실행에서는 자동 종료 안 함
    if (_reportedVerified) return;

    if (detected) {
      _verifyStreak++;
      if (_verifyStreak >= _verifyStreakTarget) {
        _info = 'Verified';
        _notifyVerifiedOnce();
      }
    } else {
      _verifyStreak = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Kit 테스트'),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<_DetectorMode>(
              value: _mode,
              items: const [
                DropdownMenuItem(value: _DetectorMode.face, child: Text('Face')),
                DropdownMenuItem(value: _DetectorMode.mesh, child: Text('Mesh')),
                DropdownMenuItem(value: _DetectorMode.segmentation, child: Text('Seg')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  _mode = v;
                  _customPaint = null;
                  _info = '';

                  // 모드 바꾸면 인증 streak 리셋
                  _reportedVerified = false;
                  _verifyStreak = 0;
                });
              },
            ),
          ),
          IconButton(
            onPressed: _reset,
            icon: const Icon(Icons.refresh),
            tooltip: 'reset',
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraView(
            customPaint: _customPaint,
            onImage: _processImage,
            onCameraLensDirectionChanged: (dir) => _lensDirection = dir,
            initialCameraLensDirection: CameraLensDirection.front,
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    _info.isEmpty ? '카메라 프레임 분석 중...' : _info,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      if (!mounted) return;

      final meta = inputImage.metadata;
      if (meta?.size != null) _imageSize = meta!.size;
      if (meta?.rotation != null) _rotation = meta!.rotation;

      switch (_mode) {
        case _DetectorMode.face:
          final faces = await _faceDetector.processImage(inputImage);
          _customPaint = CustomPaint(
            painter: FaceDetectorPainter(
              faces,
              _imageSize,
              _rotation,
              _lensDirection,
            ),
          );
          _info = 'Face: ${faces.length}';

          // ✅ 얼굴 1개 이상 감지 시(연속 프레임) 인증 처리
          _handleAutoVerify(detected: faces.isNotEmpty);
          break;

        case _DetectorMode.mesh:
          final meshes = await _faceMeshDetector.processImage(inputImage);
          _customPaint = CustomPaint(
            painter: FaceMeshDetectorPainter(
              meshes,
              _imageSize,
              _rotation,
              _lensDirection,
            ),
          );
          _info = 'Mesh: ${meshes.length}';

          // ✅ Mesh 1개 이상 감지 시(연속 프레임) 인증 처리
          _handleAutoVerify(detected: meshes.isNotEmpty);
          break;

        case _DetectorMode.segmentation:
          final mask = await _segmenter.processImage(inputImage); // SegmentationMask?
          if (mask == null) {
            _customPaint = null;
            _info = 'Segmentation: mask is null';
            _handleAutoVerify(detected: false);
            break;
          }
          _customPaint = CustomPaint(
            painter: SegmentationPainter(
              mask,
              _imageSize,
              _rotation,
              _lensDirection,
            ),
          );
          _info = 'Segmentation: ${mask.width}x${mask.height}';

          // segmentation은 얼굴 인증으로 쓰지 않음
          _handleAutoVerify(detected: false);
          break;
      }

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() {
          _customPaint = null;
          _info = 'ERROR: $e';
        });
      }
    } finally {
      _isBusy = false;
    }
  }
}
