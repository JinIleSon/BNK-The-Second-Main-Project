import 'package:flutter/material.dart';

class BoarderProfile extends StatelessWidget {
  const BoarderProfile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('내 계정')),
      body: const Center(
        child: Text('프로필 / 최근 활동 (하드코딩 상태)'),
      ),
    );
  }
}
