import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/api_service.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Luồng đăng ký thực tế kết nối với backend
  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin đăng ký!'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu phải dài tối thiểu 6 ký tự!'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Gọi API Đăng ký tài khoản
      final errorResult = await context.read<AuthProvider>().register(email, password, name);

      if (mounted) {
        if (errorResult == null) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký tài khoản thành công! Vui lòng đăng nhập.'),
              backgroundColor: AppTheme.teal,
            ),
          );
          // Quay lại màn hình Đăng nhập
          Navigator.of(context).pop();
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorResult),
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
            content: Text('Lỗi trong quá trình đăng ký: $e'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Tạo tài khoản mới',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.indigo,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Đăng ký để lưu lại quá trình học tập',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.muted,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              
              // Name Field
              const Text(
                'Họ và tên',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: 'Nhập họ tên của bạn',
                  prefixIcon: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text('👤', style: TextStyle(fontSize: 16)),
                  ),
                ),
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 20),

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
                  hintText: 'Tối thiểu 6 ký tự',
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
              const SizedBox(height: 32),
              
              // Register Button
              FilledButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Đăng ký'),
              ),
              const SizedBox(height: 16),
              // Back to Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Đã có tài khoản? ', style: TextStyle(color: AppTheme.muted)),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.indigo),
                    child: const Text('Đăng nhập', style: TextStyle(fontWeight: FontWeight.w700)),
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
