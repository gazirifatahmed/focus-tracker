import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final badges = provider.getAllBadges();
    final currentBadgeName = provider.appUser?.currentBadge ?? 'Clown';
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
          final bool isCurrentBadge = (badgeName == currentBadgeName);

          return Card(
            color: isCurrentBadge
                ? Colors.amber.withOpacity(0.15)
                : (isDark ? Colors.grey[900] : Colors.grey[200]),
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: isCurrentBadge ? Colors.amber : Colors.grey.withOpacity(0.3),
                width: isCurrentBadge ? 1.5 : 0.5,
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
                      color: isCurrentBadge
                          ? Colors.amber.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      border: Border.all(
                        color: isCurrentBadge ? Colors.amber : Colors.grey,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      provider.getBadgeImagePath(badgeName),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          isCurrentBadge ? Icons.emoji_events : Icons.lock,
                          color: isCurrentBadge ? Colors.amber : Colors.grey,
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
                            color: isCurrentBadge
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
                  isCurrentBadge
                      ? const Icon(Icons.check_circle, color: Colors.green, size: 28)
                      : Icon(Icons.radio_button_unchecked, color: Colors.grey[400], size: 28),
                ],
              ),
            ),
          );
        },
      ),
      // ✅ নিচের নেভিগেশন বার
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (index == 1) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
          } else if (index == 2) {
            // এই পেজেই আছি
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