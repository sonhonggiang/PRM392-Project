const mysql = require('mysql2/promise');
const stepsData = require('../config/origamiStepsData');
require('dotenv').config();

async function restoreHeartSwan() {
  const dbName = process.env.DB_NAME || 'Web_Son_Dep_Trai';
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: dbName
  });

  try {
    console.log(`🔄 Đang kết nối tới Database: "${dbName}"...`);
    
    // Đảm bảo có admin user (ID = 1) để gán làm creator
    const mockAdminPasswordHash = '$2a$10$sDmHJ96MVOHjhJZUT79Ki.Xd40DvI2Xlt8silKpnrl7MHjLwvvh6m';
    await conn.query(
      "INSERT IGNORE INTO users (id, email, password_hash, display_name, role, xp) VALUES (1, 'admin@origami.com', ?, 'Admin trang gấp giấy', 'admin', 500)",
      [mockAdminPasswordHash]
    );

    // 1. Khôi phục Trái Tim (ID 1)
    const [heartRows] = await conn.query('SELECT id FROM origami_models WHERE id = 1');
    if (heartRows.length === 0) {
      console.log('🌱 Trái Tim (ID 1) không tồn tại, đang thêm mới...');
      await conn.query(
        `INSERT INTO origami_models (id, name, emoji, difficulty, estimated_time, paper_size, paper_type, category_id, creator_id, status, rating) 
         VALUES (1, 'Trái Tim', '❤️', 'Dễ', 8, '15x15 cm', 'Washi', 3, 1, 'approved', 4.6)`
      );
    } else {
      console.log('ℹ️ Trái Tim (ID 1) đã tồn tại, giữ nguyên mô hình.');
    }
    
    // Cập nhật/khôi phục các bước gấp của Trái Tim
    await conn.query('DELETE FROM origami_steps WHERE origami_id = 1');
    const heartSteps = stepsData[1];
    for (const s of heartSteps) {
      await conn.query(
        `INSERT INTO origami_steps (origami_id, step_number, instruction, tip, image_url) 
         VALUES (1, ?, ?, ?, ?)`,
        [s.step, s.text, s.tip, s.img]
      );
    }
    console.log(`✅ Đã khôi phục ${heartSteps.length} bước gấp của Trái Tim (ID 1) với liên kết gốc.`);

    // 2. Khôi phục Hạc Giấy (ID 2)
    const [swanRows] = await conn.query('SELECT id FROM origami_models WHERE id = 2');
    if (swanRows.length === 0) {
      console.log('🌱 Hạc Giấy (ID 2) không tồn tại, đang thêm mới...');
      await conn.query(
        `INSERT INTO origami_models (id, name, emoji, difficulty, estimated_time, paper_size, paper_type, category_id, creator_id, status, rating) 
         VALUES (2, 'Hạc Giấy', '🦢', 'Trung bình', 15, '15x15 cm', 'Washi', 1, 1, 'approved', 4.9)`
      );
    } else {
      console.log('ℹ️ Hạc Giấy (ID 2) đã tồn tại, giữ nguyên mô hình.');
    }

    // Cập nhật/khôi phục các bước gấp của Hạc Giấy
    await conn.query('DELETE FROM origami_steps WHERE origami_id = 2');
    const swanSteps = stepsData[2];
    for (const s of swanSteps) {
      await conn.query(
        `INSERT INTO origami_steps (origami_id, step_number, instruction, tip, image_url) 
         VALUES (2, ?, ?, ?, ?)`,
        [s.step, s.text, s.tip, s.img]
      );
    }
    console.log(`✅ Đã khôi phục ${swanSteps.length} bước gấp của Hạc Giấy (ID 2) với liên kết gốc.`);

    console.log('\n🎉 Khôi phục hoàn tất! Không đụng chạm bất kỳ mẫu nào khác.');

  } catch (err) {
    console.error('❌ Lỗi:', err.message);
  } finally {
    await conn.end();
  }
}

restoreHeartSwan().catch(console.error);
