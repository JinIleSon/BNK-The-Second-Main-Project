import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/boarder_comment.dart';
import '../widgets/feed_item.dart';
import 'boarder_edit.dart';
import '../../../api/member_api.dart';
import '../../../utils/auth_guard.dart';

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
          "Content-Type": "application/json; charset=utf-8",
          if (memberApi.sessionCookie != null) "Cookie": memberApi.sessionCookie!,
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
              final loggedIn = await ensureLoggedIn(context);
              if (!loggedIn) return;

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
              final loggedIn = await ensureLoggedIn(context);
              if (!loggedIn) return;

              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("삭제할까요?"),
                  content: const Text("삭제하면 되돌릴 수 없습니다."),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("취소")),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("삭제")),
                  ],
                ),
              );
              if (confirm != true) return;

              final uri = Uri.parse("$baseUrl/api/post/board/${widget.item.postId}");
              final res = await http.delete(
                uri,
                headers: {
                  "Content-Type": "application/json; charset=utf-8",
                  if (memberApi.sessionCookie != null) "Cookie": memberApi.sessionCookie!,
                },
              );

              if (!context.mounted) return;

              if (res.statusCode == 200) {
                Navigator.pop(context, "deleted");
                return;
              }

              if (res.statusCode == 401) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("로그인이 필요합니다.")),
                );
                return;
              }

              if (res.statusCode == 403) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("작성자만 삭제할 수 있습니다.")),
                );
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("삭제 실패: ${res.statusCode}")),
              );
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
                  (widget.item.author.trim().isEmpty) ? "사용자" : widget.item.author,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  "${widget.item.title}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),

                Text(
                  "${widget.item.body}",
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
