import 'dart:convert';
import '../../auth/signup/authsession.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String? getToken() => authsession.token;

/*
    날짜 : 2026.01.02
    이름 : 이준우
    내용 : 댓글 GET/POST + JWT 연동
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
  static const baseUrl = "http://10.0.2.2:8080/BNK";

  final _ctrl = TextEditingController();
  bool _loading = false;
  String? _error;

  final List<_CommentVm> _comments = [];
  int? _lastCommentId;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Map<String, String> _headers({bool json = true}) {
    final h = <String, String>{
      'Accept': 'application/json',
    };
    if (json) {
      h['Content-Type'] = 'application/json; charset=utf-8';
    }

    final token = getToken();
    if (token != null && token.isNotEmpty) {
      h['Authorization'] = 'Bearer $token';
    }

    // ✅ 확정 디버그
    print("TOKEN=$token");
    print("AUTH=${h['Authorization']}");

    return h;
  }

  Future<void> _loadInitial() async {
    print("=== _loadInitial called ===");
    setState(() {
      _loading = true;
      _error = null;
      _comments.clear();
      _lastCommentId = null;
      _hasMore = true;
    });

    try {
      final items = await _fetchComments();
      setState(() {
        _comments.addAll(items);
        _lastCommentId = _comments.isNotEmpty ? _comments.last.commentId : null;
        _hasMore = items.isNotEmpty;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<List<_CommentVm>> _fetchComments({int size = 20}) async {
    final qp = <String, String>{'size': '$size'};
    if (_lastCommentId != null) qp['lastCommentId'] = '$_lastCommentId';

    final uri = Uri.parse('$baseUrl/api/posts/${widget.postId}/comments')
        .replace(queryParameters: qp);

    final res = await http.get(uri, headers: _headers(json: false));
    if (res.statusCode != 200) {
      throw Exception('댓글 조회 실패: ${res.statusCode} ${res.body}');
    }

    final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));
    return data
        .map((e) => _CommentVm.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);

    try {
      final items = await _fetchComments(size: 20);
      setState(() {
        _comments.addAll(items);
        _lastCommentId = _comments.isNotEmpty ? _comments.last.commentId : null;
        _hasMore = items.length == 20;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    final token = getToken();
    print("SEND TOKEN=$token");

    setState(() => _loading = true);

    try {
      final uri = Uri.parse('$baseUrl/api/posts/${widget.postId}/comments');
      final res = await http.post(
        uri,
        headers: _headers(),
        body: jsonEncode({'body': text}),
      );

      if (res.statusCode != 200) {
        throw Exception('댓글 등록 실패: ${res.statusCode} ${res.body}');
      }

      _ctrl.clear();
      widget.onAddComment();

      // 운영형: 등록 후 최신 댓글 다시 불러오기(가장 안전)
      await _loadInitial();
    } catch (e) {
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("댓글 등록 실패: $e")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text("에러: $_error"),
          ),
          FilledButton(
            onPressed: _loadInitial,
            child: const Text("다시 시도"),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: _loading && _comments.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n.metrics.pixels >= n.metrics.maxScrollExtent - 120) {
                _loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _comments.length + (_hasMore ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                if (i == _comments.length) {
                  return _loading
                      ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                      : const SizedBox.shrink();
                }

                final c = _comments[i];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121318),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.nickname ?? "익명",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(c.body),
                      const SizedBox(height: 6),
                      Text(
                        c.createdAt ?? "",
                        style: const TextStyle(fontSize: 12, color: Colors.white54),
                      ),
                    ],
                  ),
                );
              },
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
                onPressed: _loading ? null : _send,
                child: const Text("등록"),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class _CommentVm {
  final int commentId;
  final int postId;
  final int uId;
  final String body;
  final String status;
  final String? nickname;
  final String? avatarUrl;
  final String? createdAt;
  final bool mine;

  _CommentVm({
    required this.commentId,
    required this.postId,
    required this.uId,
    required this.body,
    required this.status,
    required this.mine,
    this.nickname,
    this.avatarUrl,
    this.createdAt,
  });

  static int _asInt(dynamic v, {int def = 0}) {
    if (v == null) return def;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? def;
  }

  static String? _asStr(dynamic v) => v?.toString();

  factory _CommentVm.fromJson(Map<String, dynamic> j) {
    return _CommentVm(
      commentId: _asInt(j['commentId'] ?? j['COMMENTID']),
      postId: _asInt(j['postId'] ?? j['POSTID']),
      uId: _asInt(j['uId'] ?? j['uid'] ?? j['UID']),
      body: (j['body'] ?? j['BODY'] ?? '') as String,
      status: (j['status'] ?? j['STATUS'] ?? 'ACTIVE') as String,
      nickname: _asStr(j['nickname'] ?? j['NICKNAME']),
      avatarUrl: _asStr(j['avatarUrl'] ?? j['AVATARURL']),
      createdAt: _asStr(j['createdAt'] ?? j['CREATEDAT']),
      mine: (j['mine'] ?? false) as bool,
    );
  }
}
