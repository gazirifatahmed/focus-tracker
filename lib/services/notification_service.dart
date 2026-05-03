import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static Timer? _periodicTimer;
  static int _currentStreak = 0;
  static String _lastBadge = 'Clown';

  static const List<String> _quotes = [
    "Stay strong, you're in control.",
    "Discipline is the bridge between goals and accomplishment.",
    "The pain of discipline is far less than the pain of regret.",
    "Your future self will thank you.",
    "Don't count the days, make the days count.",
    "Small progress is still progress.",
    "You are stronger than you think.",
    "Focus on the step in front of you.",
    "The best view comes after the hardest climb.",
    "Self-control is strength. Right thought is mastery.",
    "Be the master of your own destiny.",
    "It's not about perfect, it's about effort.",
    "One day or day one. You decide.",
    "Your only limit is you.",
    "Prove yourself to yourself, not others.",
    "Strength grows in the moments you think you can't go on.",
    "You didn't come this far to only come this far.",
    "The secret of change is to focus all your energy on building the new.",
    "Difficult roads often lead to beautiful destinations.",
  ];

  static Future<void> init() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'focus_channel',
      'Focus Tracker',
      channelDescription: 'Motivational reminders',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }

  static void startPeriodicInspiration({int streak = 0}) {
    _currentStreak = streak;
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      final randomIndex = DateTime.now().millisecond % _quotes.length;
      final quote = _quotes[randomIndex];
      showNotification(
        title: '🔥 Stay Focused!',
        body: '$quote\nCurrent streak: $_currentStreak days',
      );
    });
    Future.delayed(const Duration(seconds: 5), () {
      final randomIndex = DateTime.now().millisecond % _quotes.length;
      showNotification(
        title: '🚀 Challenge Started!',
        body: _quotes[randomIndex],
      );
    });
  }

  static void stopPeriodicInspiration() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  static void updateStreak(int streak) {
    _currentStreak = streak;
  }

  static void checkBadgeUpgrade(String newBadge) {
    if (newBadge != _lastBadge && _lastBadge != 'Clown') {
      showNotification(
        title: '🎉 Congratulations!',
        body: 'You have reached the $newBadge badge! Keep going!',
      );
    }
    _lastBadge = newBadge;
  }

  static void reset() {
    _periodicTimer?.cancel();
    _lastBadge = 'Clown';
    _currentStreak = 0;
  }
}