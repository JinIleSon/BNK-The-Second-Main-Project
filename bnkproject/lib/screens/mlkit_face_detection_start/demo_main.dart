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
      home: const FaceDetectorApp(),
    );
  }
}

/// ✅ 기존 앱(BoardMain)에서 push로 들어갈 "진입 페이지"
/// MaterialApp 없이 페이지(Scaffold)만 반환해야 함.
class MlkitDemoEntryPage extends StatelessWidget {
  const MlkitDemoEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('얼굴 인증')),
      body: FaceDetectorApp(
        // ✅ 인증 성공 시 이 콜백 호출되게 FaceDetectorApp 수정 필요(아래 3번)
        onVerified: () => Navigator.pop(context, true),
      ),
    );
  }
}
