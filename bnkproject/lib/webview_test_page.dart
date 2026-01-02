import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewTestPage extends StatefulWidget {
  const WebViewTestPage({super.key});

  @override
  State<WebViewTestPage> createState() => _WebViewTestPageState();
}

class _WebViewTestPageState extends State<WebViewTestPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => debugPrint('[WV] start: $url'),
          onPageFinished: (url) => debugPrint('[WV] finished: $url'),
          onWebResourceError: (err) {
            debugPrint('[WV] ERROR: '
                'code=${err.errorCode}, '
                'type=${err.errorType}, '
                'desc=${err.description}, '
                'url=${err.url}');
          },
        ),
      )
      ..loadHtmlString('''
    <!doctype html>
    <html>
    <body style="margin:0;background:#111;color:#0f0;display:flex;align-items:center;justify-content:center;height:100vh;font-size:26px;">
      WEBVIEW OK
    </body>
    </html>
  ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('WebView Test')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'PAGE OK (이 글자가 보이면 네비게이션은 정상)',
              style: TextStyle(color: Colors.white),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Container(
              color: Colors.white, // WebView 영역이 있는지 눈으로 보이게
              child: WebViewWidget(controller: _controller),
            ),
          ),
        ],
      ),
    );
  }
}
