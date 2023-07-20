import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_main/types/postMessage.dart';
// import 'package:flutter_main/utils/console.dart';

/// 通知封装
/// author Shendi
class Notification {
  Function(NotificationResponseType type, String? payload)? localNotificationCallH5;
  final FlutterLocalNotificationsPlugin np = FlutterLocalNotificationsPlugin();

  /// 是否初始化了
  var isInit = false;

  /// 初始化
  Future init() async {
    if (isInit) return;
    isInit = true;
    const iOS = DarwinInitializationSettings();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');

    await np.initialize(
      const InitializationSettings(android: android, iOS: iOS),
      onDidReceiveNotificationResponse: (NotificationResponse res) {
        if (localNotificationCallH5 != null) localNotificationCallH5!(res.notificationResponseType, res.payload);
        // switch (notificationResponse.notificationResponseType) {
        //   case NotificationResponseType.selectedNotification:
        //     console.log('NotificationResponseType.selectedNotification:被点击了${notificationResponse.payload}');
        //     break;
        //   case NotificationResponseType.selectedNotificationAction:
        //     console.log('NotificationResponseType.selectedNotificationAction:被点击了');
        //     break;
        // }
      },
    );
  }

  Future send(LocalNotificationParams params, Function(NotificationResponseType type, String? payload)? callH5,
      {int? id}) async {
    localNotificationCallH5 ??= callH5;

    // 初始化
    await init();

    // 构建描述
    const androidDetails =
        AndroidNotificationDetails('id描述', '名称描述', importance: Importance.max, priority: Priority.high);
    const details = NotificationDetails(android: androidDetails);

    // 显示通知, 第一个参数是id,id如果一致则会覆盖之前的通知
    np.show(
      id ?? DateTime.now().millisecondsSinceEpoch >> 10,
      params.title,
      params.body,
      details,
      payload: params.payload,
    );
  }
}

final notification = Notification();
