import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/*
    날짜 : 2025.12.30
    이름 : 이준우
    내용 : 백엔드 DB 연동으로 인한 write page 생성
 */

class BoarderWritePage extends StatefulWidget {
  const BoarderWritePage({super.key});

  @override
  State<BoarderWritePage> createState() => _BoarderWritePageState();
}

class _BoarderWritePageState extends State<BoarderWritePage> {
  final _titleCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  static const String baseUrl = "http://10.0.2.2:8080/BNK";

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (body.isEmpty) {
      setState(() => _error = "내용(body)은 필수입니다.");
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse("$baseUrl/api/post/board");

      final res = await http.post(
        uri,
        headers: {
          "Content-Type": "application/json",
          "X-UID": "1", // ✅ 로그인 아직이면 임시
        },
        body: jsonEncode({
          "title": title.isEmpty ? null : title,
          "body": body,
          "coverUrl": null,
        }),
      );

      if (res.statusCode != 200) {
        throw Exception("HTTP ${res.statusCode}: ${res.body}");
      }

      // 서버가 newId 숫자로 응답하면 OK
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("글쓰기"),
        actions: [
          TextButton(
            onPressed: _loading ? null : () => Navigator.pop(context, false),
            child: const Text("취소"),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 제목
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: "제목",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // 내용 (화면 남는 공간 대부분 차지)
            Expanded(
              child: TextField(
                controller: _bodyCtrl,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  labelText: "내용",
                  border: OutlineInputBorder(),
                ),
              ),
            ),

            // 에러 메시지
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 12),

            // ✅ 등록 버튼(내용칸 바로 아래)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text("등록"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
