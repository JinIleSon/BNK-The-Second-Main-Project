import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:bnkproject/screens/auth/signup/authsession.dart';
import '../widgets/category_tab.dart';
import '../widgets/feed_item.dart';
import '../pages/boarder_detail.dart';

String? getToken() => authsession.token;

class BoarderFollowing extends StatefulWidget {
  const BoarderFollowing({super.key});

  @override
  State<BoarderFollowing> createState() => _BoarderFollowingState();
}

class _BoarderFollowingState extends State<BoarderFollowing> {
  static const baseUrl = "http://10.0.2.2:8080/BNK";

  int channelIndex = 0;

  final items = <FeedItem>[];
  bool _loading = false;
  String? _error;
  String? _lastPostId;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetch(reset: true);
  }

  Future<void> _fetch({required bool reset}) async {
    final token = getToken();
    if (token == null) {
      setState(() => _error = "로그인이 필요합니다.");
      return;
    }

    if (_loading) return;

    setState(() {
      _loading = true;
      _error = null;
      if (reset) {
        items.clear();
        _lastPostId = null;
        _hasMore = true;
      }
    });

    try {
      final qs = <String, String>{
        "size": "20",
        if (_lastPostId != null) "lastPostId": _lastPostId!,
      };

      final uri = Uri.parse("$baseUrl/api/post/following").replace(queryParameters: qs);

      final res = await http.get(uri, headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      });

      if (res.statusCode == 401 || res.statusCode == 403) {
        throw Exception("로그인이 필요합니다.");
      }
      if (res.statusCode != 200) {
        throw Exception("팔로잉 피드 조회 실패: ${res.statusCode}");
      }

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as List;
      if (data.isEmpty) {
        setState(() => _hasMore = false);
        return;
      }

      final newItems = data.map((e) {
        // 1) 키 호환: postId/postid, createdAt/createdat
        final pidRaw = e["postId"] ?? e["postid"];
        final createdAtRaw = e["createdAt"] ?? e["createdat"];

        // 2) 작성자/아바타: 서버에서 내려주는 값(없으면 fallback)
        final authorRaw = e["authorName"] ?? e["authorname"] ?? e["authornickname"];
        final avatarRaw = e["avatarUrl"] ?? e["avatarurl"] ?? e["authoravatarurl"];

        // 3) 카운트: likeCount/likecount, commentCount/commentcount
        final likeRaw = e["likeCount"] ?? e["likecount"] ?? 0;
        final commentRaw = e["commentCount"] ?? e["commentcount"] ?? 0;

        final pid = (pidRaw is int) ? pidRaw : int.parse(pidRaw.toString());
        final likeCnt = (likeRaw is int) ? likeRaw : int.parse(likeRaw.toString());
        final commentCnt = (commentRaw is int) ? commentRaw : int.parse(commentRaw.toString());

        final author = (authorRaw ?? "사용자").toString();
        final avatar = (avatarRaw ?? "icon:0").toString();

        return FeedItem(
          postId: pid,
          author: author,
          timeAgo: _timeAgo(createdAtRaw),
          title: (e["title"] ?? "").toString(),
          body: (e["body"] ?? "").toString(),
          avatarUrl: avatar,
          likeCount: likeCnt,
          commentCount: commentCnt,
          isLiked: (e["isLiked"] ?? e["isliked"] ?? 0) == 1,
        );
      }).toList();

      setState(() {
        items.addAll(newItems);
        _lastPostId = newItems.last.postId.toString();
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  String _timeAgo(dynamic createdAt) {
    try {
      final dt = DateTime.parse(createdAt.toString()).toLocal();
      final diff = DateTime.now().difference(dt);

      if (diff.inSeconds < 60) return "${        diff.inSeconds}초 전";
      if (diff.inMinutes < 60) return "${diff.inMinutes}분 전";
      if (diff.inHours < 24) return "${diff.inHours}시간 전";
      return "${diff.inDays}일 전";
    } catch (_) {
      return "";
    }
  }

  Future<void> _toggleLike(FeedItem it) async {
    final token = getToken();
    if (token == null) return;

    final prevLiked = it.isLiked;

    setState(() {
      it.isLiked = !it.isLiked;
      it.likeCount += it.isLiked ? 1 : -1;
    });

    try {
      final uri = Uri.parse("$baseUrl/api/post/${it.postId}/like");
      final res = it.isLiked
          ? await http.post(uri, headers: {"Authorization": "Bearer $token"})
          : await http.delete(uri, headers: {"Authorization": "Bearer $token"});

      if (res.statusCode != 200) throw Exception("좋아요 처리 실패: ${res.statusCode}");
    } catch (e) {
      setState(() {
        it.isLiked = prevLiked;
        it.likeCount += it.isLiked ? 1 : -1;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () => _fetch(reset: true),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 110),
            children: [
              const SizedBox(height: 10),
              const SizedBox(height: 10),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                ),

              ...items.map((it) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: FeedItemCard(
                  item: it,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => BoarderDetail(item: it)),
                    );
                    setState(() {});
                  },
                  onToggleLike: () => _toggleLike(it),
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }
}