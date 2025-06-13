import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

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
  late VideoPlayerController _controller;

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

    _controller = VideoPlayerController.asset("videos/logo_text.mp4")
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  void triggerShake() {
    _shakeController.forward(from: 0);
  }

  @override
  void dispose() {
    _shakeController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    _controller.dispose();
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),
              Center(
                child: _controller.value.isInitialized
                    ? SizedBox(
                        width: 120,
                        height: 120,
                        child: VideoPlayer(_controller),
                      )
                    : const CircularProgressIndicator(),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'Chào mừng bạn đến với',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const Center(
                child: Text(
                  'PLUSHDOLLCUSTOM',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Username
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
              const SizedBox(height: 16),

              // Password
              _buildInput(
                label: 'Mật khẩu',
                icon: Icons.lock,
                controller: passwordController,
                isPassword: true,
                obscure: obscurePassword,
                toggleObscure: () =>
                    setState(() => obscurePassword = !obscurePassword),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    triggerShake();
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
                shake: _passwordShake,
              ),

              const SizedBox(height: 10),

              // Remember + Forgot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: rememberMe,
                        onChanged: (val) => setState(() => rememberMe = val!),
                      ),
                      const Text('Ghi nhớ đăng nhập'),
                    ],
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Quên mật khẩu?',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Login button
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          // handleLogin();
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

              const SizedBox(height: 24),

              // Or divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('Hoặc đăng nhập với'),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),

              const SizedBox(height: 16),

              // Google button
              ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  minimumSize: const Size.fromHeight(50),
                ),
                icon: const Icon(Icons.g_mobiledata, color: Colors.white),
                label: const Text(
                  'Đăng nhập với Google',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              const SizedBox(height: 24),

              // Signup prompt
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có tài khoản?'),
                  TextButton(
                    onPressed: () {
                      // Navigator.push...
                    },
                    child: const Text(
                      'Đăng ký ngay',
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
