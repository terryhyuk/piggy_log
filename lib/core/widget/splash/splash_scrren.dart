// [splash_screen.dart] 🐷
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:piggy_log/screens/onbording/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:piggy_log/core/widget/navigation/main_navigation.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      _checkFirstRun(); 
    });
  }

  Future<void> _checkFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    // 'isFirstRun'이 null이면(처음이면) true를 기본값으로 사용
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      _navigateToNext(const OnboardingScreen()); 
    } else {
      _navigateToNext(const MainNavigation());
    }
  }

  void _navigateToNext(Widget nextScreen) {
    if (!mounted) return;
    
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(seconds: 1),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'images/original_ https_lottiefiles.com24811-saving-money.json',
          width: MediaQuery.of(context).size.width,
          height: 400,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}