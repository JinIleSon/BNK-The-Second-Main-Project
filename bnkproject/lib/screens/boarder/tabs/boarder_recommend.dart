import 'package:flutter/material.dart';
import '../widgets/category_tab.dart';

/*
    날짜 : 2025.12.17(수)
    이름 : 이준우
    내용 : 추천
 */

class BoarderRecommend extends StatefulWidget {
  const BoarderRecommend({super.key});

  @override
  State<BoarderRecommend> createState() => _BoarderRecommendState();
}

class _BoarderRecommendState extends State<BoarderRecommend> {
  int chipIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.only(bottom: 100),
          children: [
            const SizedBox(height: 10),

            const SizedBox(height: 14),
          ],
        ),
      ],
    );
  }
}
