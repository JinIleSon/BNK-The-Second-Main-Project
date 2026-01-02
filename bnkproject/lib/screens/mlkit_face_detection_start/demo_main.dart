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
      // ✅ 단독 실행: Entry가 아니라서 자동 pop/성공 판정 없음
      home: const FaceDetectorApp(),
    );
  }
}

/// ✅ 기존 앱(회원가입/인증 플로우)에서 push로 들어갈 "진입 페이지"
/// ✅ 중복 AppBar 방지: 여기서는 Scaffold/AppBar 만들지 않는다.
/// ✅ FaceDetectorApp의 AppBar(=ML Kit 테스트)만 사용한다.
///
/// Entry(회원가입)에서 필요한 계약:
/// - 성공: Navigator.pop(context, true)
/// - 즉시 실패(백그라운드 전환 등): Navigator.pop(context, Map{ok:false, code, reason})
///
/// ⚠️ personal_auth_page.dart 쪽에서는
/// - bool true 만 성공 저장
/// - Map(ok:false)이면 실패로 처리(성공 저장 금지)
class MlkitDemoEntryPage extends StatelessWidget {
  const MlkitDemoEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FaceDetectorApp(
      /// ✅ 성공 시: 단순 bool(true) 반환
      onVerified: () => Navigator.pop(context, true),

      /// ✅ 실패 시: 구조화된 Map 반환 (ok=false)
      /// - FaceDetectorApp에서 백그라운드 전환 등 "즉시 실패" 상황에 호출됨
      onFailed: (res) => Navigator.pop(context, res),
    );
  }
}
