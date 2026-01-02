import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  void Function(String? payload)? onTap;

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (resp) {
        onTap?.call(resp.payload);
      },
    );

    const channel = AndroidNotificationChannel(
      'feed_channel',
      'Feed Notification',
      description: '피드 알림',
      importance: Importance.max,
    );

    final androidPlugin =
    _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    // ✅ 채널 생성 (1번만)
    await androidPlugin?.createNotificationChannel(channel);

    // ✅ Android 13+ 알림 권한 요청 (핵심)
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> showFeedPush() async {
    await _plugin.show(
      1,
      '새 피드가 올라왔어요 🔥',
      '지금 확인하고 놓치지 마세요',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'feed_channel',
          'Feed Notification',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      payload: jsonEncode({'tab': 4}),
    );
  }
}
