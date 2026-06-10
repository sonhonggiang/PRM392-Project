import 'package:flutter/material.dart';
import '../../core/theme.dart';
import 'otp_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;

  void _handleRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const OtpScreen()),
    );
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
                decoration: InputDecoration(
                  hintText: 'Nhập họ tên của bạn',
                  prefixIcon: const Padding(
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
                decoration: InputDecoration(
                  hintText: 'you@email.com',
                  prefixIcon: const Padding(
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
                onPressed: _handleRegister,
                child: const Text('Đăng ký'),
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
              
              // Google Button
              OutlinedButton.icon(
                onPressed: _handleRegister,
                icon: const Text('🌐', style: TextStyle(fontSize: 18)),
                label: const Text('Đăng ký bằng Google'),
              ),
              
              const SizedBox(height: 32),
              // Register link
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
