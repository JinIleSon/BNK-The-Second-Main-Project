/*
  날짜 : 2025.12.22.
  이름 : 강민철
  내용 : 호가 API
 */

import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../models/hoga_ws_models.dart';
import '../models/order_book.dart';
import '../utils/hoga_value_parser.dart';

class HogaWsApi {
  final Uri wsUri;

  WebSocketChannel? _channel;
  StreamSubscription? _sub;

  final _snapshotCtrl = StreamController<OrderBookSnapshot>.broadcast();

  // 마지막 값 캐시 (JS와 동일하게)
  Map<String, String>? _last0D;
  Map<String, String>? _last0A;

  static const int hogaLevels = 10;

  HogaWsApi({required this.wsUri});

  Stream<OrderBookSnapshot> get snapshots => _snapshotCtrl.stream;

  void connect() {
    if (_channel != null) return;

    _channel = WebSocketChannel.connect(wsUri);

    _sub = _channel!.stream.listen(
          (event) {
        try {
          final text = event is String ? event : event.toString();
          final decoded = jsonDecode(text);

          if (decoded is! Map<String, dynamic>) return;
          final root = HogaWsRoot.fromJson(decoded);
          if (root.data.isEmpty) return;

          final row = root.data.first;
          final type = row.type;

          if (type == '0D') {
            _last0D = row.values;
            _emitMergedSnapshot(sourceType: '0D');
          } else if (type == '0A') {
            _last0A = row.values;
            _emitMergedSnapshot(sourceType: '0A');
          } else {
            // 다른 타입은 무시
            return;
          }
        } catch (_) {
          // 파싱 실패는 조용히 무시(실시간에서 안전)
        }
      },
      onError: (e) {
        // 필요하면 에러 스트림/로깅 추가
      },
      onDone: () {
        // 서버가 끊으면 정리
        disconnect();
      },
    );
  }

  void disconnect() {
    _sub?.cancel();
    _sub = null;
    _channel?.sink.close();
    _channel = null;
    _last0D = null;
    _last0A = null;
  }

  void dispose() {
    disconnect();
    _snapshotCtrl.close();
  }

  void _emitMergedSnapshot({required String sourceType}) {
    // 0D 없으면 레벨/총잔량 구성 불가 → 그래도 현재가만 보여주고 싶으면 여기 정책 바꾸면 됨
    final v0D = _last0D;
    final v0A = _last0A;

    final levels = <OrderBookLevel>[];

    for (int level = 1; level <= hogaLevels; level++) {
      final askPriceFid = (40 + level).toString(); // 41~50
      final askQtyFid = (60 + level).toString();   // 61~70
      final bidPriceFid = (50 + level).toString(); // 51~60
      final bidQtyFid = (70 + level).toString();   // 71~80

      final bidPrice = HogaValueParser.toInt(v0D?[bidPriceFid]);
      final askPrice = HogaValueParser.toInt(v0D?[askPriceFid]);
      final bidQty = HogaValueParser.toInt(v0D?[bidQtyFid]);
      final askQty = HogaValueParser.toInt(v0D?[askQtyFid]);

      levels.add(OrderBookLevel(
        level: level,
        bidPrice: bidPrice,
        bidQty: bidQty,
        askPrice: askPrice,
        askQty: askQty,
      ));
    }

    final totalAsk = HogaValueParser.toInt(v0D?['121']);
    final totalBid = HogaValueParser.toInt(v0D?['125']);

    // JS 요구사항: "0A가 있으면 0A 우선, 없으면 0D fallback"
    // 네가 준 로그는 0D에 6102/6112가 들어오지만, 실제 환경에서는 0A로 올 수도 있으니 우선순위 유지.
    final priceRaw = v0A?['6102']?.trim().isNotEmpty == true
        ? v0A!['6102']
        : (v0D?['6102'] ?? v0D?['23']);

    final rateRaw = v0A?['6112']?.trim().isNotEmpty == true
        ? v0A!['6112']
        : (v0D?['6112'] ?? v0D?['201']);

    final currentPrice = HogaValueParser.toInt(priceRaw);
    final changeRate = HogaValueParser.toDouble(rateRaw);

    _snapshotCtrl.add(OrderBookSnapshot(
      levels: levels,
      totalAskQty: totalAsk,
      totalBidQty: totalBid,
      currentPrice: currentPrice,
      changeRate: changeRate,
      sourceType: (v0D != null && v0A != null) ? 'MERGED' : sourceType,
    ));
  }
}
