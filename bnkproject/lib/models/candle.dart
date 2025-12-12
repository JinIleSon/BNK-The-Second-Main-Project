// lib/models/candle.dart
//
// 백엔드 CandleDTO 에 대응하는 Flutter 모델 클래스

/*
  날짜 : 2025.12.11.
  이름 : 강민철
  내용 : CandleDTO
 */

class Candle {
  /// unix seconds (백엔드 CandleDTO의 long time)
  final int time;

  /// 시가
  final double open;

  /// 고가
  final double high;

  /// 저가
  final double low;

  /// 종가
  final double close;

  Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  /// JSON -> Candle
  factory Candle.fromJson(Map<String, dynamic> json) {
    final numTime = json['time'] as num;
    final numOpen = json['open'] as num;
    final numHigh = json['high'] as num;
    final numLow = json['low'] as num;
    final numClose = json['close'] as num;

    return Candle(
      time: numTime.toInt(),
      open: numOpen.toDouble(),
      high: numHigh.toDouble(),
      low: numLow.toDouble(),
      close: numClose.toDouble(),
    );
  }

  /// Candle -> JSON (보낼 일은 거의 없겠지만 참고용)
  Map<String, dynamic> toJson() {
    return {
      'time': time,
      'open': open,
      'high': high,
      'low': low,
      'close': close,
    };
  }

  /// 편의용: time(unix seconds)을 DateTime으로 보고 싶을 때
  DateTime get dateTime =>
      DateTime.fromMillisecondsSinceEpoch(time * 1000);
}
