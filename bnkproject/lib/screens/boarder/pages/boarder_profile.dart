import 'dart:convert';
import 'package:bnkproject/screens/auth/login_main.dart';
import 'package:bnkproject/screens/auth/signup/authsession.dart';
import 'package:bnkproject/screens/boarder/boarder_main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:bnkproject/api/member_api.dart';


String? getToken() => authsession.token;

/*
    날짜 : 2026.01.03
    이름 : 이준우
    내용 : 프로필(실데이터 연동)
 */

class BoarderProfile extends StatefulWidget {
  const BoarderProfile({super.key});

  @override
  State<BoarderProfile> createState() => _BoarderProfileState();
}

class _BoarderProfileState extends State<BoarderProfile> {
  static const baseUrl = "http://10.0.2.2:8080/BNK";

  bool loading = true;
  String? errorMsg;

  String nickname = "";
  String bio = "";
  String avatarUrl = "icon:0";

  int postCount = 0;
  int commentCount = 0;
  int likeCount = 0;

  int filterIndex = 0; // 0=게시글, 1=댓글, 2=좋아요

  final List<IconData> avatarIcons = const [
    Icons.headset_mic_rounded,
    Icons.android_rounded,
    Icons.savings_rounded,
    Icons.auto_graph_rounded,
    Icons.rocket_launch_rounded,
    Icons.pets_rounded,
    Icons.sports_esports_rounded,
    Icons.face_rounded,
  ];

  final List<String> filters = const ["게시글", "댓글", "좋아요"];

  List<dynamic> items = [];
  bool listLoading = false;

  int _avatarIndexFromUrl(String url) {
    if (url.startsWith("icon:")) {
      final idx = int.tryParse(url.split(":").last);
      if (idx != null && idx >= 0 && idx < avatarIcons.length) return idx;
    }
    return 0;
  }

