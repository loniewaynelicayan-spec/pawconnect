import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _requestPermissions();
    _initialized = true;
  }

  static void _onNotificationTap(NotificationResponse response) {
    handleNotificationTap(response.payload);
  }

  static Future<void> _requestPermissions() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }

    final ios = _notifications.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      await ios.requestPermissions(sound: true, alert: true, badge: true);
    }
  }

  static Future<void> showAdoptionNotification({
    required String petName,
    required String adopterName,
  }) async {
    if (!_initialized) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'adoption_channel',
          'Adoption Requests',
          channelDescription: 'Notifications for pet adoption requests',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'Adoption Request!',
      '$adopterName wants to adopt $petName',
      platformDetails,
      payload: 'adoption_request',
    );
  }

  static Future<void> showMessageNotification({
    required String senderName,
    required String message,
  }) async {
    if (!_initialized) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'message_channel',
          'New Message',
          channelDescription: 'Notifications for new messages',
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'New Message from $senderName',
      message,
      platformDetails,
      payload: 'new_message',
    );
  }

  static void handleNotificationTap(String? payload) {
    if (payload == null) return;

    switch (payload) {
      case 'adoption_request':
        debugPrint('Navigate to adoption requests');
        break;
      case 'new_message':
        debugPrint('Navigate to messages');
        break;
      default:
        debugPrint('Unknown notification payload: $payload');
    }
  }
}
