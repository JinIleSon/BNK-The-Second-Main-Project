import 'package:flutter/material.dart';
import 'face_auth_screen.dart';

class FaceAuthTestScreen extends StatefulWidget {
  const FaceAuthTestScreen({super.key});

  @override
  State<FaceAuthTestScreen> createState() => _FaceAuthTestScreenState();
}

class _FaceAuthTestScreenState extends State<FaceAuthTestScreen> {
  String? resultPath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('안면인증 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () async {
                final path = await Navigator.push<String>(
                  context,
                  MaterialPageRoute(builder: (_) => const FaceAuthScreen()),
                );
                if (!mounted) return;
                setState(() => resultPath = path);
              },
              child: const Text('안면인증 시작'),
            ),
            const SizedBox(height: 16),
            Text(resultPath == null ? '결과 없음' : '촬영 파일: $resultPath'),
          ],
        ),
      ),
    );
  }
}
