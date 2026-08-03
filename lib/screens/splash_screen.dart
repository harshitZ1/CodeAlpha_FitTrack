import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'auth_gate.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  @override
void initState() {
  super.initState();

  _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );

  _fadeAnimation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );

  _controller.forward();

  Future.delayed(const Duration(seconds: 3), () {
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, animation, __) => const AuthGate(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  });
}

  @override
void dispose() {
  _controller.dispose();
  super.dispose();
}
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
  child: FadeTransition(
    opacity: _fadeAnimation,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 220,
          child: Lottie.asset(
            'assets/animations/gym_splash.json',
            repeat: false,
          ),
        ),

        const SizedBox(height: 25),

        const Text(
          "FitTrack",
          style: TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 10),

        const Text(
          "Train • Track • Transform",
          style: TextStyle(
            color: Colors.greenAccent,
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 35),

        const SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.greenAccent,
          ),
        ),
      ],
    ),
  ),
),
    );
  }
}