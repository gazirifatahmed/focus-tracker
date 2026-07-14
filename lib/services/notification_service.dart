import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// 👈 অ্যাপ যখন মেমোরি থেকে বন্ধ (Terminated/Background) থাকে, তখন এটি নোটিফিকেশন রিসিভ করে
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("🍂 [FCM Background] Message ID: ${message.messageId}");
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  
  // 👈 ফায়ারবেস মেসেজিং অবজেক্ট
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static String _currentBadge = 'Clown';
  static int _currentStreak = 0;

  static const List<String> _reminderMessages = [
    "🔥 Stay strong! You've got this.",
    "💪 One day at a time. Keep going!",
    "🎯 Focus on your goal. You're doing great!",
    "🌟 Every day without relapse is a victory.",
    "📈 Your streak is growing. Don't stop now!",
    "🧠 You are in control. Keep building discipline.",
    "🏆 Remember why you started. Stay focused!",
  ];

  static Future<void> init() async {
    // রিমাইন্ডারের জন্য আলাদা চ্যানেল – কাস্টম সাউন্ড সহ
    const AndroidNotificationChannel reminderChannel = AndroidNotificationChannel(
      'reminder_channel',
      'Daily Reminders',
      description: 'Get daily motivational reminders',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('reminder_sound'),
    );

    const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
      'focus_channel',
      'Focus Tracker',
      description: 'Motivational reminders & badge updates',
      importance: Importance.high,
      playSound: true,
    );

    await _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(reminderChannel);
    await _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(generalChannel);

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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

    // 👈 ফায়ারবেস লিসেনারগুলো চালু করার কল
    await setupFirebaseMessaging();
  }

  // 👈 ফায়ারবেস পুশ নোটিফিকেশন কনফিগারেশন মেথড
  static Future<void> setupFirebaseMessaging() async {
    // ১. নোটিফিকেশন পারমিশন রিকোয়েস্ট (বিশেষ করে Android 13+)
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('🔔 [FCM] User granted permission: ${settings.authorizationStatus}');

    // ২. টোকেন প্রিন্ট করা (এটি দিয়ে আপনি ফায়ারবেস কনসোল থেকে টেস্ট নোটিফিকেশন পাঠাতে পারবেন)
    String? token = await _firebaseMessaging.getToken();
    print("🔑 [FCM Token] $token");

    // ৩. অ্যাপ স্ক্রিনে ওপেন থাকা অবস্থায় (Foreground) নোটিফিকেশন হ্যান্ডেল করা
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('🍏 [FCM Foreground] Got a message: ${message.notification?.title}');
      
      if (message.notification != null) {
        // ফায়ারবেস থেকে আসা মেসেজটিকে লোকাল নোটিফিকেশনে পুশ করা হচ্ছে
        showNotification(
          title: message.notification!.title ?? '',
          body: message.notification!.body ?? '',
          channelId: 'focus_channel',
        );
      }
    });

    // ৪. ব্যাকগ্রাউন্ড হ্যান্ডেলার রেজিস্ট্রেশন
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    int? id,
    String? channelId,
  }) async {
    final String usedChannel = channelId ?? 'focus_channel';
    final androidDetails = AndroidNotificationDetails(
      usedChannel,
      usedChannel == 'reminder_channel' ? 'Daily Reminders' : 'Focus Tracker',
      channelDescription: usedChannel == 'reminder_channel'
          ? 'Get daily motivational reminders'
          : 'Motivational reminders & badge updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails();
    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    await _plugin.show(
      id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
    );
  }

  static void updateStreakAndBadge(int streak, String newBadge) {
    _currentStreak = streak;
    if (newBadge != _currentBadge && _currentBadge != 'Clown') {
      showNotification(
        title: "🎉 Congratulations!",
        body: "You have reached the **$newBadge** badge! Keep going!",
        id: 888,
        channelId: 'focus_channel',
      );
    }
    _currentBadge = newBadge;
  }

  static Future<void> sendChallengeStartedNotification(int streak) async {
    _currentStreak = streak;
    await showNotification(
      title: "🚀 Challenge Started!",
      body: "Your focus journey begins now. Stay strong!",
      id: 100,
      channelId: 'focus_channel',
    );
  }

  static void reset() {
    _currentBadge = 'Clown';
    _currentStreak = 0;
  }
}