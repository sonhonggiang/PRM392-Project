const mysql = require('mysql2/promise');
require('dotenv').config();

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'origami_app_db',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Test connection
pool.getConnection()
  .then(conn => {
    console.log('✅ Kết nối Cơ sở dữ liệu MySQL thành công!');
    conn.release();
  })
  .catch(err => {
    console.error('❌ Lỗi kết nối Cơ sở dữ liệu MySQL: ', err.message);
    console.log('👉 Vui lòng tạo cơ sở dữ liệu "' + (process.env.DB_NAME || 'origami_app_db') + '" trong MySQL Workbench và kiểm tra tài khoản/mật khẩu trong file .env');
  });

module.exports = pool;
