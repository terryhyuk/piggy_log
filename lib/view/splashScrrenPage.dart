import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'dart:async';
import 'package:lottie/lottie.dart';
import 'package:piggy_log/view/widget/mainTabBar.dart';

class SplashScreen extends StatefulWidget {

  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 3초 후에 홈화면으로 이동
    Timer(const Duration(seconds: 3), () {
      _navigateToHome(); // 홈화면으로 애니메이션 전환
    });
  }

  _navigateToHome() {
    Get.offAll(
    () => Maintabbar(),
    transition: Transition.fade,
    duration: const Duration(seconds: 1),
  );
    // Navigator.of(context).pushReplacement(
    //   PageRouteBuilder(
    //     pageBuilder: (context, animation, secondaryAnimation) =>
    //         Maintabbar(),
    //     transitionsBuilder:
    //         (context, animation, secondaryAnimation, child) {
    //       return FadeTransition(
    //         opacity: animation,
    //         child: child,
    //       );
    //     },
    //     transitionDuration: const Duration(seconds: 1),
    //   ),
    // );
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