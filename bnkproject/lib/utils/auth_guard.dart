import '../api/member_api.dart';
import '../screens/auth/login_main.dart';
import 'package:flutter/material.dart';

/*
    날짜 : 2025.01.02
    이름 : 이준우
    내용 : 피드 글 작성시 로그인 필요
 */

Future<bool> ensureLoggedIn(BuildContext context) async {
  try {
    final me = await memberApi.me();
    if (me.ok) return true;
  } catch (_) {
  }

  final ok = await Navigator.of(context, rootNavigator: true).push<bool>(
    MaterialPageRoute(builder: (_) => const LoginPage()),
  );

  return ok == true;
}
