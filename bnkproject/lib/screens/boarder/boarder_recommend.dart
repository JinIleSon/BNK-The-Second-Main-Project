import 'package:flutter/material.dart';

class BoarderRecommend extends StatelessWidget {
  const BoarderRecommend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 일단 하드코딩 더미 화면
    return ListView(
      children: const [
        ListTile(
          title: Text('추천 피드 1'),
          subtitle: Text('하드코딩 테스트용 더미 데이터'),
        ),
        ListTile(
          title: Text('추천 피드 2'),
          subtitle: Text('나중에 API 연동으로 교체'),
        ),
      ],
    );
  }
}
