import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Giả lập Đăng nhập bằng Google
  Future<void> _handleGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    
    // Giả lập 1.5 giây để hiện vòng xoay "Google Auth"
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (mounted) {
      setState(() => _isGoogleLoading = false);
      
      // Tạo một đối tượng User giả từ Google
      final googleUser = UserModel(
        id: 'google_${DateTime.now().millisecondsSinceEpoch}',
        email: 'sonhonggiang.google@gmail.com',
        displayName: 'Giang Google',
        role: UserRole.user,
        avatarUrl: '',
      );
      
      // Đăng nhập vào app bằng Mock Google User
      context.read<AuthProvider>().loginAs(googleUser);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã kết nối với tài khoản Google! 🌐'),
          backgroundColor: AppTheme.teal,
        ),
      );
      
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  // Đăng nhập nhanh cho việc kiểm thử UI tĩnh (Guest)
  void _handleMockLogin(UserModel user) {
    context.read<AuthProvider>().loginAs(user);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  // Đăng nhập thực tế kết nối với API Backend
  Future<void> _handleRealLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ email và mật khẩu!'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final errorMessage = await context.read<AuthProvider>().login(email, password);

      if (mounted) {
        setState(() => _isLoading = false);
        if (errorMessage == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng nhập thành công! 🎉'),
              backgroundColor: AppTheme.teal,
            ),
          );
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: AppTheme.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể kết nối đến máy chủ: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              // Header Icon
              const Center(
                child: Text('🕊️', style: TextStyle(fontSize: 48)),
              ),
              const SizedBox(height: 24),
              const Text(
                'Đăng nhập',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.indigo,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Chào mừng bạn quay lại với Origami',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.muted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Email Field
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'you@email.com',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('📧', style: TextStyle(fontSize: 16)),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              
              // Password Field
              const Text(
                'Mật khẩu',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '••••••••',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('🔒', style: TextStyle(fontSize: 16)),
                  ),
                  suffixIcon: IconButton(
                    icon: Text(_obscurePassword ? '👁️' : '🙈', style: const TextStyle(fontSize: 16)),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),
              
              // Forgot Password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.teal,
                  ),
                  child: const Text('Quên mật khẩu?', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 24),
              
              // Login Button
              FilledButton(
                onPressed: _isLoading ? null : _handleRealLogin,
                child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Đăng nhập'),
              ),
              const SizedBox(height: 16),
              

              
              // OR divider
              Row(
                children: [
                  Expanded(child: Divider(color: AppTheme.border)),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('HOẶC', style: TextStyle(color: AppTheme.muted, fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                  Expanded(child: Divider(color: AppTheme.border)),
                ],
              ),
              const SizedBox(height: 16),
              
              // Google Button (Chỉnh sửa để không dùng account cũ đã xóa)
              OutlinedButton.icon(
                onPressed: _isGoogleLoading ? null : _handleGoogleLogin,
                icon: _isGoogleLoading 
                    ? const SizedBox(
                        height: 18, 
                        width: 18, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.indigo)
                      )
                    : const Text('🌐', style: TextStyle(fontSize: 18)),
                label: Text(_isGoogleLoading ? 'Đang kết nối...' : 'Tiếp tục với Google'),
              ),
              
              const SizedBox(height: 32),
              // Register link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Chưa có tài khoản? ', style: TextStyle(color: AppTheme.muted)),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterScreen()),
                      );
                    },
                    style: TextButton.styleFrom(foregroundColor: AppTheme.indigo),
                    child: const Text('Đăng ký ngay', style: TextStyle(fontWeight: FontWeight.w700)),
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
