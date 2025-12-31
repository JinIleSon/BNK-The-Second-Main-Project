import 'dart:io';
import 'package:flutter/material.dart';

import 'face_auth_result.dart';

class FaceAuthOutcomeScreen extends StatelessWidget {
  final bool success;
  final String? photoPath;
  final String message;
  final FaceAuthResult? result;

  const FaceAuthOutcomeScreen({
    super.key,
    required this.success,
    required this.message,
    this.photoPath,
    this.result,
  });

  @override
  Widget build(BuildContext context) {
    final title = success ? '인증완료' : '인증실패';

    return Scaffold(
      appBar: AppBar(
        title: const Text('안면인증 결과'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, null),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Icon(
              success ? Icons.verified : Icons.error,
              size: 84,
              color: success ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),

            if (photoPath != null && File(photoPath!).existsSync())
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(photoPath!),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const Spacer(),

            if (!success)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // 실패 시: FaceAuthScreen 다시 띄우기
                        Navigator.pushReplacementNamed(context, '/face_legacy-auth');
                      },
                      child: const Text('다시 시도'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, null),
                      child: const Text('닫기'),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, result),
                  child: const Text('확인'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
