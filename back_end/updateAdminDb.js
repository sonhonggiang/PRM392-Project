const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
require('dotenv').config();

async function run() {
  const dbName = process.env.DB_NAME || 'Web_Son_Dep_Trai';
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: dbName
  });

  try {
    const email = 'admin@origami.com';
    const password = '123456';
    const hash = bcrypt.hashSync(password, 10);
    const displayName = 'Admin trang gấp giấy';

    // 1. Check if user already exists
    const [rows] = await connection.query('SELECT * FROM users WHERE email = ?', [email]);
    if (rows.length > 0) {
      // User exists, update password and role to admin
      await connection.query(
        'UPDATE users SET password_hash = ?, role = ?, display_name = ? WHERE email = ?',
        [hash, 'admin', displayName, email]
      );
      console.log(`✅ Đã cập nhật tài khoản Admin cũ: ${email} với mật khẩu mới: ${password}`);
    } else {
      // User does not exist, insert it
      await connection.query(
        'INSERT INTO users (email, password_hash, display_name, role, xp) VALUES (?, ?, ?, ?, ?)',
        [email, hash, displayName, 'admin', 500]
      );
      console.log(`✅ Đã tạo tài khoản Admin mới: ${email} với mật khẩu: ${password}`);
    }
  } catch (err) {
    console.error('❌ Lỗi thiết lập Admin:', err.message);
  } finally {
    await connection.end();
  }
}

run();
