import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import 'add_relapse_screen.dart';
import 'history_screen.dart';
import 'badges_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> _quotes = [
    "Every day is a new beginning.",
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
    "Believe in yourself and all that you are.",
    "The struggle you're in today is developing the strength you need for tomorrow.",
    "It always seems impossible until it's done.",
    "Don't stop when you're tired. Stop when you're done.",
    "Success is the sum of small efforts repeated day in and day out.",
  ];

  late Timer _quoteTimer;
  String _currentQuote = "Stay strong, you're in control.";

  @override
  void initState() {
    super.initState();
    _startQuoteRotation();
  }

  void _startQuoteRotation() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          final randomIndex = DateTime.now().millisecondsSinceEpoch % _quotes.length;
          _currentQuote = _quotes[randomIndex];
        });
      }
    });
  }

  @override
  void dispose() {
    _quoteTimer.cancel();
    super.dispose();
  }

  Future<void> _showStartTimerDialog(BuildContext context) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start timer from?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.play_arrow,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  title: Text(
                    'Now',
                    style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await provider.resetTimer();
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isActive = provider.isTimerRunning;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentBadge = provider.appUser?.currentBadge ?? 'Clown';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'NO FAP!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 22,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(!themeProvider.isDarkMode),
            tooltip: themeProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
          ),
          IconButton(
            icon: Icon(Icons.settings, color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          TextButton.icon(
            onPressed: () => provider.signOut(),
            icon: Icon(Icons.logout, color: isDark ? Colors.white70 : Colors.black54),
            label: Text(
              'Logout',
              style: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ✅ অ্যানিমেটেড ব্যাকগ্রাউন্ড
          AnimatedBackground(isDark: isDark),
          // মূল কন্টেন্ট
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ব্যাজ কার্ড
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E).withOpacity(0.9) : Colors.grey[100]!.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.amber.withOpacity(0.1),
                          border: Border.all(color: Colors.amber.withOpacity(0.3), width: 1),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          provider.getBadgeImagePath(currentBadge),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 40,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        currentBadge,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber,
                          shadows: [Shadow(color: Colors.orangeAccent, blurRadius: 10)],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Current Badge',
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _currentQuote,
                    key: ValueKey(_currentQuote),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '${provider.currentStreak}',
                  style: TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.0,
                  ),
                ),
                Text(
                  'Days',
                  style: TextStyle(fontSize: 20, color: isDark ? Colors.white54 : Colors.black54),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.grey[900] : Colors.grey[200])!.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
                    ),
                  ),
                  child: Text(
                    provider.formattedTime,
                    style: TextStyle(
                      fontSize: 28,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: !isActive
                      ? _buildGetFocusButton(context)
                      : _buildSlippedUpButton(context),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen()));
          } else if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const BadgesScreen()));
          } else if (index == 3) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
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

  // ✅ প্রিমিয়াম অ্যানিমেটেড "Get Focus" বাটন
  Widget _buildGetFocusButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.02),
      duration: const Duration(milliseconds: 1200),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.blueAccent, Colors.purpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.purpleAccent.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () => _showStartTimerDialog(context),
                borderRadius: BorderRadius.circular(30),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Get Focus',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ✅ প্রিমিয়াম অ্যানিমেটেড "I Slipped Up" বাটন
  Widget _buildSlippedUpButton(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 1.02),
      duration: const Duration(milliseconds: 1200),
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade800, Colors.redAccent.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.red.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(30),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddRelapseScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                splashColor: Colors.white.withOpacity(0.2),
                highlightColor: Colors.white.withOpacity(0.1),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'I Slipped Up',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ✅ ব্যাকগ্রাউন্ড অ্যানিমেশন উইজেট
class AnimatedBackground extends StatefulWidget {
  final bool isDark;
  const AnimatedBackground({super.key, required this.isDark});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(
                (_controller.value * 0.4) - 0.2,
                (_controller.value * 0.4) - 0.2,
              ),
              radius: 1.5,
              colors: widget.isDark
                  ? [
                      const Color(0xFF0D1117),
                      const Color(0xFF161B22),
                      Colors.blueAccent.withOpacity(0.05),
                      Colors.purpleAccent.withOpacity(0.03),
                    ]
                  : [
                      Colors.white,
                      const Color(0xFFF5F5F5),
                      Colors.blueAccent.withOpacity(0.03),
                      Colors.purpleAccent.withOpacity(0.02),
                    ],
              stops: const [0.0, 0.5, 0.8, 1.0],
            ),
          ),
        );
      },
    );
  }
}