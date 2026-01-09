import 'package:flutter/material.dart';
import 'package:piggy_log/core/widget/navigation/main_navigation.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _controller = PageController();
  int _currentPage = 0;

  // 🐷 Animation controller for the bouncing piggy
  late AnimationController _bounceController;

  @override
  void initState() {
    super.initState();
    //  Bounce animation: 800ms loop, up and down
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<String> backgroundImages = [
      'images/onboarding_1.png',
      'images/onboarding_2.png',
      'images/onboarding_3.png',
    ];

    final List<String> messages = [
      l10n.onboarding_cat_msg,
      l10n.onboarding_chart_msg,
      l10n.onboarding_setting_msg,
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (idx) => setState(() => _currentPage = idx),
            itemCount: backgroundImages.length,
            itemBuilder: (context, index) {
              return Opacity(
                opacity: 0.6,
                child: Image.asset(
                  backgroundImages[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              );
            },
          ),

          // Bouncing Piggy & Speech Bubble Layer
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 160),
              child: AnimatedBuilder(
                animation: _bounceController,
                builder: (context, child) {
                  return Transform.translate(
                    // Bouncing effect calculation
                    offset: Offset(0, -15 * _bounceController.value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSpeechBubble(messages[_currentPage]),
                        const SizedBox(height: 15),
                        Image.asset(
                          'images/pig_happy.png',
                          height: 100,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.pest_control_rodent,
                                color: Colors.pink,
                                size: 80,
                              ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom UI (Indicators & Button)
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: _buildFooter(backgroundImages.length),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeechBubble(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            // Modern color handling
            color: Colors.pinkAccent.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 1.4,
          color: Colors.black87,
        ),
      ),
    );
  }

  // Navigation Footer
  Widget _buildFooter(int totalSteps) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            totalSteps,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? Colors.white : Colors.white24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 25),
        // Action Button
        GestureDetector(
          onTap: () async {
            if (_currentPage < totalSteps - 1) {
              _controller.nextPage(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
              );
            } else {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isFirstRun', false);

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainNavigation(),
                  ),
                  (route) => false,
                );
              }
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              _currentPage == totalSteps - 1 ? "START! 🐷" : "NEXT",
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
