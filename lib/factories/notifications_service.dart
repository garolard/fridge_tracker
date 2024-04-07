import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

const _uuid = Uuid();
final _notifications = FlutterLocalNotificationsPlugin();

const channelId = 'fridge_tracker_channel';
const channelName = 'Fridge Tracker';
const channelDescription = 'Notifications for Fridge Tracker';

class NotificationsService {
  static NotificationsService? _instance;
  NotificationsService._internal();

  factory NotificationsService() {
    _instance ??= NotificationsService._internal();
    return _instance!;
  }

  Future<bool> requestPermission() async {
    final result = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    return result ?? false;
  }

  void showNotification(String title, String? message) async {
    const androidNotificationDetails = AndroidNotificationDetails(channelId, channelName,
        priority: Priority.max, importance: Importance.max);
    const notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await _notifications.show(_uuid.v4().hashCode, title, message, notificationDetails);
  }

  void scheduleNotification(
      int id, String title, Duration fromNowTo, String? message, File? notificationImage) async {
    final notificationStyleInformation = notificationImage != null
        ? const MediaStyleInformation()
        : const DefaultStyleInformation(false, false);

    final androidNotificationDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      importance: Importance.max,
      largeIcon: notificationImage != null ? FilePathAndroidBitmap(notificationImage.path) : null,
      styleInformation: notificationStyleInformation,
    );
    final notificationDetails = NotificationDetails(android: androidNotificationDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      message,
      tz.TZDateTime.now(tz.local).add(fromNowTo),
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void cancelNotification(int id) {
    _notifications.cancel(id);
  }
}
