import 'package:final_project/main_layout.dart';
import 'package:final_project/models/appointment.dart';
import 'package:final_project/utils/app_router.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/standalone.dart';
import 'package:timezone/timezone.dart' as tz;

class LocalNotification {
  LocalNotification._();
  static LocalNotification localNotification = LocalNotification._();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static onTap(NotificationResponse response) {
    if (response.payload != null) {
      // Use a navigator key or other method to handle navigation
      AppRouter.navigateToWidgetWithReplacment(MainLayout());
    }
  }

  Future init() async {
    InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
      iOS: DarwinInitializationSettings(),
    );

    flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveBackgroundNotificationResponse: onTap,
      onDidReceiveNotificationResponse: onTap,
    );
  }

  void showScheduledNotification(TZDateTime appointmentTime) async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
    NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        "appointment_reminders",
        "Appointment Reminders",
        importance: Importance.max,
        priority: Priority.max,
        channelDescription: "Notifications for upcoming appointments",
      ),
    );

    String formattedTime = DateFormat('h:mm a').format(appointmentTime);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      appointmentTime.millisecondsSinceEpoch ~/ 1000,
      "Appointment Reminder",
      "You have an appointment tomorrow at $formattedTime",
      appointmentTime,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  void getRightTime(AppointmentModel appointment) async {
    tz.initializeTimeZones();

    final cairo = tz.getLocation('Africa/Cairo');
    tz.setLocalLocation(cairo);

    final now = tz.TZDateTime.now(cairo);

    final appointmentDateTime = DateFormat(
      'M/dd/yyyy HH:mm',
    ).parse("${appointment.date} ${appointment.time}");

    final appointmentReminder = appointmentDateTime.subtract(Duration(days: 1));
    final formatedAppointmentReminder = tz.TZDateTime.from(
      appointmentReminder,
      cairo,
    );

    if (formatedAppointmentReminder.day == now.day) {
      if (formatedAppointmentReminder.isAfter(now)) {
        showScheduledNotification(formatedAppointmentReminder);
      }
    }
  }
}
