import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/boarder_comment.dart';
import '../widgets/feed_item.dart';
import 'boarder_edit.dart';

/*
    날짜 : 2025.12.17 / 2025.12.31 / 2025.01.01
    이름 : 이준우
    내용 : 게시글 상세 / 수정 & 삭제 추가 / 조회수(임시)
 */

class BoarderDetail extends StatefulWidget {
  final FeedItem item;
  const BoarderDetail({super.key, required this.item});

  @override
  State<BoarderDetail> createState() => _BoarderDetailState();
}

class _BoarderDetailState extends State<BoarderDetail> {
  static const String baseUrl = "http://10.0.2.2:8080/BNK";

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    fetchDetailAndIncView();
  }

  Future<void> fetchDetailAndIncView() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse("$baseUrl/api/post/board/${widget.item.postId}");

      final res = await http.get(
        uri,
        headers: {
          "X-UID": "1",
          // 임시 : 로그인 방식 바꾸면 나중에 수정
        },
      );

      if (res.statusCode != 200) {
        throw Exception("HTTP ${res.statusCode}: ${res.body}");
      }

      final j = (json.decode(res.body) as Map).cast<String, dynamic>();

      final vc = (j["viewcount"] as num?)?.toInt();
      if (vc != null) {
        setState(() => widget.item.viewCount = vc);
      }
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
        title: const Text("상세"),
        actions: [
          TextButton(
            onPressed: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BoarderEditPage(item: widget.item)),
              );

              if (updated == true && context.mounted) {
                Navigator.pop(context, "updated");
              }
            },
            child: const Text("수정", style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () async {
              final uri = Uri.parse("$baseUrl/api/post/board/${widget.item.postId}");

              final res = await http.delete(
                uri,
                headers: {
                  "X-UID": "1",
                },
              );

              if (res.statusCode == 200 && context.mounted) {
                Navigator.pop(context, "deleted");
              } else {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("삭제 실패: ${res.statusCode}")),
                );
              }
            },
            child: const Text("삭제", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null)
          ? Center(child: Text("상세 불러오기 실패\n$_error", textAlign: TextAlign.center))
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (widget.item.author.trim().isEmpty) ? "익명" : widget.item.author,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  "Title : ${widget.item.title}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),

                Text(
                  "Body : ${widget.item.body}",
                  style: const TextStyle(height: 1.35, color: Colors.white70),
                ),

                const SizedBox(height: 12),

                // (선택) 조회수는 계속 보이고 싶으면 유지
                Row(
                  children: [
                    const Icon(Icons.visibility_outlined, size: 18, color: Colors.white60),
                    const SizedBox(width: 6),
                    Text("${widget.item.viewCount}",
                        style: const TextStyle(color: Colors.white60)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: BoarderComment(
              postId: widget.item.postId,
              onAddComment: () => widget.item.commentCount += 1,
            ),
          ),
        ],
      ),
    );
  }
}
