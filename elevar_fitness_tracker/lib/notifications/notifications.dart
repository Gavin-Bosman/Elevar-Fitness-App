import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notifications {
  final channelID = "testNotif";
  final channelName = "Test Notification";
  final channelDescription = "Test Notification Description";

  //Configure plugin using platform specific details
  var _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  NotificationDetails? _platformChannelInfo;
  var _notificationID = 100;

  init() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
    var androidChannelInfo = AndroidNotificationDetails(channelID, channelName,
        channelDescription: channelDescription);

    _platformChannelInfo = NotificationDetails(android: androidChannelInfo);
  }

  void sendNotification(String title, String body, String payload) {
    print(_flutterLocalNotificationsPlugin.toString());

    _flutterLocalNotificationsPlugin.show(
        _notificationID++, title, body, _platformChannelInfo,
        payload: payload);
  }

  Future onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    if (notificationResponse != null) {
      print("NotificationResponse::payload = "
          "${notificationResponse.payload}");
    }
  }
}