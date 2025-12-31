import 'dart:io';

import 'package:flutter/material.dart';
import 'face_auth_screen.dart';
import 'face_auth_result.dart';

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

    setState(() => result = r);

    if (r != null) {
      await _showResultDialog(r);
    }
  }

  Future<void> _showResultDialog(FaceAuthResult r) async {
    final ok = r.demoPass;
    final bg = ok ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          ok ? '인증 성공' : '인증 실패',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ok ? '데모 기준을 통과했습니다.' : '데모 기준을 통과하지 못했습니다.',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _MiniChip(label: 'LEFT', done: r.turnedLeft),
                const SizedBox(width: 8),
                _MiniChip(label: 'RIGHT', done: r.turnedRight),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '촬영: ${r.capturedAt}',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '확인',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFile() async {
    final path = result?.path;
    if (path == null || path.isEmpty) return;

    final f = File(path);
    if (await f.exists()) {
      await f.delete();
    }
    if (!mounted) return;
    setState(() => result = null);
  }

  @override
  Widget build(BuildContext context) {
    final r = result;
    final path = r?.path;

    return Scaffold(
      appBar: AppBar(title: const Text('안면인증 테스트')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _startFaceAuth,
              child: Text(r == null ? '안면인증 시작' : '다시 촬영'),
            ),
            const SizedBox(height: 16),

            // =========================
            // ✅ 결과 없음: 유도 이미지 표시
            // =========================
            if (r == null) ...[
              const SizedBox(height: 8),
              const Text('안내'),
              const SizedBox(height: 12),

              Center(
                child: Image.asset(
                  'assets/images/face_guide.png',
                  width: 260,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 12),
              const Text(
                '얼굴을 중앙에 맞추고\n왼쪽/오른쪽으로 고개를 돌려주세요.',
                textAlign: TextAlign.center,
              ),
            ] else ...[
              // =========================
              // ✅ 결과 있음: 촬영 이미지/결과 표시
              // =========================
              Card(
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: (path != null && path.isNotEmpty)
                          ? Image.file(
                        File(path),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                        const Center(child: Text('이미지 로드 실패')),
                      )
                          : const Center(child: Text('촬영 파일 없음')),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.demoPass ? 'PASS (데모)' : 'FAIL (데모)',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: r.demoPass ? Colors.green : Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _MiniChip(label: 'LEFT', done: r.turnedLeft),
                              const SizedBox(width: 8),
                              _MiniChip(label: 'RIGHT', done: r.turnedRight),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('시간: ${r.capturedAt}'),
                          const SizedBox(height: 6),
                          SelectableText('파일: ${r.path}'),
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

class _MiniChip extends StatelessWidget {
  final String label;
  final bool done;

  const _MiniChip({required this.label, required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: done ? Colors.green.withOpacity(0.85) : Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
      ),
      child: Text(
        done ? '$label ✓' : label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}
