/*
  날짜 : 2025.12.22.
  이름 : 강민철
  내용 : 호가, 갯수 문자열 -> int/double로 정리
 */

class HogaValueParser {
  // "+110250" / "-200" / " 0" / "" -> int?
  static int? toInt(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    // 숫자 아닌 값 섞여 들어오면 제거(안전)
    final cleaned = s.replaceAll(',', '');
    final v = int.tryParse(cleaned);
    return v;
  }

  // "+3.72" / "-0.12" / "0.00" -> double?
  static double? toDouble(String? raw) {
    if (raw == null) return null;
    final s = raw.trim();
    if (s.isEmpty) return null;

    final cleaned = s.replaceAll(',', '');
    final v = double.tryParse(cleaned);
    return v;
  }
}
