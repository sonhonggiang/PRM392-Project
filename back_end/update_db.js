const mysql = require('mysql2/promise');
require('dotenv').config();

async function update() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'origami_app_db',
  });

  try {
    console.log('🔄 Đang cập nhật Database...');

    // 1. Thêm cột xp_reward vào origami_models
    try {
      await connection.query('ALTER TABLE origami_models ADD COLUMN xp_reward INT DEFAULT 50 AFTER status');
      console.log('✅ Đã thêm cột xp_reward');
    } catch (e) { console.log('⚠️ Cột xp_reward đã tồn tại hoặc lỗi: ' + e.message); }

    // 2. Thêm cột estimated_duration vào origami_steps
    try {
      await connection.query('ALTER TABLE origami_steps ADD COLUMN estimated_duration INT DEFAULT 0 AFTER image_url');
      console.log('✅ Đã thêm cột estimated_duration');
    } catch (e) { console.log('⚠️ Cột estimated_duration đã tồn tại hoặc lỗi: ' + e.message); }

    // 3. Cập nhật difficulty enum
    try {
      await connection.query("ALTER TABLE origami_models MODIFY COLUMN difficulty ENUM('Dễ', 'Trung bình', 'Khó', 'Cực khó') DEFAULT 'Dễ'");
      console.log('✅ Đã cập nhật difficulty enum');
    } catch (e) { console.log('⚠️ Lỗi cập nhật difficulty: ' + e.message); }

    // 4. Thêm cột image_url vào categories
    try {
      await connection.query('ALTER TABLE categories ADD COLUMN image_url VARCHAR(255) DEFAULT NULL AFTER emoji');
      console.log('✅ Đã thêm cột image_url vào categories');
    } catch (e) { console.log('⚠️ Cột image_url đã tồn tại hoặc lỗi: ' + e.message); }

    console.log('🚀 Cập nhật Database thành công!');
  } catch (error) {
    console.error('❌ Lỗi cập nhật:', error.message);
  } finally {
    await connection.end();
  }
}

update();
