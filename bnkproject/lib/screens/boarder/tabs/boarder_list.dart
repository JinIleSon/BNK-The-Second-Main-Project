import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../widgets/feed_item.dart';
import '../pages/boarder_detail.dart';
import '../pages/boarder_write.dart';
import '../../../utils/auth_guard.dart';
import 'package:bnkproject/screens/auth/signup/authsession.dart';

String? getToken() => authsession.token;

class BoarderList extends StatefulWidget {
  const BoarderList({super.key});

  @override
  State<BoarderList> createState() => _BoarderListState();
}

class _BoarderListState extends State<BoarderList> {
  final List<FeedItem> items = [];
  bool loading = false;
  String? errorMsg;

  static const String baseUrl = "http://10.0.2.2:8080/BNK";

  @override
  void initState() {
    super.initState();
    fetchBoardList();
  }

  Future<void> fetchBoardList() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      final uri = Uri.parse("$baseUrl/api/post/board?size=20");

      final res = await http.get(uri);

      if (res.statusCode != 200) {
        throw Exception("HTTP ${res.statusCode}: ${res.body}");
      }

      final jsonBody = json.decode(res.body) as Map<String, dynamic>;
      final list = (jsonBody["items"] as List? ?? []).cast<dynamic>();

      final mapped = list.map((e) {
        final j = (e as Map).cast<String, dynamic>();

        final postId = (j["postid"] as num?)?.toInt() ?? 0;
        final authoruId = (j["authoruId"] as num?)?.toInt() ?? 0;

        final title = (j["title"] ?? "") as String;
        final body  = (j["body"] ?? "") as String;

        final author = (j["authorNickname"] ??
            j["authornickname"] ??
            j["nickname"] ??
            j["NICKNAME"] ??
            j["author"] ??
            "")
            .toString()
            .trim();

        final showAuthor = author.isEmpty ? "사용자" : author;

        final avatarUrl = (j["authoravatarurl"] ??
            "https://i.pravatar.cc/200?u=$postId") as String;

        final likeCount = (j["likecount"] as num?)?.toInt() ?? 0;
        final commentCount = (j["commentcount"] as num?)?.toInt() ?? 0;

        final viewCount = (j["viewcount"] as num?)?.toInt() ?? 0; // 조회수

        final createdAtStr = (j["createdat"] ?? j["createdAt"] ?? j["created_at"])?.toString();
        final createdAt = (createdAtStr != null && createdAtStr.isNotEmpty)
            ? DateTime.tryParse(createdAtStr)
            : null; // 게시일 날짜

        return FeedItem(
          postId: postId,
          authoruId: authoruId,
          author: showAuthor,
          createdAt: createdAt,
          timeAgo: "",
          title: title,
          body: body,
          avatarUrl: avatarUrl,
          likeCount: likeCount,
          commentCount: commentCount,
          isLiked: false,
          viewCount: viewCount,
        );
      }).toList();

      setState(() {
        items
          ..clear()
          ..addAll(mapped);
      });
    } catch (e) {
      setState(() => errorMsg = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _toggleFollowServer(FeedItem it) async {
    final token = getToken();
    if (token == null) throw Exception("로그인이 필요합니다.");

    // authoruId가 0이면 DB에 못 넣음 (대상 uid가 없음)
    if (it.authoruId <= 0) throw Exception("authoruId가 비정상: ${it.authoruId}");

    final prev = it.isFollowing;

    // UI 선반영
    setState(() => it.isFollowing = !it.isFollowing);

    try {
      final uri = Uri.parse("$baseUrl/api/follow/${it.authoruId}");

      final res = it.isFollowing
          ? await http.post(uri, headers: {"Authorization": "Bearer $token"})
          : await http.delete(uri, headers: {"Authorization": "Bearer $token"});

      if (res.statusCode != 200) {
        throw Exception("팔로우 실패: ${res.statusCode} ${res.body}");
      }
    } catch (e) {
      // 실패 시 롤백
      setState(() => it.isFollowing = prev);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : (errorMsg != null)
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("불러오기 실패\n$errorMsg", textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: fetchBoardList,
              child: const Text("다시 시도"),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchBoardList,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: items.map((it) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: FeedItemCard(
                item: it,
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => BoarderDetail(item: it)),
                  );

                  if (result == null || result == "deleted" || result == "updated") {
                    fetchBoardList();
                  } else {
                    setState(() {});
                  }
                },
                onToggleLike: () async {
                  setState(() {
                    it.isLiked = !it.isLiked;
                    it.likeCount += it.isLiked ? 1 : -1;
                  });
                },
                onToggleFollow: () async {
                  try {
                    await _toggleFollowServer(it);
                  } catch (e) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final loggedIn = await ensureLoggedIn(context);
          if (!loggedIn) return;

          final ok = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BoarderWritePage()),
          );

          if (ok == true) {
            fetchBoardList();
          }
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}
