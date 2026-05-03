import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
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

  User? get currentUser => _currentUser;
  AppUser? get appUser => _appUser;
  List<Relapse> get relapses => _relapses;
  int get currentStreak => _currentStreak;
  String get formattedTime => _formattedTime;

  bool get isTimerRunning => _appUser != null && _appUser!.lastRelapse == null;

  AppProvider() {
    _auth.user.listen((user) {
      _currentUser = user;
      if (user != null) {
        _loadUserData(user.uid);
        _loadRelapses(user.uid);
      } else {
        _appUser = null;
        _relapses = [];
        _currentStreak = 0;
        _formattedTime = '00:00:00';
        _stopTimer();
      }
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

  Future<void> _loadUserData(String uid) async {
    _appUser = await _firestore.getUser(uid);
    if (_appUser == null) {
      _appUser = AppUser(
        uid: uid,
        email: _currentUser!.email!,
        createdAt: DateTime.now(),
      );
      await _firestore.saveUser(_appUser!);
    }

    // ✅ নাল-সেফ ব্যাজ চেক
    final String badge = _appUser!.currentBadge ?? 'Clown';
    final String finalBadge = badge.isEmpty ? 'Clown' : badge;
    NotificationService.checkBadgeUpgrade(finalBadge);

    if (_appUser!.lastRelapse != null) {
      _currentStreak = 0;
      _formattedTime = '00:00:00';
      _stopTimer();
    } else {
      _updateStreakAndTime();
      _startTimer();
    }
    notifyListeners();
  }

  Future<void> _loadRelapses(String uid) async {
    _firestore.getUserRelapses(uid).listen((list) {
      _relapses = list;
      notifyListeners();
    });
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
    _currentStreak = diff.inDays;
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

    NotificationService.startPeriodicInspiration(streak: _currentStreak);

    await _loadUserData(_currentUser!.uid);
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

    NotificationService.stopPeriodicInspiration();

    _stopTimer();
    _appUser = _appUser!.copyWith(lastRelapse: relapse.timestamp);
    _currentStreak = 0;
    _formattedTime = '00:00:00';
    notifyListeners();

    await _loadUserData(_currentUser!.uid);
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
      case 'Clown':
        return 'assets/badges/clown.png';
      case 'Noob':
        return 'assets/badges/noob.png';
      case 'Novice':
        return 'assets/badges/novice.png';
      case 'Average':
        return 'assets/badges/average.png';
      case 'Advanced':
        return 'assets/badges/advanced.png';
      case 'Sigma':
        return 'assets/badges/sigma.png';
      case 'Chad':
        return 'assets/badges/chad.png';
      case 'Absolute Chad':
        return 'assets/badges/absolute_chad.png';
      case 'Giga Chad':
        return 'assets/badges/giga_chad.png';
      default:
        return 'assets/badges/clown.png';
    }
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}