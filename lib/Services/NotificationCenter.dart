import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:goalkeeper/Models/Goal.dart';
import 'package:goalkeeper/Services/Interfaces/IRepository.dart';

class NotificationCenter {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();

  final IRepository repository;

  NotificationCenter({@required this.repository}) {
    var initNotificationSettings = getInitSettings();
    flutterLocalNotificationsPlugin.initialize(initNotificationSettings,
        onSelectNotification: defaultCallBack);
  }

  Future<bool> defaultCallBack(String goalId) {
    if (goalId != null) {
      Goal goal = repository.find(int.parse(goalId));
      // still need to figure how to go to EditPage from here !
      print('got this notification: $goal');
    }
    // just to shut the linter up since onSelectNotification expect "Future<dynamic> Function(String)"...
    return Future.value(true);
  }

  InitializationSettings getInitSettings() {
    return InitializationSettings(
        getAndroidInitSettings(), getIosInitSettings());
  }

  AndroidInitializationSettings getAndroidInitSettings() {
    return AndroidInitializationSettings('@mipmap/ic_launcher');
  }

  IOSInitializationSettings getIosInitSettings() {
    return IOSInitializationSettings();
  }

  void scheduleNotification(Goal goal) async {
    if (goal.deadLine == null) return;

    var platformChannelSpecifics = getNotificationDetails();
    await flutterLocalNotificationsPlugin.schedule(
        goal.id, goal.title, goal.body, goal.deadLine, platformChannelSpecifics,
        payload: goal.id.toString());
  }

  NotificationDetails getNotificationDetails() {
    return NotificationDetails(
        getAndroidNotificationDetails(), getIOSNotificationDetails());
  }

  AndroidNotificationDetails getAndroidNotificationDetails() {
    return AndroidNotificationDetails("goalNotificationChannelId",
        "Goal Deadlines", "Reminders to complete your goals in time",
        importance: Importance.Max,
        priority: Priority.High,
        ticker: 'ticker',
        icon: '@mipmap/ic_launcher',
        largeIcon: '@mipmap/ic_launcher',
        largeIconBitmapSource: BitmapSource.Drawable);
  }

  IOSNotificationDetails getIOSNotificationDetails() {
    return IOSNotificationDetails();
  }

  Future<bool> goalHasNotification(Goal goal) async {
    var pendingNotifications =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    return pendingNotifications
        .any((notification) => notification.id == goal.id);
  }

  void updateGoalNotification(Goal goal) async {
    var hasNotification = await goalHasNotification(goal);
    if (hasNotification) {
      flutterLocalNotificationsPlugin.cancel(goal.id);
    }
    // if there is notification then update, and insert it anyway
    scheduleNotification(goal);
  }
}
