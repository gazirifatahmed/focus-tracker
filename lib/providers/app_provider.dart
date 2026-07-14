import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // এখন আর এরর দেখাবে না
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/sound_service.dart';      
import '../models/user_model.dart';
import '../models/relapse_model.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  User? _currentUser;
  AppUser? _appUser;
  List<Relapse> _relapses = [];
  int _currentStreak = 0;
  Timer? _timer;
  String _formattedTime = '00:00:00';
  String _previousBadge = 'Clown';
  bool _isLoading = true;

  // রেটিং পপ-আপ ট্রিগার করার জন্য স্ট্রিম কন্ট্রোলার
  final StreamController<String> _ratingTriggerController = StreamController<String>.broadcast();
  Stream<String> get ratingTriggerStream => _ratingTriggerController.stream;

  User? get currentUser => _currentUser;
  AppUser? get appUser => _appUser;
  List<Relapse> get relapses => _relapses;
  int get currentStreak => _currentStreak;
  String get formattedTime => _formattedTime;
  bool get isLoading => _isLoading;
  bool get isTimerRunning => _appUser != null && _appUser!.lastRelapse == null;

  String get liveBadge {
    final effectiveDays = _currentStreak;
    final longest = _appUser?.longestStreak ?? 0;
    final displayDays = effectiveDays > longest ? effectiveDays : longest;
    return getBadgeFromDays(displayDays);
  }

  AppProvider() {
    _auth.user.listen((user) async {
      _currentUser = user;
      if (user != null) {
        await _loadUserData(user.uid, email: user.email);
        await _loadRelapses(user.uid);
      } else {
        _appUser = null;
        _relapses = [];
        _currentStreak = 0;
        _formattedTime = '00:00:00';
        _stopTimer();
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateStreakAndTime();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _loadUserData(String uid, {String? email}) async {
    try {
      _appUser = await _firestore.getUser(uid);
      if (_appUser == null) {
        final tempUser = AppUser(
          uid: uid,
          email: email ?? _currentUser?.email ?? 'no-email@domain.com',
          createdAt: DateTime.now(),
          lastRelapse: DateTime.now(),
        );
        _appUser = tempUser;
        await _firestore.saveUser(tempUser);
      }

      final String badge = _appUser!.currentBadge ?? 'Clown';
      final String finalBadge = badge.isEmpty ? 'Clown' : badge;
      _previousBadge = finalBadge;

      if (_appUser!.lastRelapse != null) {
        _currentStreak = 0;
        _formattedTime = '00:00:00';
        _stopTimer();
      } else {
        _updateStreakAndTime();
        _startTimer();
        // অ্যাপ ওপেন করার সময়ও যেন চেক করে রেটিং ডায়ালগ দেখাতে পারে
        _checkAndTriggerRating(liveBadge);
      }
    } catch (e) {
      print("⚠️ Error loading user data: $e");
    }
  }

  Future<void> _loadRelapses(String uid) async {
    _firestore.getUserRelapses(uid).listen((list) {
      _relapses = list;
      notifyListeners();
    });
  }

  // ৩টি নির্দিষ্ট ব্যাচের জন্য রেটিং পপ-আপ ট্রিগার করার লজিক
  Future<void> _checkAndTriggerRating(String badgeName) async {
    if (badgeName == 'Noob' || badgeName == 'Average' || badgeName == 'Sigma') {
      final prefs = await SharedPreferences.getInstance();
      final key = 'has_shown_rating_for_$badgeName';
      final hasShown = prefs.getBool(key) ?? false;

      if (!hasShown) {
        await prefs.setBool(key, true);
        _ratingTriggerController.add(badgeName);
      }
    }
  }

  void _updateStreakAndTime() {
    if (_appUser == null) {
      _currentStreak = 0;
      _formattedTime = '00:00:00';
      return;
    }
    final now = DateTime.now();
    final start = _appUser!.lastRelapse == null
        ? _appUser!.createdAt
        : _appUser!.lastRelapse!;
    final diff = now.difference(start);
    final newStreak = diff.inDays;
    if (newStreak != _currentStreak) {
      _currentStreak = newStreak;
      final newBadge = liveBadge;
      if (newBadge != _previousBadge) {
        SoundService.playCongratsSound();
        NotificationService.updateStreakAndBadge(_currentStreak, newBadge);
        _previousBadge = newBadge;
        // রিয়েল-টাইমে নতুন ব্যাচ অর্জন করার সাথে সাথে পপ-আপ চেক করবে
        _checkAndTriggerRating(newBadge);
      } else {
        NotificationService.updateStreakAndBadge(_currentStreak, _previousBadge);
      }
    }
    final hours = diff.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = diff.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = diff.inSeconds.remainder(60).toString().padLeft(2, '0');
    _formattedTime = '$hours:$minutes:$seconds';
    notifyListeners();
  }

  Future<void> resetTimer({DateTime? startDate}) async {
    if (_currentUser == null || _appUser == null) return;

    final newStart = startDate ?? DateTime.now();
    await _firestore.updateUserStartDate(_currentUser!.uid, newStart);

    _appUser = _appUser!.copyWith(
      createdAt: newStart,
      lastRelapse: null,
    );

    _currentStreak = 0;
    _formattedTime = '00:00:00';
    _startTimer();
    notifyListeners();

    await NotificationService.sendChallengeStartedNotification(_currentStreak);
    _previousBadge = 'Clown';
    NotificationService.updateStreakAndBadge(_currentStreak, _previousBadge);

    // রিসেট হলে আগের ব্যাচগুলোর রেটিং ফ্ল্যাগ ক্লিয়ার করতে পারেন যাতে ভবিষ্যতে আবার সুযোগ পায়
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('has_shown_rating_for_Noob');
    await prefs.remove('has_shown_rating_for_Average');
    await prefs.remove('has_shown_rating_for_Sigma');

    await _loadUserData(_currentUser!.uid, email: _currentUser!.email);
  }

  Future<void> addRelapse(String reason) async {
    if (_currentUser == null || _appUser == null) return;

    final relapse = Relapse(
      id: '',
      userId: _currentUser!.uid,
      timestamp: DateTime.now(),
      reason: reason,
      daysAchieved: _currentStreak,
    );

    await _firestore.addRelapse(relapse);
    await _firestore.updateUserAfterRelapse(
      _currentUser!.uid,
      relapse.timestamp,
      _currentStreak,
    );

    _stopTimer();
    _appUser = _appUser!.copyWith(lastRelapse: relapse.timestamp);
    _currentStreak = 0;
    _formattedTime = '00:00:00';
    notifyListeners();

    await _loadUserData(_currentUser!.uid, email: _currentUser!.email);
  }

  Future<void> deleteRelapse(String relapseId) async {
    if (_currentUser == null) return;
    await _firestore.deleteRelapse(relapseId);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    NotificationService.reset();
  }

  String getBadgeFromDays(int days) {
    if (days >= 120) return 'Giga Chad';
    if (days >= 60) return 'Absolute Chad';
    if (days >= 45) return 'Chad';
    if (days >= 30) return 'Sigma';
    if (days >= 15) return 'Advanced';
    if (days >= 7) return 'Average';
    if (days >= 3) return 'Novice';
    if (days >= 1) return 'Noob';
    return 'Clown';
  }

  List<Map<String, dynamic>> getAllBadges() {
    return [
      {'name': 'Clown', 'days': 0},
      {'name': 'Noob', 'days': 1},
      {'name': 'Novice', 'days': 3},
      {'name': 'Average', 'days': 7},
      {'name': 'Advanced', 'days': 15},
      {'name': 'Sigma', 'days': 30},
      {'name': 'Chad', 'days': 45},
      {'name': 'Absolute Chad', 'days': 60},
      {'name': 'Giga Chad', 'days': 120},
    ];
  }

  String getBadgeImagePath(String badgeName) {
    switch (badgeName) {
      case 'Clown': return 'assets/badges/clown.png';
      case 'Noob': return 'assets/badges/noob.png';
      case 'Novice': return 'assets/badges/novice.png';
      case 'Average': return 'assets/badges/average.png';
      case 'Advanced': return 'assets/badges/advanced.png';
      case 'Sigma': return 'assets/badges/sigma.png';
      case 'Chad': return 'assets/badges/chad.png';
      case 'Absolute Chad': return 'assets/badges/absolute_chad.png';
      case 'Giga Chad': return 'assets/badges/giga_chad.png';
      default: return 'assets/badges/clown.png';
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _ratingTriggerController.close();
    super.dispose();
  }
}