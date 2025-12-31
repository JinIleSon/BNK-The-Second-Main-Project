// lib/mlkit_face_detection_start/demo_main.dart
import 'package:flutter/material.dart';

import 'face_detector_app.dart';

/// 단독 실행용 (원하면 flutter run -t 로 실행)
void main() => runApp(const MlkitDemoApp());

class MlkitDemoApp extends StatelessWidget {
  const MlkitDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ML Kit Demo',
      theme: ThemeData(useMaterial3: true),
      home: const FaceDetectorApp(), // 단독 실행: 자동 pop 없음
    );
  }
}

/// ✅ 기존 앱(BoardMain)에서 push로 들어갈 "진입 페이지"
/// ✅ 중복 AppBar 방지: 여기서는 Scaffold/AppBar 만들지 않는다.
/// FaceDetectorApp의 AppBar(=ML Kit 테스트)만 사용한다.
class MlkitDemoEntryPage extends StatelessWidget {
  const MlkitDemoEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FaceDetectorApp(
      onVerified: () => Navigator.pop(context, true),
    );
  }
}
