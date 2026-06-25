import 'package:flutter/material.dart';
import '../../core/theme.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 1; // 1: Email, 2: Reset Password
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_step == 1) {
      if (_emailController.text.isNotEmpty) {
        setState(() {
          _step = 2;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xác thực email thành công! Vui lòng thiết lập mật khẩu mới.'),
            backgroundColor: AppTheme.teal,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập địa chỉ email của bạn!'),
            backgroundColor: AppTheme.red,
          ),
        );
      }
    } else {
      if (_newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập đầy đủ thông tin mật khẩu!'),
            backgroundColor: AppTheme.red,
          ),
        );
        return;
      }
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu xác nhận không trùng khớp!'),
            backgroundColor: AppTheme.red,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mật khẩu của bạn đã được đặt lại thành công!'),
          backgroundColor: AppTheme.teal,
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.indigo, size: 20),
          onPressed: () {
            if (_step == 2) {
              setState(() {
                _step = 1;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Header Icon
              Center(
                child: Text(
                  _step == 1 ? '🔑' : '🛡️',
                  style: const TextStyle(fontSize: 64),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                _step == 1 ? 'Quên mật khẩu?' : 'Đặt lại mật khẩu',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.indigo,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _step == 1
                    ? 'Đừng lo lắng! Hãy nhập email đã đăng ký. Chúng tôi sẽ gửi hướng dẫn đặt lại mật khẩu cho bạn.'
                    : 'Vui lòng thiết lập mật khẩu mới mạnh mẽ để bảo vệ tài khoản của bạn.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.muted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              if (_step == 1) ...[
                // Email Field
                const Text(
                  'Địa chỉ Email',
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
              ] else ...[
                // New Password Field
                const Text(
                  'Mật khẩu mới',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscureNewPassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('🔒', style: TextStyle(fontSize: 16)),
                    ),
                    suffixIcon: IconButton(
                      icon: Text(_obscureNewPassword ? '👁️' : '🙈', style: const TextStyle(fontSize: 16)),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm New Password Field
                const Text(
                  'Xác nhận mật khẩu mới',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('🔒', style: TextStyle(fontSize: 16)),
                    ),
                    suffixIcon: IconButton(
                      icon: Text(_obscureConfirmPassword ? '👁️' : '🙈', style: const TextStyle(fontSize: 16)),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Submit Button
              FilledButton(
                onPressed: _handleResetPassword,
                child: Text(_step == 1 ? 'Gửi yêu cầu' : 'Đặt lại mật khẩu'),
              ),

              const SizedBox(height: 24),
              // Back to Login link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Bạn đã nhớ mật khẩu? ', style: TextStyle(color: AppTheme.muted)),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.indigo),
                    child: const Text('Quay lại đăng nhập', style: TextStyle(fontWeight: FontWeight.w700)),
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
