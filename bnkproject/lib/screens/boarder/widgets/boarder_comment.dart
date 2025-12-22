import 'package:flutter/material.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : 댓글 위젯
 */

class BoarderComment extends StatefulWidget {
  final int postId;
  final VoidCallback onAddComment;

  const BoarderComment({
    super.key,
    required this.postId,
    required this.onAddComment,
  });

  @override
  State<BoarderComment> createState() => _BoarderCommentState();
}

class _BoarderCommentState extends State<BoarderComment> {
  final _ctrl = TextEditingController();
  final List<String> _comments = ["좋은 글이네요!", "저도 같은 생각입니다."];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _comments.insert(0, text);
      _ctrl.clear();
    });
    widget.onAddComment();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _comments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF121318),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(_comments[i]),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(
                    hintText: "댓글을 입력하세요",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _send,
                child: const Text("등록"),
              )
            ],
          ),
        ),
      ],
    );
  }
}
