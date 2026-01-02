// lib/mlkit_face_detection_start/face_detector_app.dart
//
// ✅ Entry(회원가입) 보안 강화 요구사항 반영
// 1) 미션 3개 고정: blink + turnLeft + turnRight (순서 고정)
// 2) 타임아웃: 15초 내 미션 완료 못하면 실패 처리하지 않고 "재시도"로 리셋
// 3) 개인정보/보안 UX
//    - Android: FLAG_SECURE로 스크린샷/화면녹화 차단(플러그인 사용)
//    - 앱이 백그라운드( paused/inactive )로 가면 즉시 실패 처리(Entry이면 pop으로 반환)
//
// ⚠️ 중요한 전제
// - Entry(onVerified != null)에서는 "감지됨 = 성공" 같은 자동 승인을 절대 하지 않는다.
// - 얼굴 1명 + 얼굴 전체 + 충분한 크기 + 연속 프레임 + 미션 완료 => 성공
//
// ⚠️ 분류값(eyeOpen/smile)은 흔들린다. 하지만 "사진만 들이대도 성공"을 크게 줄인다.
// - blink는 left/right eye open probability가 null이면 진행 불가. (정면/조도 요구)

import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';

import 'camera_view_page.dart';
import 'face_detector_painter.dart' show FaceDetectorPainter;
import 'face_mesh_detector_painter.dart' show FaceMeshDetectorPainter;
import 'segmentation_painter.dart' show SegmentationPainter;

enum _DetectorMode { face, mesh, segmentation }

/// Entry 고정 미션 3개
enum _Mission { blink, turnLeft, turnRight }

class FaceDetectorApp extends StatefulWidget {
  const FaceDetectorApp({
    super.key,
    this.onVerified,
    this.onFailed,
  });

  /// ✅ Entry(회원가입 플로우)에서만 non-null
  /// - 성공 시 1회 호출
  final VoidCallback? onVerified;

  /// ✅ Entry(회원가입 플로우)에서만 사용 권장
  /// - 백그라운드 이동 등 "즉시 실패" 상황에서 호출
  /// - 예: Navigator.pop(context, {'ok': false, 'reason': '...', 'code': 'APP_BACKGROUND'});
  final void Function(Map<String, dynamic> result)? onFailed;

  @override
  State<FaceDetectorApp> createState() => _FaceDetectorAppState();
}

