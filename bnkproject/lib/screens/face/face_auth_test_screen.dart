import 'dart:io';

import 'package:flutter/material.dart';
import 'face_auth_screen.dart';

class FaceAuthTestScreen extends StatefulWidget {
  const FaceAuthTestScreen({super.key});

  @override
  State<FaceAuthTestScreen> createState() => _FaceAuthTestScreenState();
}

class _FaceAuthTestScreenState extends State<FaceAuthTestScreen> {
  FaceAuthResult? result;

  Future<void> _startFaceAuth() async {
    final r = await Navigator.push<FaceAuthResult?>(
      context,
      MaterialPageRoute(builder: (_) => const FaceAuthScreen()),
    );
    if (!mounted) return;

    setState(() {
      result = r; // 취소면 null
    });
  }

  Future<void> _deleteFile() async {
    final path = result?.path;
    if (path == null) return;

    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
    if (!mounted) return;
    setState(() => result = null);
  }

  @override
  Widget build(BuildContext context) {
    final path = result?.path;

    return Scaffold(
      appBar: AppBar(title: const Text('안면인증 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _startFaceAuth,
              child: Text(result == null ? '안면인증 시작' : '다시 촬영'),
            ),
            const SizedBox(height: 16),

            if (result == null) ...[
              const Text('결과 없음'),
            ] else ...[
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: Image.file(
                        File(path!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(child: Text('이미지 로드 실패')),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('촬영 성공', style: TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text('시간: ${result!.capturedAt}'),
                          const SizedBox(height: 6),
                          SelectableText('파일: ${result!.path}'),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: _deleteFile,
                                child: const Text('파일 삭제'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () => setState(() => result = null),
                                child: const Text('결과 지우기'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
