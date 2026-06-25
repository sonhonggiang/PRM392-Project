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
  bool _obscurePassword = true;

  void _handleLogin(UserModel user) {
    context.read<AuthProvider>().loginAs(user);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
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
                onPressed: () => _handleLogin(UserModel.mockUser),
                child: const Text('Đăng nhập'),
              ),
              const SizedBox(height: 16),
              
              // TEST ROLES (For development)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.amber.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    const Text('Test Roles', style: TextStyle(color: AppTheme.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        ActionChip(
                          label: const Text('Guest', style: TextStyle(fontSize: 11)),
                          onPressed: () => _handleLogin(UserModel.mockGuest),
                        ),
                        ActionChip(
                          label: const Text('User', style: TextStyle(fontSize: 11)),
                          onPressed: () => _handleLogin(UserModel.mockUser),
                        ),
                        ActionChip(
                          label: const Text('Admin', style: TextStyle(fontSize: 11)),
                          onPressed: () => _handleLogin(UserModel.mockAdmin),
                        ),
                      ],
                    ),
                  ],
                ),
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
                onPressed: () => _handleLogin(UserModel.mockUser),
                icon: const Text('🌐', style: TextStyle(fontSize: 18)),
                label: const Text('Tiếp tục với Google'),
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