class _FaceDetectorAppState extends State<FaceDetectorApp>
    with WidgetsBindingObserver {
  // ===========================================================================
  // 1) ML Kit Detectors
  // ===========================================================================
  late final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      enableLandmarks: true,
      enableContours: true,
      enableClassification: true, // ✅ blink(eye prob) 사용 필수
      enableTracking: true,
      minFaceSize: 0.1,
    ),
  );

  // Mesh/Seg는 데모용. Entry 성공 판정에는 절대 사용하지 않는다.
  late final FaceMeshDetector _faceMeshDetector = FaceMeshDetector(
    option: FaceMeshDetectorOptions.faceMesh,
  );

  late final SelfieSegmenter _segmenter = SelfieSegmenter(
    mode: SegmenterMode.stream,
  );

  // ===========================================================================
  // 2) UI/Runtime State
  // ===========================================================================
  _DetectorMode _mode = _DetectorMode.mesh; // 데모 기본은 mesh
  CustomPaint? _customPaint;
  String _info = '';
  bool _isBusy = false;

  Size _imageSize = Size.zero;
  InputImageRotation _rotation = InputImageRotation.rotation0deg;
  CameraLensDirection _lensDirection = CameraLensDirection.front;

  // ===========================================================================
  // 3) Entry Gate State
  // ===========================================================================
  bool get _isEntryFlow => widget.onVerified != null;

  // 성공/실패 콜백이 중복 호출되지 않게 단일 종료 플래그
  bool _done = false;

  // (A) 얼굴 전체 입력 품질(streak)
  int _fullFaceStreak = 0;

  // (B) 미션 진행
  final List<_Mission> _missions = const [
    _Mission.blink,
    _Mission.turnLeft,
    _Mission.turnRight,
  ];
  int _missionIndex = 0;

  // (C) yaw hold (좌/우 회전 유지 프레임)
  int _yawHold = 0;

  // (D) blink 상태 머신
  // phase 0: 열림 대기 -> phase 1: 닫힘 유지 -> phase 2: 열림 복귀(성공)
  int _blinkPhase = 0;
  int _blinkClosedHold = 0;
  int _blinkOpenHold = 0;

  // (E) 타임아웃(미션 구간에서만 15초)
  Timer? _timeoutTimer;
  DateTime? _timeoutDeadline;

  // ===========================================================================
  // 4) Tuning Constants
  // ===========================================================================
  static const int _kFullFaceStreakTarget = 8;

  static const int _kYawHoldTarget = 5;
  static const double _kYawThreshold = 15.0;

  static const double _kMarginRatio = 0.06;
  static const double _kMinAreaRatio = 0.12;

  // blink thresholds (hysteresis)
  static const double _kEyeClosedTh = 0.20;
  static const double _kEyeOpenTh = 0.60;

  static const int _kBlinkClosedHoldTarget = 2;
  static const int _kBlinkOpenHoldTarget = 2;

  static const Duration _kMissionTimeout = Duration(seconds: 15);

  // ===========================================================================
  // 5) Lifecycle
  // ===========================================================================
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Entry면 보안 UX 적용(캡처 방지)
    if (_isEntryFlow) {
      _applySecureScreen(true);
      _info = '얼굴 전체가 프레임 안에 들어오게 맞추세요.';
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _cancelTimeout();
    if (_isEntryFlow) {
      _applySecureScreen(false);
    }

    _faceDetector.close();
    _faceMeshDetector.close();
    _segmenter.close();
    super.dispose();
  }

  /// 앱이 백그라운드로 가면 Entry는 즉시 실패 처리
  /// - "중간 상태를 이어서 성공시키는" 우회 경로를 닫는다.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isEntryFlow || _done) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _failAndExit(
        code: 'APP_BACKGROUND',
        reason: '앱이 백그라운드로 전환되어 인증이 중단되었습니다.',
      );
    }
  }

  // ===========================================================================
  // 6) Security UX: Screenshot/Recording Block (Android)
  // ===========================================================================
  Future<void> _applySecureScreen(bool enable) async {
    // iOS는 별도 네이티브/플러그인 필요(여기서는 Android만 확실히 막는다)
    if (!Platform.isAndroid) return;
    try {
      if (enable) {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
      } else {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
      }
    } catch (_) {
      // 플러그인/플랫폼 이슈로 실패해도 앱은 계속 동작해야 한다.
    }
  }

  // ===========================================================================
  // 7) Reset / Finish
  // ===========================================================================
  void _resetAll({String? info}) {
    _customPaint = null;
    _info = info ?? '';
    _isBusy = false;

    _done = false;

    _fullFaceStreak = 0;
    _missionIndex = 0;
    _yawHold = 0;

    _blinkPhase = 0;
    _blinkClosedHold = 0;
    _blinkOpenHold = 0;

    _cancelTimeout();
  }

  void _resetForRetry({required String reason}) {
    // 타임아웃은 "실패 pop"이 아니라 "재시도" 요구사항
    setState(() {
      _fullFaceStreak = 0;
      _missionIndex = 0;
      _yawHold = 0;

      _blinkPhase = 0;
      _blinkClosedHold = 0;
      _blinkOpenHold = 0;

      _cancelTimeout();
      _info = reason;
    });
  }

  void _success() {
    if (_done) return;
    _done = true;

    _cancelTimeout();

    // 프레임 처리 중 pop 충돌 방지
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onVerified?.call();
    });
  }

  void _failAndExit({required String code, required String reason}) {
    if (_done) return;
    _done = true;

    _cancelTimeout();

    final payload = <String, dynamic>{
      'ok': false,
      'code': code,
      'reason': reason,
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 콜백이 있으면 콜백 우선
      if (widget.onFailed != null) {
        widget.onFailed!(payload);
        return;
      }
      // fallback: Entry라면 직접 pop
      if (_isEntryFlow && mounted) {
        Navigator.pop(context, payload);
      }
    });
  }

  // ===========================================================================
  // 8) Timeout
  // ===========================================================================
  void _startTimeoutIfNeeded() {
    if (_timeoutTimer != null) return;
    _timeoutDeadline = DateTime.now().add(_kMissionTimeout);
    _timeoutTimer = Timer(_kMissionTimeout, () {
      if (!mounted || _done) return;
      _resetForRetry(reason: '시간 초과(15초). 다시 시도하세요.');
    });
  }

  void _cancelTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
    _timeoutDeadline = null;
  }

  int? _remainingSeconds() {
    final dl = _timeoutDeadline;
    if (dl == null) return null;
    final diff = dl.difference(DateTime.now()).inSeconds;
    return diff < 0 ? 0 : diff;
  }

  // ===========================================================================
  // 9) Face Quality Gate
  // ===========================================================================
  bool _isFaceFullyInFrame(Rect bb, Size img) {
    final mx = img.width * _kMarginRatio;
    final my = img.height * _kMarginRatio;
    return bb.left > mx &&
        bb.top > my &&
        bb.right < (img.width - mx) &&
        bb.bottom < (img.height - my);
  }

  bool _isFaceBigEnough(Rect bb, Size img) {
    final imgArea = img.width * img.height;
    if (imgArea <= 0) return false;

    final faceArea = bb.width * bb.height;
    return (faceArea / imgArea) >= _kMinAreaRatio;
  }

  // front camera mirror compensation: 사용자 기준 좌/우를 안정적으로 유지
  double _normYaw(double yaw) =>
      _lensDirection == CameraLensDirection.front ? -yaw : yaw;

  // ===========================================================================
  // 10) Missions (fixed 3)
  // ===========================================================================
  String _missionLabel(_Mission m) {
    switch (m) {
      case _Mission.blink:
        return '눈을 깜빡이세요';
      case _Mission.turnLeft:
        return '왼쪽으로 고개를 돌리세요';
      case _Mission.turnRight:
        return '오른쪽으로 고개를 돌리세요';
    }
  }

  bool _checkYaw(Face face, {required bool left}) {
    final yaw = _normYaw(face.headEulerAngleY ?? 0.0);
    final ok = left ? (yaw <= -_kYawThreshold) : (yaw >= _kYawThreshold);

    if (ok) {
      _yawHold++;
    } else {
      _yawHold = 0;
    }

    final remain = _remainingSeconds();
    final timeText = remain == null ? '' : ' / 남은 ${remain}s';
    _info =
    '미션 ${_missionIndex + 1}/${_missions.length}: ${left ? "좌회전" : "우회전"} (${_yawHold}/$_kYawHoldTarget)$timeText';

    return _yawHold >= _kYawHoldTarget;
  }

  bool _checkBlink(Face face) {
    final l = face.leftEyeOpenProbability;
    final r = face.rightEyeOpenProbability;

    // 분류값이 null이면 blink 미션을 평가할 수 없다.
    // - 정면/조도 개선을 유도하고 계속 대기
    if (l == null || r == null) {
      final remain = _remainingSeconds();
      final timeText = remain == null ? '' : ' / 남은 ${remain}s';
      _info =
      '미션 ${_missionIndex + 1}/${_missions.length}: 눈 인식 중... 정면을 봐주세요$timeText';
      return false;
    }

    final bothClosed = (l <= _kEyeClosedTh) && (r <= _kEyeClosedTh);
    final bothOpen = (l >= _kEyeOpenTh) && (r >= _kEyeOpenTh);

    // phase 0: 열림 상태에서 닫힘을 기다림
    if (_blinkPhase == 0) {
      final remain = _remainingSeconds();
      final timeText = remain == null ? '' : ' / 남은 ${remain}s';
      _info = '미션 ${_missionIndex + 1}/${_missions.length}: 눈을 깜빡이세요$timeText';
      if (bothClosed) {
        _blinkPhase = 1;
        _blinkClosedHold = 1;
      }
      return false;
    }

    // phase 1: 닫힘 유지 확인
    if (_blinkPhase == 1) {
      if (bothClosed) {
        _blinkClosedHold++;
      } else {
        _blinkClosedHold = 0;
      }

      final remain = _remainingSeconds();
      final timeText = remain == null ? '' : ' / 남은 ${remain}s';
      _info =
      '미션 ${_missionIndex + 1}/${_missions.length}: 눈 감기 (${_blinkClosedHold}/$_kBlinkClosedHoldTarget)$timeText';

      if (_blinkClosedHold >= _kBlinkClosedHoldTarget) {
        _blinkPhase = 2;
        _blinkOpenHold = 0;
      }
      return false;
    }

    // phase 2: 다시 열림 확인
    if (bothOpen) {
      _blinkOpenHold++;
    } else {
      _blinkOpenHold = 0;
    }

    final remain = _remainingSeconds();
    final timeText = remain == null ? '' : ' / 남은 ${remain}s';
    _info =
    '미션 ${_missionIndex + 1}/${_missions.length}: 눈 뜨기 (${_blinkOpenHold}/$_kBlinkOpenHoldTarget)$timeText';

    return _blinkOpenHold >= _kBlinkOpenHoldTarget;
  }

  void _advanceMission() {
    _missionIndex++;
    // 다음 미션을 위해 카운터 초기화
    _yawHold = 0;
    _blinkPhase = 0;
    _blinkClosedHold = 0;
    _blinkOpenHold = 0;
  }

  void _runMissions(Face face) {
    if (_missionIndex >= _missions.length) {
      _success();
      return;
    }

    final mission = _missions[_missionIndex];
    bool ok = false;

    switch (mission) {
      case _Mission.blink:
        ok = _checkBlink(face);
        break;
      case _Mission.turnLeft:
        ok = _checkYaw(face, left: true);
        break;
      case _Mission.turnRight:
        ok = _checkYaw(face, left: false);
        break;
    }

    if (ok) {
      _advanceMission();

      if (_missionIndex >= _missions.length) {
        _info = 'Verified';
        _success();
      } else {
        final next = _missions[_missionIndex];
        final remain = _remainingSeconds();
        final timeText = remain == null ? '' : ' / 남은 ${remain}s';
        _info =
        '미션 ${_missionIndex + 1}/${_missions.length}: ${_missionLabel(next)}$timeText';
      }
    }
  }

  // ===========================================================================
  // 11) Entry Gate Main Update
  // ===========================================================================
  void _updateEntryGate(List<Face> faces) {
    if (!_isEntryFlow || _done) return;
    if (_imageSize == Size.zero) return;

    // 얼굴 1명만 허용
    if (faces.length != 1) {
      _resetForRetry(reason: '얼굴 1명만 인식되게 맞추세요.');
      return;
    }

    final face = faces.first;
    final bb = face.boundingBox;

    // 얼굴 전체 + 충분한 크기(거리)
    final fullOk =
        _isFaceFullyInFrame(bb, _imageSize) && _isFaceBigEnough(bb, _imageSize);

    if (!fullOk) {
      _resetForRetry(reason: '얼굴 전체가 프레임 안에 들어오게 맞추세요.');
      return;
    }

    // 연속 프레임 안정화
    _fullFaceStreak++;
    if (_fullFaceStreak < _kFullFaceStreakTarget) {
      _cancelTimeout(); // 미션 구간 전에는 타이머 돌리면 UX가 망가진다.
      _info = '얼굴 고정 (${_fullFaceStreak}/$_kFullFaceStreakTarget)';
      return;
    }

    // ✅ 미션 타임아웃 시작(미션 구간에서만)
    _startTimeoutIfNeeded();

    // 미션 수행
    _runMissions(face);
  }

  // ===========================================================================
  // 12) UI
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ML Kit 테스트'),
        actions: [
          // Entry에서는 모드 변경 차단(우회 방지)
          if (!_isEntryFlow)
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
                    _resetAll();
                  });
                },
              ),
            ),
          IconButton(
            onPressed: () {
              setState(() {
                _resetAll(
                  info: _isEntryFlow
                      ? '얼굴 전체가 프레임 안에 들어오게 맞추세요.'
                      : '',
                );
              });
            },
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

  // ===========================================================================
  // 13) Frame processing loop
  // ===========================================================================
  Future<void> _processImage(InputImage inputImage) async {
    if (_isBusy) return;
    _isBusy = true;

    try {
      if (!mounted) return;

      final meta = inputImage.metadata;
      if (meta?.size != null) _imageSize = meta!.size;
      if (meta?.rotation != null) _rotation = meta!.rotation;

      // Entry에서는 무조건 FaceDetector로만 판정
      final effectiveMode = _isEntryFlow ? _DetectorMode.face : _mode;

      switch (effectiveMode) {
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

          if (_isEntryFlow) {
            _updateEntryGate(faces);
          } else {
            _info = 'Face: ${faces.length}';
          }
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
          break;

        case _DetectorMode.segmentation:
          final mask = await _segmenter.processImage(inputImage);
          if (mask == null) {
            _customPaint = null;
            _info = 'Segmentation: mask is null';
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
