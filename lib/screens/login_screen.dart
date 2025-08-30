import 'dart:convert';

import 'package:PlushDollCustom/redux/app_state.dart';
import 'package:PlushDollCustom/redux/auth_actions.dart';
import 'package:PlushDollCustom/services/auth_service.dart';
import 'package:PlushDollCustom/screens/home_screen.dart';
import 'package:PlushDollCustom/constants/role_constants.dart';
import 'package:PlushDollCustom/exceptions/auth_exceptions.dart';
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
      String errorMessage = e.toString();

      // Handle null or empty error messages
      if (errorMessage.isEmpty) {
        errorMessage = 'Đã xảy ra lỗi không xác định. Vui lòng thử lại.';
      }

      // Check if it's a role-based access error
      if (e is RoleAccessDeniedException) {
        // Show a more prominent error dialog for role-based access
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Thông báo',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                      children: [
                        TextSpan(text: 'Tài khoản '),
                        TextSpan(
                          text: RoleConstants.translateRole(
                            (e as RoleAccessDeniedException).role,
                          ),
                          style: TextStyle(
                            color: RoleConstants.getRoleColor(
                              (e as RoleAccessDeniedException).role,
                            ),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text:
                              ' không được hỗ trợ trên ứng dụng di động. Ứng dụng di động chỉ dành cho khách hàng.',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.computer, color: Colors.orange, size: 16),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Vui lòng truy cập website để sử dụng đầy đủ tính năng dành cho bạn.',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    minimumSize: Size(80, 36),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Text('Đã hiểu', style: TextStyle(fontSize: 13)),
                ),
              ],
            );
          },
        );
      } else {
        // Show regular snackbar for other errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
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

                                const SizedBox(height: 20),

                                // Nút chuyển sang trang đăng ký
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Chưa có tài khoản? ',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 14,
                                      ),
                                    ),
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: GestureDetector(
                                        onTap: () {
                                          // TODO: Navigate to registration screen
                                          print(
                                            'Chức năng đăng ký sẽ được phát triển sau',
                                          );
                                        },
                                        child: AnimatedContainer(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          child: const Text(
                                            'Đăng ký ngay',
                                            style: TextStyle(
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
