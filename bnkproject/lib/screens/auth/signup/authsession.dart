class authsession {
  static String? token;
  static int? uId;
  static String? mid;
  static String? role;

  static bool get isLoggedIn => token != null && token!.isNotEmpty;

  static void clear() {
    token = null;
    uId = null;
    mid = null;
    role = null;
  }
}

class LikeSnap {
  final bool liked;
  final int count;
  LikeSnap(this.liked, this.count);
}

final Map<int, LikeSnap> likeCache = {};
