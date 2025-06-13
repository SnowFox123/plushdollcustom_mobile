import 'dart:convert';

import 'package:capstone_project_mobile_flutter/redux/app_state.dart';
import 'package:capstone_project_mobile_flutter/redux/auth_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Set status bar to transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // Initialize animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _logoAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation
    await _logoController.forward();

    // Start fade animation for text
    await _fadeController.forward();

    // Wait a bit more
    await Future.delayed(const Duration(milliseconds: 500));

    // Navigate to appropriate screen
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userInfoStr = prefs.getString('userInfo');

    // print('[SplashScreen] Token from SharedPreferences: $token');
    // print('[SplashScreen] UserInfo from SharedPreferences: $userInfoStr');

    if (token != null && userInfoStr != null) {
      final store = StoreProvider.of<AppState>(context);
      store.dispatch(SetTokenAction(token));
      store.dispatch(
        SetUserInfoAction(
          Map<String, dynamic>.from(await parseUserInfo(userInfoStr)),
        ),
      );
    }

    if (mounted) {
      print(
        '[SplashScreen] Navigating to: ${token != null && userInfoStr != null ? "HomeScreen" : "LoginScreen"}',
      );
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              (token != null && userInfoStr != null)
              ? const HomeScreen()
              : const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> parseUserInfo(String jsonString) async {
    try {
      return Future.value(
        Map<String, dynamic>.from(
          await Future.microtask(() => jsonDecode(jsonString)),
        ),
      );
    } catch (e) {
      return {};
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF2196F3), Color(0xFF1976D2), Color(0xFF0D47A1)],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo section
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo/icon
                    AnimatedBuilder(
                      animation: _logoAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _logoAnimation.value,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.work,
                              size: 60,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 30),

                    // App name
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: const Text(
                            'Freelance Hub',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // App tagline
                    AnimatedBuilder(
                      animation: _fadeAnimation,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _fadeAnimation,
                          child: const Text(
                            'Kết nối tài năng, tạo ra giá trị',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Loading section
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Loading indicator
                    const SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Loading text
                    const Text(
                      'Đang tải...',
                      style: TextStyle(fontSize: 14, color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
