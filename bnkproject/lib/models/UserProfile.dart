// lib/models/UserProfile.dart
/*
  날짜 : 2025.12.16.
  이름 : 강민철
  내용 : User 관련 model (사용자 요약 model)
 */

class UserProfile {
  final int uid;
  final String mid;
  final String mname;
  final String? memail;
  final String? mphone;
  final String? mgrade;
  final String? role;

  UserProfile({
    required this.uid,
    required this.mid,
    required this.mname,
    this.memail,
    this.mphone,
    this.mgrade,
    this.role,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: _toInt(json['uid']) ?? 0,
      mid: json['mid']?.toString() ?? '',
      mname: json['mname']?.toString() ?? '',
      memail: json['memail']?.toString(),
      mphone: json['mphone']?.toString(),
      mgrade: json['mgrade']?.toString(),
      role: json['role']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'mid': mid,
      'mname': mname,
      'memail': memail,
      'mphone': mphone,
      'mgrade': mgrade,
      'role': role,
    };
  }
}

int? _toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}
