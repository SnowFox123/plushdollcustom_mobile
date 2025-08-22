import 'dart:convert';

import 'package:PlushDollCustom/redux/app_state.dart';
import 'package:PlushDollCustom/redux/auth_actions.dart';
import 'package:PlushDollCustom/services/auth_service.dart';
import 'package:PlushDollCustom/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool rememberMe = false;
  bool loading = false;
  bool obscurePassword = true;

  late AnimationController _shakeController;
  late Animation<double> _usernameShake;
  late Animation<double> _passwordShake;

  Future<void> handleLogin() async {
    setState(() => loading = true);

    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    try {
      final result = await AuthService.login(username, password);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);
      await prefs.setString('userInfo', jsonEncode(result['userInfo']));

      final store = StoreProvider.of<AppState>(context, listen: false);
      store.dispatch(SetTokenAction(result['token']));
      store.dispatch(SetUserInfoAction(result['userInfo']));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void initState() {
    super.initState();

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    final shakeTween = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]);
    _usernameShake = shakeTween.animate(_shakeController);
    _passwordShake = shakeTween.animate(_shakeController);
  }

  void triggerShake() {
    _shakeController.forward(from: 0);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget _buildInput({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
    Animation<double>? shake,
  }) {
    return AnimatedBuilder(
      animation: shake ?? AlwaysStoppedAnimation(0),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(shake?.value ?? 0, 0),
          child: child,
        );
      },
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscure ? Icons.visibility_off : Icons.visibility,
                    color: Colors.blueAccent,
                  ),
                  onPressed: toggleObscure,
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Stack(
          children: [
            // Background GIF
            Column(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9, // Giữ tỷ lệ tương tự như video
                  child: Image.asset(
                    'assets/videos/bg-login.gif',
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),

            // Positioned form over background
            // Positioned container như phần bo góc phía dưới
            Positioned(
              top: screenHeight * 0.25,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 30,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Logo PlushDoll
                                Center(
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        'assets/images/logo_chu_gif.gif',
                                        height: 60,
                                        fit: BoxFit.contain,
                                      ),
                                      const SizedBox(height: 20),
                                    ],
                                  ),
                                ),

                                // Spacer đẩy phần input xuống giữa tự nhiên
                                const SizedBox(height: 24),

                                _buildInput(
                                  label: 'Tên đăng nhập',
                                  icon: Icons.person,
                                  controller: usernameController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      triggerShake();
                                      return 'Vui lòng nhập tên đăng nhập';
                                    }
                                    return null;
                                  },
                                  shake: _usernameShake,
                                ),
                                const SizedBox(height: 20),

                                _buildInput(
                                  label: 'Mật khẩu',
                                  icon: Icons.lock,
                                  controller: passwordController,
                                  isPassword: true,
                                  obscure: obscurePassword,
                                  toggleObscure: () => setState(() {
                                    obscurePassword = !obscurePassword;
                                  }),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      triggerShake();
                                      return 'Vui lòng nhập mật khẩu';
                                    }
                                    return null;
                                  },
                                  shake: _passwordShake,
                                ),

                                const SizedBox(
                                  height: 36,
                                ), // Khoảng cách cân đối

                                ElevatedButton(
                                  onPressed: loading
                                      ? null
                                      : () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            handleLogin();
                                          }
                                        },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    minimumSize: const Size.fromHeight(50),
                                  ),
                                  child: loading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        )
                                      : const Text(
                                          'Đăng nhập',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
