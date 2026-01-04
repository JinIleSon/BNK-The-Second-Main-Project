import 'dart:convert';
import 'package:bnkproject/screens/boarder/pages/boarder_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bnkproject/screens/boarder/widgets/feed_item.dart';

import 'package:bnkproject/screens/auth/signup/authsession.dart';

/*
    날짜 : 2026.01.04
    이름 : 이준우
    내용 : 추천 탭
 */

class BoarderRecommend extends StatefulWidget {
  const BoarderRecommend({super.key});

  @override
  State<BoarderRecommend> createState() => _BoarderRecommendState();
}

class _BoarderRecommendState extends State<BoarderRecommend> {
  static const baseUrl = "http://10.0.2.2:8080/BNK";

  bool _loading = false;
  String? _error;
  final List<_PostVm> _items = [];

  Map<String, String> _authHeaders() {
    final t = authsession.token;
    if (t == null || t.isEmpty) return {"Content-Type": "application/json"};
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $t",
    };
  }

  bool get _isLoggedIn {
    final t = authsession.token;
    return t != null && t.isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _fetchRecommend();
  }

  Future<void> _fetchRecommend() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final uri = Uri.parse("$baseUrl/api/post/recommend?size=20");
      final res = await http.get(uri, headers: _authHeaders());

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);

        final List list = body is List ? body : (body["items"] ?? body["data"] ?? []);

        final parsed = list.map((e) => _PostVm.fromJson(e)).toList();

        if (authsession.isLoggedIn) {
          for (final p in parsed) {
            final snap = likeCache[p.postId];
            if (snap != null) {
              p.likedByMe = snap.liked;
              p.likeCount = snap.count;
            }
          }
        } else {
          for (final p in parsed) {
            p.likedByMe = false;
          }
        }

        if (!mounted) return;
        setState(() {
          _items
            ..clear()
            ..addAll(parsed);
          _loading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = "추천 불러오기 실패 (${res.statusCode})";
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = "네트워크 오류: $e";
      });
    }
  }

  Future<void> _toggleLike(_PostVm item) async {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인 후 좋아요를 누를 수 있어요.")),
      );
      return;
    }
    if (item.likeLoading) return;

    setState(() => item.likeLoading = true);

    final uri = Uri.parse("$baseUrl/api/post/${item.postId}/like");

    try {

      final res = await http.post(uri, headers: _authHeaders());

      if (res.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("좋아요 실패 (${res.statusCode})")),
        );
        return;
      }

      final data = jsonDecode(res.body);
      final liked = data["liked"] == true;
      final likeCount = (data["likeCount"] ?? item.likeCount) as num;

      if (!mounted) return;
      setState(() {
        item.likedByMe = liked;
        item.likeCount = likeCount.toInt();
      });

      likeCache[item.postId] = LikeSnap(item.likedByMe, item.likeCount);

      await _fetchRecommend();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("네트워크 오류로 좋아요 실패")),
      );
    } finally {
      if (mounted) setState(() => item.likeLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _fetchRecommend,
              child: const Text("다시 시도"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchRecommend,
      child: ListView.separated(
        padding: const EdgeInsets.only(bottom: 100, top: 10),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
        itemBuilder: (_, i) {
          final item = _items[i];

          return ListTile(
            onTap: () async {
              final feed = FeedItem(
                postId: item.postId,
                title: item.title,
                body: item.body,
                author: "사용자",
                commentCount: 0,
                viewCount: 0, timeAgo: '',
              );

              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => BoarderDetail(item: feed)),
              );

              if (!mounted) return;
              await _fetchRecommend();
            },

            title: Text(
              item.title.isEmpty ? "(제목 없음)" : item.title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                item.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, height: 1.25),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.likeLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    onPressed: _isLoggedIn ? () => _toggleLike(item) : null,
                    icon: Icon(
                      item.likedByMe ? Icons.favorite : Icons.favorite_border,
                      color: item.likedByMe ? Colors.pinkAccent : Colors.white70,
                      size: 20,
                    ),
                  ),
                Text("${item.likeCount}", style: const TextStyle(color: Colors.white70)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PostVm {
  final int postId;
  final String title;
  final String body;
  int likeCount;
  bool likedByMe;
  bool likeLoading;


  _PostVm({
    required this.postId,
    required this.title,
    required this.body,
    required this.likeCount,
    required this.likedByMe,
    this.likeLoading = false,
  });

  factory _PostVm.fromJson(Map<String, dynamic> j) {
    final likeCount = (j["likeCount"] ?? 0) as num;
    final likedByMeRaw = j["likedByMe"];

    bool likedByMe = false;
    if (likedByMeRaw is bool) likedByMe = likedByMeRaw;
    if (likedByMeRaw is num) likedByMe = likedByMeRaw.toInt() == 1;
    if (likedByMeRaw is String) likedByMe = likedByMeRaw == "1" || likedByMeRaw.toLowerCase() == "true";

    final postIdRaw = j["postId"] ?? j["POSTID"];
    final postId = (postIdRaw is num)
        ? postIdRaw.toInt()
        : int.tryParse(postIdRaw.toString()) ?? 0;

    return _PostVm(
      postId: postId,
      title: (j["title"] ?? "").toString(),
      body: (j["body"] ?? "").toString(),
      likeCount: likeCount.toInt(),
      likedByMe: likedByMe,
    );
  }
}
