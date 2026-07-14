import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../providers/theme_provider.dart';
import '../services/sound_service.dart';
import 'add_relapse_screen.dart';
import 'history_screen.dart';
import 'badges_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
  StreamSubscription<String>? _ratingSubscription; // যুক্ত করা হয়েছে

  late AnimationController _badgePulseController;
  late Animation<double> _badgePulseAnim;
  late AnimationController _badgeGlowController;
  late Animation<double> _badgeGlowAnim;

  late AnimationController _timerPulseController;
  late Animation<double> _timerPulseAnim;
  late AnimationController _dayBreathController;
  late Animation<double> _dayGlowAnim;
  late final List<Particle> _particles;
  late final AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _startQuoteRotation();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundService.playWelcomeSound();
      
      // ব্যাচ অর্জনের রেটিং পপ-আপ স্ট্রিম লিসেন করা হচ্ছে
      final provider = Provider.of<AppProvider>(context, listen: false);
      _ratingSubscription = provider.ratingTriggerStream.listen((badgeName) {
        _showRatingDialog(context, badgeName);
      });
    });

    _badgePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _badgePulseAnim = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _badgePulseController, curve: Curves.easeInOut),
    );

    _badgeGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _badgeGlowAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _badgeGlowController, curve: Curves.easeInOut),
    );

    _timerPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _timerPulseAnim = Tween<double>(begin: 1.0, end: 1.015).animate(
      CurvedAnimation(parent: _timerPulseController, curve: Curves.easeInOut),
    );

    _dayBreathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _dayGlowAnim = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _dayBreathController, curve: Curves.easeInOut),
    );

    _particles = List.generate(30, (index) => Particle.random());
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  void _startQuoteRotation() {
    _quoteTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          final randomIndex =
              DateTime.now().millisecondsSinceEpoch % _quotes.length;
          _currentQuote = _quotes[randomIndex];
        });
      }
    });
  }

  // কাঙ্ক্ষিত রেটিং ডায়ালগ পপ-আপ ফাংশন
  void _showRatingDialog(BuildContext context, String badgeName) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 28),
            const SizedBox(width: 10),
            Expanded(child: Text('Congratulations! 🎉\nYou are a $badgeName!')),
          ],
        ),
        content: const Text(
          'You have achieved a new badge! If you love using this app, please take a moment to rate us.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // এখানে আপনার ইন-অ্যাপ রিভিউ বা স্টোর ওপেন করার লজিক দিতে পারেন
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Rate Now', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _quoteTimer.cancel();
    _ratingSubscription?.cancel(); // সাবস্ক্রিপশন ক্যানসেল করা হয়েছে
    _badgePulseController.dispose();
    _badgeGlowController.dispose();
    _timerPulseController.dispose();
    _dayBreathController.dispose();
    _particleController.dispose();
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
                    style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87),
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
    final currentBadge = provider.liveBadge;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'FOCUS!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            fontSize: 20,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () =>
                themeProvider.toggleTheme(!themeProvider.isDarkMode),
            tooltip: themeProvider.isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          ),
          IconButton(
            icon: Icon(Icons.settings,
                color: isDark ? Colors.white70 : Colors.black54),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
          TextButton.icon(
            onPressed: () => provider.signOut(),
            icon: Icon(Icons.logout,
                color: isDark ? Colors.white70 : Colors.black54),
            label: Text(
              'Logout',
              style:
                  TextStyle(color: isDark ? Colors.white70 : Colors.black54),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBackground(isDark: isDark),
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              _updateParticles();
              return CustomPaint(
                painter: ParticlePainter(_particles, isDark),
                size: Size.infinite,
              );
            },
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    AnimatedBuilder(
                      animation: _badgeGlowAnim,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 20),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E1E1E).withValues(alpha: 0.95)
                                : const Color(0xFFFFF9E6),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark
                                  ? Colors.amber.withValues(alpha: 0.6)
                                  : Colors.amber.shade800.withValues(alpha: 0.7),
                              width: 1.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.amber.withValues(alpha: 0.2)
                                    : Colors.amber.shade200.withValues(alpha: 0.8),
                                blurRadius: 16,
                                spreadRadius: 1,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withValues(alpha: 0.3)
                                    : Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: child,
                        );
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: _badgePulseAnim,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.amber.withValues(alpha: 0.12),
                                border: Border.all(
                                    color: Colors.amber.withValues(alpha: 0.5),
                                    width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Image.asset(
                                provider.getBadgeImagePath(currentBadge),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber,
                                    size: 56,
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentBadge,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.amber.shade300 : Colors.amber.shade800,
                              shadows: [
                                Shadow(
                                    color: isDark ? Colors.orangeAccent : Colors.amber.shade200,
                                    blurRadius: 8,
                                    offset: const Offset(1, 1))
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Current Badge',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Text(
                        _currentQuote,
                        key: ValueKey(_currentQuote),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AnimatedBuilder(
                      animation: _dayGlowAnim,
                      builder: (context, child) {
                        return Column(
                          children: [
                            Text(
                              '${provider.currentStreak}',
                              style: TextStyle(
                                fontSize: 85,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : Colors.black87,
                                height: 1.0,
                                letterSpacing: 2,
                                shadows: [
                                  Shadow(
                                    blurRadius: 15 + (10 * _dayGlowAnim.value),
                                    color: isDark
                                        ? Colors.white.withValues(alpha: _dayGlowAnim.value)
                                        : Colors.blueAccent.withValues(alpha: _dayGlowAnim.value * 0.8),
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'Days',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.5,
                                color: isDark ? Colors.white70 : Colors.black87,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ScaleTransition(
                      scale: _timerPulseAnim,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isDark
                                ? [
                                    Colors.white.withValues(alpha: 0.12),
                                    Colors.white.withValues(alpha: 0.03)
                                  ]
                                : [
                                    Colors.black.withValues(alpha: 0.08),
                                    Colors.black.withValues(alpha: 0.03)
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(40),
                          border: Border.all(
                            color: (isDark ? Colors.white : Colors.black)
                                .withValues(alpha: 0.20),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.blueAccent.withValues(alpha: 0.20)
                                  : Colors.black.withValues(alpha: 0.08),
                              blurRadius: 16,
                              spreadRadius: 1,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 28,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              provider.formattedTime,
                              style: TextStyle(
                                fontSize: 36,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: !isActive
                          ? _buildGetFocusButton(context)
                          : _buildSlippedUpButton(context),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: isDark ? Colors.white70 : Colors.black54,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()));
          } else if (index == 2) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BadgesScreen()));
          } else if (index == 3) {
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()));
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: 'Badges'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildGetFocusButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        key: const ValueKey('focus'),
        onPressed: () => _showStartTimerDialog(context),
        icon: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 24),
        label: const Text(
          'Get Focus',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: 1.1,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          elevation: 5,
          shadowColor: Colors.blueAccent.withValues(alpha: 0.4),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
    );
  }

  Widget _buildSlippedUpButton(BuildContext context) {
    return Center(
      key: const ValueKey('slipped'),
      child: OutlinedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddRelapseScreen()),
          );
        },
        icon: const Icon(
          Icons.sentiment_dissatisfied_rounded,
          color: Colors.redAccent,
          size: 20,
        ),
        label: const Text(
          'I Slipped Up',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.redAccent,
            letterSpacing: 0.7,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.redAccent,
          side: const BorderSide(color: Colors.redAccent, width: 1.6),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
        ),
      ),
    );
  }

  void _updateParticles() {
    for (var p in _particles) {
      p.update(MediaQuery.of(context).size);
    }
  }
}

// Particle এবং ParticlePainter ক্লাস অপরিবর্তিত রয়েছে...
class Particle {
  double x, y;
  double radius;
  double speedX, speedY;
  double opacity;
  final Color color;

  Particle.random() : this._(Random());

  Particle._(Random r)
      : x = r.nextDouble(),
        y = r.nextDouble(),
        radius = 1 + r.nextDouble() * 3,
        speedX = (r.nextDouble() - 0.5) * 0.5,
        speedY = (r.nextDouble() - 0.5) * 0.5,
        opacity = 0.1 + r.nextDouble() * 0.4,
        color = Colors.white;

  void update(Size size) {
    x += speedX / size.width;
    y += speedY / size.height;
    if (x < 0) x = 1;
    if (x > 1) x = 0;
    if (y < 0) y = 1;
    if (y > 1) y = 0;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final bool isDark;

  ParticlePainter(this.particles, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var p in particles) {
      paint.color = isDark
          ? Colors.white.withValues(alpha: p.opacity * 0.6)
          : Colors.blueAccent.withValues(alpha: p.opacity * 0.4);
      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// মনে করে AnimatedBackground উইজেটটি আপনার ফাইলে অলরেডি ডিফাইন করা আছে ধরে নেওয়া হয়েছে।
class AnimatedBackground extends StatelessWidget {
  final bool isDark;
  const AnimatedBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF0F172A), const Color(0xFF020617)]
              : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
        ),
      ),
    );
  }
}