import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_review/in_app_review.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class BadgesScreen extends StatefulWidget {
  const BadgesScreen({super.key});

  @override
  State<BadgesScreen> createState() => _BadgesScreenState();
}

class _BadgesScreenState extends State<BadgesScreen> {
  final InAppReview _inAppReview = InAppReview.instance;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // স্ক্রিন সম্পূর্ণ রেন্ডার হওয়ার পর পপআপ ট্রিগার করার লজিক
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestReview();
    });
  }

  void _checkAndRequestReview() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final int longestStreak = provider.appUser?.longestStreak ?? 0;
    final int currentStreak = provider.currentStreak;
    
    // সর্বোচ্চ স্ট্রিক কাউন্ট নির্ধারণ
    final int effectiveStreak = currentStreak > longestStreak ? currentStreak : longestStreak;

    // ৪টি নির্দিষ্ট মাইলফলক ব্যাচ: Noob (1), Average (7), Sigma (30), Giga Chad (120)
    bool targetAchieved = false;

    if (effectiveStreak == 1 ||      
        effectiveStreak == 7 ||      
        effectiveStreak == 30 ||     
        effectiveStreak == 120) {    
      targetAchieved = true;
    }

    // নির্দিষ্ট দিন পূর্ণ হলে অফিশিয়াল ইন-অ্যাপ রিভিউ ডায়ালগ প্রদর্শন
    if (targetAchieved) {
      if (await _inAppReview.isAvailable()) {
        _inAppReview.requestReview();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final badges = provider.getAllBadges();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Collect All the Badges!'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final badge = badges[index];
          final String badgeName = badge['name'];
          final int requiredDays = badge['days'] as int;

          final int longestStreak = provider.appUser?.longestStreak ?? 0;
          final bool achieved = (provider.currentStreak >= requiredDays) ||
              (longestStreak >= requiredDays);

          return Card(
            color: achieved
                ? Colors.amber.withValues(alpha: 0.15)
                : (isDark ? Colors.grey[900] : Colors.grey[200]),
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: achieved ? Colors.amber : Colors.grey.withValues(alpha: 0.3),
                width: achieved ? 1.5 : 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: achieved
                          ? Colors.amber.withValues(alpha: 0.1)
                          : Colors.grey.withValues(alpha: 0.1),
                      border: Border.all(
                        color: achieved ? Colors.amber : Colors.grey,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      provider.getBadgeImagePath(badgeName),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          achieved ? Icons.emoji_events : Icons.lock,
                          color: achieved ? Colors.amber : Colors.grey,
                          size: 30,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          badgeName,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: achieved
                                ? Colors.amber
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$requiredDays+ Days',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  achieved
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                      : Icon(Icons.radio_button_unchecked, color: Colors.grey[400], size: 28),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        backgroundColor: isDark ? Colors.black : Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: isDark ? Colors.white70 : Colors.black54,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
          } else if (index == 2) {
            // Already here
          } else if (index == 3) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Badges'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}