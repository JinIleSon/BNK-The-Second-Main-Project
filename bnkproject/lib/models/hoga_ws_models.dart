/*
  날짜 : 2025.12.22.
  이름 : 강민철
  내용 : WS 원본 메시지 파싱용 모델 (Root -> data[0] -> values)
 */

class HogaWsRoot {
  final String? trnm;
  final List<HogaWsRow> data;

  HogaWsRoot({required this.trnm, required this.data});

  factory HogaWsRoot.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'];
    return HogaWsRoot(
      trnm: json['trnm'] as String?,
      data: (rawData is List)
          ? rawData
          .whereType<Map>()
          .map((e) => HogaWsRow.fromJson(e.cast<String, dynamic>()))
          .toList()
          : <HogaWsRow>[],
    );
  }
}

class HogaWsRow {
  final String type; // "0D" | "0A"
  final String? name;
  final String? item;
  final Map<String, String> values; // fid -> string

  HogaWsRow({
    required this.type,
    required this.values,
    this.name,
    this.item,
  });

  factory HogaWsRow.fromJson(Map<String, dynamic> json) {
    final rawValues = json['values'];
    final map = <String, String>{};

    if (rawValues is Map) {
      for (final entry in rawValues.entries) {
        final k = entry.key?.toString();
        if (k == null) continue;
        map[k] = entry.value?.toString() ?? '';
      }
    }

    return HogaWsRow(
      type: (json['type']?.toString() ?? '').trim(),
      name: json['name']?.toString(),
      item: json['item']?.toString(),
      values: map,
    );
  }
}
