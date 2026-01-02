import 'dart:convert';
import 'package:bnkproject/api/member_api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/feed_item.dart';

/*
    날짜 : 2025.12.31
    이름 : 이준우
    내용 : 게시글 수정
 */

class BoarderEditPage extends StatefulWidget {
  final FeedItem item;
  const BoarderEditPage({super.key, required this.item});

  @override
  State<BoarderEditPage> createState() => _BoarderEditPageState();
}

class _BoarderEditPageState extends State<BoarderEditPage> {
  static const baseUrl = "http://10.0.2.2:8080/BNK";

  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.item.title);
    _bodyCtrl = TextEditingController(text: widget.item.body);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final body = _bodyCtrl.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("제목/내용을 입력하세요.")),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final uri = Uri.parse("$baseUrl/api/post/board/${widget.item.postId}");

      final res = await http.put(
        uri,
        headers: {
          "Content-Type": "application/json; charset=utf-8",
          if (memberApi.sessionCookie != null) "Cookie": memberApi.sessionCookie!,
        },
        body: json.encode({
          "title": title,
          "body": body,
        }),
      );

      if (res.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        throw Exception("HTTP ${res.statusCode}: ${res.body}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("수정 실패: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, false),
        ),
        title: const Text("수정"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("취소", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottom),
          child: SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _loading
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text("저장"),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                hintText: "제목",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _bodyCtrl,
                decoration: const InputDecoration(
                  hintText: "내용",
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
