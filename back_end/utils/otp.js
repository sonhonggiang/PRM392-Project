const nodemailer = require('nodemailer');
require('dotenv').config();

// Sinh mã OTP 6 chữ số ngẫu nhiên
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Gửi OTP qua email (nếu cấu hình SMTP) hoặc in ra console
async function sendOTPEmail(email, otpCode) {
  console.log(`[TESTING OTP] 🔑 Mã OTP dành cho ${email} là: ${otpCode}`);

  const hasConfig = process.env.EMAIL_USER && 
                    process.env.EMAIL_USER !== 'your_email@gmail.com' &&
                    process.env.EMAIL_PASS && 
                    process.env.EMAIL_PASS !== 'your_email_app_password';

  if (!hasConfig) {
    console.log(`[SMTP INFO] Chưa cấu hình SMTP gửi email. Đã giả lập gửi thành công.`);
    return true;
  }

  try {
    const transporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST || 'smtp.gmail.com',
      port: parseInt(process.env.EMAIL_PORT || '587'),
      secure: false, // true for 465, false for other ports
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });

    const mailOptions = {
      from: `"Origami App Support" <${process.env.EMAIL_USER}>`,
      to: email,
      subject: 'Mã OTP đặt lại mật khẩu - Origami App',
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 8px; max-width: 600px;">
          <h2 style="color: #3f51b5; text-align: center;">Mã Xác Thực OTP</h2>
          <p>Xin chào,</p>
          <p>Chúng tôi nhận được yêu cầu đặt lại mật khẩu cho tài khoản Origami của bạn. Mã OTP xác thực của bạn là:</p>
          <div style="text-align: center; margin: 30px 0;">
            <span style="font-size: 32px; font-weight: bold; letter-spacing: 5px; padding: 10px 20px; background-color: #f5f5f5; border-radius: 4px; border: 1px dashed #3f51b5; color: #3f51b5;">
              ${otpCode}
            </span>
          </div>
          <p style="color: #ff5722; font-weight: bold;">Mã này có hiệu lực trong vòng 5 phút.</p>
          <p>Nếu bạn không thực hiện yêu cầu này, vui lòng bỏ qua email.</p>
          <hr style="border: none; border-top: 1px solid #eee; margin-top: 30px;" />
          <p style="font-size: 12px; color: #9e9e9e; text-align: center;">Origami App © 2026</p>
        </div>
      `,
    };

    await transporter.sendMail(mailOptions);
    console.log(`[SMTP] Đã gửi email chứa OTP tới ${email}`);
    return true;
  } catch (error) {
    console.error(`[SMTP ERROR] Lỗi gửi email:`, error.message);
    // Vẫn trả về true hoặc cho phép tiếp tục vì đã in ra console để debug
    return true;
  }
}

module.exports = {
  generateOTP,
  sendOTPEmail
};
