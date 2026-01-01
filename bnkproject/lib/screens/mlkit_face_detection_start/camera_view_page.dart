import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class CameraView extends StatefulWidget {
  const CameraView({
    super.key,
    required this.customPaint,
    required this.onImage,
    this.onCameraFeedReady,
    this.onDetectorViewModeChanged,
    this.onCameraLensDirectionChanged,
    this.initialCameraLensDirection = CameraLensDirection.back,
  });

  final CustomPaint? customPaint;

  /// NOTE: return type 미지정(Function)이라 async 콜백도 들어올 수 있음
  final Function(InputImage inputImage) onImage;

  final VoidCallback? onCameraFeedReady;
  final VoidCallback? onDetectorViewModeChanged;
  final Function(CameraLensDirection direction)? onCameraLensDirectionChanged;
  final CameraLensDirection initialCameraLensDirection;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static List<CameraDescription> _cameras = [];

  CameraController? _controller;
  int _cameraIndex = -1;

  double _currentZoomLevel = 1.0;
  double _minAvailableZoom = 1.0;
  double _maxAvailableZoom = 1.0;

  bool _changingCameraLens = false;
  String? _error;

  // ✅ 프레임 처리 중복 방지 + dispose 이후 호출 방지
  bool _isProcessing = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }

      for (var i = 0; i < _cameras.length; i++) {
        if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
          _cameraIndex = i;
          break;
        }
      }

      if (_cameraIndex != -1) {
        await _startLiveFeed();
      } else {
        if (mounted) setState(() => _error = 'No camera found.');
      }
    } catch (e) {
      if (mounted) setState(() => _error = 'Camera init failed: $e');
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopLiveFeed(); // async지만 dispose에서 await 불가 → 내부 try/catch로 안전 종료
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _liveFeedBody();
  }

  Widget _liveFeedBody() {
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.white),
        ),
      );
    }
    if (_cameras.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller == null || _controller!.value.isInitialized == false) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Center(
            child: _changingCameraLens
                ? const Text('Changing camera lens', style: TextStyle(color: Colors.white))
                : Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller!),
                if (widget.customPaint != null) Positioned.fill(child: widget.customPaint!),
              ],
            ),
          ),
          _switchLiveCameraToggle(),
          _zoomControl(),
        ],
      ),
    );
  }

  Widget _switchLiveCameraToggle() => Positioned(
    bottom: 16,
    right: 16,
    child: SizedBox(
      height: 50.0,
      width: 50.0,
      child: FloatingActionButton(
        heroTag: Object(),
        onPressed: _switchLiveCamera,
        child: Icon(
          Platform.isIOS ? Icons.flip_camera_ios_outlined : Icons.flip_camera_android_outlined,
          size: 25,
        ),
      ),
    ),
  );

  Widget _zoomControl() => Positioned(
    bottom: 16,
    left: 0,
    right: 0,
    child: Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: 260,
        child: Row(
          children: [
            Expanded(
              child: Slider(
                value: _currentZoomLevel,
                min: _minAvailableZoom,
                max: _maxAvailableZoom,
                activeColor: Colors.white,
                inactiveColor: Colors.white30,
                onChanged: (value) async {
                  if (!mounted) return;
                  setState(() => _currentZoomLevel = value);
                  await _controller?.setZoomLevel(value);
                },
              ),
            ),
            Container(
              width: 56,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  '${_currentZoomLevel.toStringAsFixed(1)}x',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Future<void> _startLiveFeed() async {
    if (_isDisposed) return;

    final camera = _cameras[_cameraIndex];

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );

    try {
      await _controller!.initialize();

      _minAvailableZoom = await _controller!.getMinZoomLevel();
      _maxAvailableZoom = await _controller!.getMaxZoomLevel();
      _currentZoomLevel = _minAvailableZoom;

      await _controller!.startImageStream(_processCameraImage);

      widget.onCameraFeedReady?.call();
      widget.onCameraLensDirectionChanged?.call(camera.lensDirection);

      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _error = 'Camera start failed: $e');
    }
  }

  Future<void> _stopLiveFeed() async {
    try {
      await _controller?.stopImageStream();
    } catch (_) {}
    try {
      await _controller?.dispose();
    } catch (_) {}
    _controller = null;
  }

  Future<void> _switchLiveCamera() async {
    if (_cameras.length < 2) return;
    if (!mounted) return;
    if (_changingCameraLens) return;

    setState(() => _changingCameraLens = true);

    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    await _stopLiveFeed();
    if (!mounted) return;

    await _startLiveFeed();
    if (!mounted) return;

    setState(() => _changingCameraLens = false);
  }

  final _orientations = const {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final ctrl = _controller;
    if (ctrl == null) return null;

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else {
      var rotationCompensation = _orientations[ctrl.value.deviceOrientation];
      if (rotationCompensation == null) return null;

      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // ✅ onImage가 async일 수도 있으니, 버퍼 재사용 이슈 방지 위해 복사
    final bytes = Uint8List.fromList(plane.bytes);

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  // startImageStream은 void 콜백만 받는다. (async 금지)
  void _processCameraImage(CameraImage image) {
    if (_isDisposed || _changingCameraLens) return;
    if (_isProcessing) return;

    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;

    _isProcessing = true;

    // ✅ sync/async 모두 안전 처리
    Future.sync(() => widget.onImage(inputImage))
        .catchError((e, st) {
      debugPrint('CameraView onImage crashed: $e');
      debugPrint('$st');
    })
        .whenComplete(() {
      _isProcessing = false;
    });
  }
}
