import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../api/chart_api.dart';

class ChartWebViewBox extends StatefulWidget {
  final String stockCode;
  final String interval;
  final double height;

  const ChartWebViewBox({
    super.key,
    required this.stockCode,
    this.interval = '1m',
    this.height = 220,
  });

  @override
  State<ChartWebViewBox> createState() => _ChartWebViewBoxState();
}

class _ChartWebViewBoxState extends State<ChartWebViewBox> {
  late final WebViewController _controller;
  late final ChartApiClient _api;

  @override
  void initState() {
    super.initState();

    _api = ChartApiClient(baseUrl: 'http://10.0.2.2:8080/BNK'); // 네 서버 주소로

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF1F2025))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) => _fetchAndInject(),
        ),
      )
      ..loadFlutterAsset('assets/chart/lw.html');
  }

  Future<void> _fetchAndInject() async {
    try {
      final candles = await _api.fetchCandles(
        code: widget.stockCode,
        interval: widget.interval,
      );

      final payload = candles.map((c) => {
        "time": c.time,
        "open": c.open,
        "high": c.high,
        "low": c.low,
        "close": c.close,
      }).toList();

      final jsonStr = jsonEncode(payload);

      await _controller.runJavaScript(
        "window.setCandlesFromFlutter(${jsonEncode(jsonStr)});",
      );
    } catch (e) {
      debugPrint('[chart] inject error: $e');
    }
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: WebViewWidget(
          controller: _controller,
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
          },
        ),
      ),
    );
  }
}