  Map<String, String> _authHeaders() {
    final t = getToken();
    if (t == null || t.isEmpty) return {"Content-Type": "application/json"};
    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $t",
    };
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final t = getToken();
      if (t == null || t.isEmpty) {
        _goLogin();
        return;
      }
      await fetchProfile();
    });
  }

  Future<void> fetchProfile() async {
    setState(() {
      loading = true;
      errorMsg = null;
    });

    try {
      final uri = Uri.parse("$baseUrl/api/profile/me");
      final res = await http.get(uri, headers: _authHeaders());

      if (res.statusCode == 401 || res.statusCode == 403) {
        _goLogin();
        return;
      }

      if (res.statusCode != 200) {
        throw Exception("프로필 조회 실패: ${res.statusCode} ${res.body}");
      }

      final data = jsonDecode(res.body);
      final p = data["profile"] ?? {};

      setState(() {
        nickname = (p["nickname"] ?? "") as String;
        bio = (p["bio"] ?? "") as String;
        avatarUrl = (p["avatarUrl"] ?? "icon:0") as String;

        postCount = (data["postCount"] ?? 0) as int;
        commentCount = (data["commentCount"] ?? 0) as int;
        likeCount = (data["likeCount"] ?? 0) as int;
      });

      await fetchTabList();
    } catch (e) {
      setState(() => errorMsg = "$e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> fetchTabList() async {
    setState(() {
      listLoading = true;
      items = [];
    });

    try {
      final path = switch (filterIndex) {
        0 => "/api/profile/me/posts",
        1 => "/api/profile/me/comments",
        _ => "/api/profile/me/likes",
      };

      final uri = Uri.parse("$baseUrl$path?size=20");
      final res = await http.get(uri, headers: _authHeaders());

      if (res.statusCode == 401 || res.statusCode == 403) {
        _goLogin();
        return;
      }

      if (res.statusCode != 200) {
        throw Exception("목록 조회 실패: ${res.statusCode} ${res.body}");
      }

      final list = jsonDecode(res.body);
      setState(() => items = (list as List));
    } catch (e) {
      setState(() => errorMsg = "$e");
    } finally {
      if (mounted) setState(() => listLoading = false);
    }
  }

  Future<void> updateProfile({required String newNick, required int newAvatar, required String newBio}) async {
    final body = jsonEncode({
      "nickname": newNick,
      "avatarUrl": "icon:$newAvatar",
      "bio": newBio,
    });

    final uri = Uri.parse("$baseUrl/api/profile/me");
    final res = await http.put(uri, headers: _authHeaders(), body: body);

    if (res.statusCode == 401 || res.statusCode == 403) {
      _goLogin();
      return;
    }

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception("프로필 수정 실패: ${res.statusCode} ${res.body}");
    }

    await fetchProfile();
  }

  // 로그아웃 함수 추가
  Future<void> _logout() async {
    final ok = await memberApi.logout();

    authsession.token = null;
    memberApi.token = null;
    memberApi.sessionCookie = null;
  }

  // 로그아웃 완료시 피드 메인으로 이동
  Future<void> _logoutAndGoBoardMain() async {
    final nav = Navigator.of(context, rootNavigator: true);

    await _logout();

    if (!mounted) return;

    nav.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const BoardMain()),
          (_) => false,
    );
  }

  void openEditSheet() {
    final nickCtrl = TextEditingController(text: nickname);
    final bioCtrl = TextEditingController(text: bio);
    int tempAvatar = _avatarIndexFromUrl(avatarUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121318),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("프로필 편집", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 14),

                  const Text("아이콘 선택", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(avatarIcons.length, (i) {
                      final selected = i == tempAvatar;
                      return GestureDetector(
                        onTap: () => setSheetState(() => tempAvatar = i),
                        child: CircleAvatar(
                          radius: 22,
                          backgroundColor: selected ? Colors.white24 : Colors.white10,
                          child: Icon(avatarIcons[i], color: Colors.white),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: nickCtrl,
                    decoration: const InputDecoration(
                      labelText: "닉네임",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: bioCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: "소개",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final nn = nickCtrl.text.trim();
                        final bb = bioCtrl.text.trim();

                        if (nn.isEmpty) return;

                        Navigator.pop(context);
                        try {
                          await updateProfile(newNick: nn, newAvatar: tempAvatar, newBio: bb);
                        } catch (e) {
                          if (mounted) {
                            setState(() => errorMsg = "$e");
                          }
                        }
                      },
                      child: const Text("저장"),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _goLogin() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatarIdx = _avatarIndexFromUrl(avatarUrl);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("로그아웃"),
                    content: const Text("로그아웃 하시겠습니까?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("취소"),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("확인"),
                      ),
                    ],
                  ),
                );
                if (ok == true) {
                  await _logoutAndGoBoardMain();
                }
              },
              onLongPress: () {
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(
                  "로그아웃",
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : errorMsg != null
          ? Center(child: Text(errorMsg!, style: const TextStyle(color: Colors.redAccent)))
          : ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          // 1줄: 닉네임 / 아이콘
          Row(
            children: [
              Expanded(
                child: Text(
                  nickname.isEmpty ? "닉네임 없음" : nickname,
                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900),
                ),
              ),
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white12,
                child: Icon(avatarIcons[avatarIdx], size: 38, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 10),

          if (bio.isNotEmpty)
            Text(bio, style: const TextStyle(color: Colors.white70, height: 1.3)),

          const SizedBox(height: 14),

          // 게시글/댓글/좋아요
          Row(
            children: [
              _stat("게시글", postCount),
              _stat("댓글", commentCount),
              _stat("좋아요", likeCount),
            ],
          ),
          const SizedBox(height: 14),

          // 프로필 편집 버튼
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: openEditSheet,
              onLongPress: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("로그아웃"),
                    content: const Text("로그아웃 하시겠습니까?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("취소"),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("확인"),
                      ),
                    ],
                  ),
                );

                if (ok == true) {
                  await _logout();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                        (_) => false,
                  );
                }
              },
              child: const Text("프로필 편집", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),

          const SizedBox(height: 18),

          // 탭
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final selected = i == filterIndex;
                return ChoiceChip(
                  selected: selected,
                  onSelected: (_) async {
                    setState(() => filterIndex = i);
                    await fetchTabList();
                  },
                  label: Text(filters[i]),
                  backgroundColor: Colors.white10,
                  selectedColor: Colors.white12,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          if (listLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ))
          else
            ...items.map((it) => _buildItemCard(it)).toList(),
        ],
      ),
    );
  }

  Widget _buildItemCard(dynamic it) {
    // 게시글: {postId, title, body}
    // 댓글:  {commentId, postId, postTitle, body}
    // 좋아요:{postId, title, body}
    final title = (it["title"] ?? it["postTitle"] ?? "") as String;
    final body = (it["body"] ?? "") as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121318),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty)
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          if (title.isNotEmpty) const SizedBox(height: 8),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, height: 1.35),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, int value) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 16)),
            const SizedBox(height: 8),
            Text("$value", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }
}