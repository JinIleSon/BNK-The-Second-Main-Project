import 'dart:convert';
import 'package:http/http.dart' as http;

/*
    날짜 : 2025.12.30
    이름 : 이준우
    내용 : post api 추가(커뮤니티)
 */

class PostListResult {
  final List<Map<String, dynamic>> items; // raw json list
  final int? nextLastPostId;
  final bool hasNext;

  PostListResult({
    required this.items,
    required this.nextLastPostId,
    required this.hasNext,
  });

  factory PostListResult.fromJson(Map<String, dynamic> json) {
    final list = (json['items'] as List? ?? [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();

    return PostListResult(
      items: list,
      nextLastPostId: json['nextLastPostId'] is int ? json['nextLastPostId'] as int : null,
      hasNext: json['hasNext'] == true,
    );
  }
}

class PostApi {
  final String baseUrl;
  final String? contextPath;
  final int? debugUid;

  PostApi({
    required this.baseUrl,
    this.contextPath,
    this.debugUid,
  });

  Uri _uri(String path, [Map<String, String>? query]) {
    final prefix = (contextPath == null || contextPath!.isEmpty) ? '' : contextPath!;
    return Uri.parse('$baseUrl$prefix$path').replace(queryParameters: query);
  }

  Map<String, String> _headers() {
    final h = <String, String>{
      'Content-Type': 'application/json',
    };
    if (debugUid != null) {
      h['X-UID'] = debugUid.toString();
    }
    return h;
  }

  Future<PostListResult> fetchBoardPosts({
    int size = 20,
    int? lastPostId,
  }) async {
    final query = <String, String>{
      'size': '$size',
      if (lastPostId != null) 'lastPostId': '$lastPostId',
    };

    final res = await http.get(
      _uri('/api/post/board', query),
      headers: _headers(),
    );

    if (res.statusCode != 200) {
      throw Exception('fetchBoardPosts failed: ${res.statusCode} ${res.body}');
    }

    final jsonBody = json.decode(res.body) as Map<String, dynamic>;
    return PostListResult.fromJson(jsonBody);
  }
}
