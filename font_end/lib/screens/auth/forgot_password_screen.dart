import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/services/api_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  int _step = 1; // 1: Email, 2: OTP & Reset Password
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Xử lý gửi OTP và thiết lập mật khẩu mới
  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();

    if (_step == 1) {
      if (email.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập địa chỉ email của bạn!'),
            backgroundColor: AppTheme.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);
      
      try {
        final success = await ApiService.sendOTP(email);
        if (mounted) {
          setState(() => _isLoading = false);
          if (success) {
            setState(() {
              _step = 2; // Chuyển sang bước nhập OTP và đặt lại mật khẩu
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mã OTP xác thực đã được gửi tới Email của bạn!'),
                backgroundColor: AppTheme.teal,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Gửi mã OTP thất bại! Vui lòng kiểm tra lại email của bạn.'),
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
              content: Text('Lỗi kết nối: $e'),
              backgroundColor: AppTheme.red,
            ),
          );
        }
      }
    } else {
      // Bước 2: Xác minh OTP và reset
      final otpCode = _otpController.text.trim();
      final newPassword = _newPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (otpCode.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin!'),
            backgroundColor: AppTheme.red,
          ),
        );
        return;
      }

      if (newPassword != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu xác nhận không khớp!'),
            backgroundColor: AppTheme.red,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        // 1. Xác thực OTP
        final otpOk = await ApiService.verifyOTP(email, otpCode);
        if (!otpOk) {
          if (mounted) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mã OTP không hợp lệ hoặc đã hết hạn!'),
                backgroundColor: AppTheme.red,
              ),
            );
          }
          return;
        }

        // 2. Thực hiện đổi mật khẩu
        final resetOk = await ApiService.resetPassword(email, newPassword);

        if (mounted) {
          setState(() => _isLoading = false);
          if (resetOk) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Mật khẩu của bạn đã được đặt lại thành công!'),
                backgroundColor: AppTheme.teal,
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) Navigator.of(context).pop();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đặt lại mật khẩu thất bại! Vui lòng thử lại.'),
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
              content: Text('Lỗi kết nối: $e'),
              backgroundColor: AppTheme.red,
            ),
          );
        }
      }
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
                    : 'Vui lòng nhập mã OTP 6 số và thiết lập mật khẩu mới của bạn.',
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
                // OTP Code Field
                const Text(
                  'Mã xác thực OTP (6 chữ số)',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _otpController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập mã 6 số',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Text('🔑', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),

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
                onPressed: _isLoading ? null : _handleResetPassword,
                child: _isLoading 
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_step == 1 ? 'Gửi yêu cầu' : 'Đặt lại mật khẩu'),
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
