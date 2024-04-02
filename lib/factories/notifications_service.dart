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

  void scheduleNotification(String title, Duration fromNowTo, String? message) async {
    final id = _uuid.v1();
    const androidNotificationDetails = AndroidNotificationDetails(channelId, channelName,
        priority: Priority.max, importance: Importance.max);
    const notificationDetails = NotificationDetails(android: androidNotificationDetails);
    await _notifications.zonedSchedule(
      id.hashCode,
      title,
      message,
      tz.TZDateTime.now(tz.local).add(fromNowTo),
      notificationDetails,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
