// lib/models/EtfMain.dart

import 'EtfQuote.dart';

class EtfMain {
  final List<EtfQuote> etfs;
  final double usdKrw;

  EtfMain({
    required this.etfs,
    required this.usdKrw,
  });

  factory EtfMain.fromJson(Map<String, dynamic> json) {
    final list = (json['etfs'] as List<dynamic>? ?? const []);
    return EtfMain(
      etfs: list
          .map((e) => EtfQuote.fromJson(e as Map<String, dynamic>))
          .toList(),
      usdKrw: _toDouble(json['usdKrw']) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'etfs': etfs.map((e) => e.toJson()).toList(),
      'usdKrw': usdKrw,
    };
  }
}

double? _toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  return double.tryParse(value.toString());
}
