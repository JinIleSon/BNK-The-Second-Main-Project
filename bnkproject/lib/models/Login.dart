// lib/models/Login.dart
/*
  날짜 : 2025.12.16.
  이름 : 강민철
  내용 : 로그인 응답 model
 */

import 'UserProfile.dart';

class LoginResult {
  final bool ok;
  final String? token;
  final int? sessionExpiresIn; // 초 단위
  final UserProfile? user;
  final String? message;

  LoginResult({
    required this.ok,
    this.token,
    this.sessionExpiresIn,
    this.user,
    this.message,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    return LoginResult(
      ok: json['ok'] == true,
      token: json['token']?.toString(),
      sessionExpiresIn: _toInt(json['sessionExpiresIn']),
      user: json['user'] != null
          ? UserProfile.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      message: json['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ok': ok,
      'token': token,
      'sessionExpiresIn': sessionExpiresIn,
      'user': user?.toJson(),
      'message': message,
    };
  }
}

class MeResult {
  final bool ok;
  final UserProfile? user;
  final int? remainSeconds;
  final String? message;

  MeResult({
    required this.ok,
    this.user,
    this.remainSeconds,
    this.message,
  });

  factory MeResult.fromJson(Map<String, dynamic> json) {
    return MeResult(
      ok: json['ok'] == true,
      user: json['user'] != null
          ? UserProfile.fromJson(json['user'] as Map<String, dynamic>)
          : null,
      remainSeconds: _toInt(json['remainSeconds']),
      message: json['message']?.toString(),
    );
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
