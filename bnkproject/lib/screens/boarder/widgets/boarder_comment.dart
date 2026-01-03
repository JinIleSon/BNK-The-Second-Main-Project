import 'dart:convert';
import '../../auth/signup/authsession.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String? getToken() => authsession.token;

/*
    날짜 : 2026.01.02, 01.03
    이름 : 이준우
    내용 : 댓글 JWT 연동, 시간 UI 수정, 수정 삭제 기능 추가
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

  int? _editingCommentId;
  final _editCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _editCtrl.dispose();
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

    return h;
  }

  // 시간 출력 수정
  String _fmtKstMinute(String? raw) {
    if (raw == null || raw.trim().isEmpty) return "";

    final normalized = raw.trim().replaceFirst(' ', 'T');

    try {
      var dt = DateTime.parse(normalized).toLocal();

      String two(int v) => v.toString().padLeft(2, '0');
      return "${dt.year}.${two(dt.month)}.${two(dt.day)} "
          "${two(dt.hour)}:${two(dt.minute)}";
    } catch (_) {
      return raw;
    }
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
      final r = await _fetchComments(size: 20);
      setState(() {
        _comments.addAll(r.items);
        _lastCommentId = _comments.isNotEmpty ? _comments.last.commentId : null;
        _hasMore = r.hasMoreRaw;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<({List<_CommentVm> items, bool hasMoreRaw})> _fetchComments({int size = 20}) async {
    final qp = <String, String>{'size': '$size'};
    if (_lastCommentId != null) qp['lastCommentId'] = '$_lastCommentId';

    final uri = Uri.parse('$baseUrl/api/posts/${widget.postId}/comments')
        .replace(queryParameters: qp);

    final res = await http.get(uri, headers: _headers(json: false));
    if (res.statusCode != 200) {
      throw Exception('댓글 조회 실패: ${res.statusCode} ${res.body}');
    }

    final List<dynamic> data = jsonDecode(utf8.decode(res.bodyBytes));

    final rawHasMore = data.length == size;

    final items = data
        .map((e) => _CommentVm.fromJson(e as Map<String, dynamic>))
        .where((c) => c.status.toUpperCase() != 'DELETED')
        .toList();

    return (items: items, hasMoreRaw: rawHasMore);
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() => _loading = true);

    try {
      final r = await _fetchComments(size: 20);
      setState(() {
        _comments.addAll(r.items);
        _lastCommentId = _comments.isNotEmpty ? _comments.last.commentId : null;
        _hasMore = r.hasMoreRaw;
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

  Future<void> _openCommentActions(_CommentVm c) async {
    if (c.status.toUpperCase() == 'DELETED') return;

    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("수정"),
              onTap: () {
                Navigator.pop(context);
                _startEdit(c);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text("삭제"),
              onTap: () async {
                Navigator.pop(context);
                await _deleteComment(c.commentId);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _startEdit(_CommentVm c) {
    setState(() {
      _editingCommentId = c.commentId;
      _editCtrl.text = c.body;
    });
  }

  void _cancelEdit() {
    setState(() => _editingCommentId = null);
  }

  Future<void> _updateComment(int commentId, String body) async {
    final safe = body.trim();
    if (safe.isEmpty) return;

    setState(() => _loading = true);
    try {
      final uri = Uri.parse('$baseUrl/api/comments/$commentId');
      final res = await http.put(
        uri,
        headers: _headers(),
        body: jsonEncode({'body': safe}),
      );

      if (res.statusCode != 200) {
        return;
      }
      _cancelEdit();
      await _loadInitial();
    } catch (e) {
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _deleteComment(int commentId) async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse('$baseUrl/api/comments/$commentId');
      final res = await http.delete(uri, headers: _headers(json: false));

      if (res.statusCode != 200) {
        return;
      }

      await _loadInitial();
    } catch (e) {

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
                final nick = (c.nickname ?? "").toString().trim();
                final showNick = nick.isEmpty ? "사용자" : nick;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121318),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.white10,
                            child: const Icon(Icons.person, size: 16, color: Colors.white70),
                          ),
                          const SizedBox(width: 8),

                          Expanded(child: Text(showNick)),

                          if (c.mine && c.status.toUpperCase() != 'DELETED')
                            IconButton(
                              icon: const Icon(Icons.more_vert, size: 18),
                              onPressed: _loading ? null : () => _openCommentActions(c),
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),
                      if (_editingCommentId == c.commentId && c.status.toUpperCase() != 'DELETED')
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _editCtrl,
                                minLines: 1,
                                maxLines: 4,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.check, size: 18),
                              onPressed: _loading ? null : () => _updateComment(c.commentId, _editCtrl.text),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: _loading ? null : _cancelEdit,
                            ),
                          ],
                        )
                      else
                        Text(c.body),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          _fmtKstMinute(c.createdAt),
                          style: const TextStyle(fontSize: 12, color: Colors.white54),
                        ),
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
      nickname: _asStr(
          j['nickname'] ??
              j['authorNickname'] ??
              j['AUTHOR_NICKNAME'] ??
              j['NICKNAME']
      ),
      avatarUrl: _asStr(
          j['avatarUrl'] ??
              j['authorAvatarUrl'] ??
              j['AUTHOR_AVATARURL'] ??
              j['AVATARURL']
      ),
      createdAt: _asStr(j['createdAt'] ?? j['CREATEDAT']),
      mine: (j['mine'] ?? false) as bool,
    );
  }
}
