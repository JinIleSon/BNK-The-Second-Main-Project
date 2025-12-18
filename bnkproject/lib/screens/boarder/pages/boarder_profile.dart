import 'package:flutter/material.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : 프로필
 */

class BoarderProfile extends StatefulWidget {
  const BoarderProfile({super.key});

  @override
  State<BoarderProfile> createState() => _BoarderProfileState();
}

class _BoarderProfileState extends State<BoarderProfile> {
  // 설정값(하드코딩 → 나중에 API/저장으로 교체)
  String nickname = "응애";
  int avatarIndex = 0;

  int mutualFollow = 0; // 맞팔로우
  int followers = 0;
  int following = 2;

  int filterIndex = 0; // 전체/게시글/남긴 글/좋아요

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

  final List<String> filters = const ["전체", "게시글", "남긴 글", "좋아요 누른 글"];

  void openEditSheet() {
    final nickCtrl = TextEditingController(text: nickname);
    int tempAvatar = avatarIndex;

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
                  const Text(
                    "프로필 편집",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
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
                      labelText: "닉네임 변경",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final nn = nickCtrl.text.trim();
                        setState(() {
                          if (nn.isNotEmpty) nickname = nn;
                          avatarIndex = tempAvatar;
                        });
                        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.more_horiz),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          // 1줄: 닉네임 / 아이콘
          Row(
            children: [
              Expanded(
                child: Text(
                  nickname,
                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w900),
                ),
              ),
              CircleAvatar(
                radius: 42,
                backgroundColor: Colors.white12,
                child: Icon(avatarIcons[avatarIndex], size: 38, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2줄: 맞팔로우 / 팔로워 / 팔로잉
          Row(
            children: [
              _stat("맞팔로우", mutualFollow),
              _stat("팔로워", followers, arrow: true),
              _stat("팔로잉", following, arrow: true),
            ],
          ),
          const SizedBox(height: 14),

          // 프로필 편집 버튼
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonal(
              onPressed: openEditSheet,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("프로필 편집", style: TextStyle(fontWeight: FontWeight.w900)),
            ),
          ),
          const SizedBox(height: 18),

          // 3줄: 전체 / 게시글 / 남긴 글 / 좋아요 누른 글 (필터)
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
                  onSelected: (_) => setState(() => filterIndex = i),
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

          // 아래는 “느낌 잡는” 더미 목록
          ...List.generate(6, (idx) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF121318),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                "${filters[filterIndex]} 더미 항목 #${idx + 1}",
                style: const TextStyle(color: Colors.white70),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _stat(String label, int value, {bool arrow = false}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white60, fontSize: 16)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text("$value", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
                if (arrow) ...[
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, color: Colors.white60),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}