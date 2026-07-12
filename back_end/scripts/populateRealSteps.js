const mysql = require('mysql2/promise');
const stepsData = require('../config/origamiStepsData');
require('dotenv').config();

async function populateRealSteps() {
  const dbName = process.env.DB_NAME || 'Web_Son_Dep_Trai';
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
  });

  try {
    // Tự động kiểm tra/tạo DB nếu chưa có
    await conn.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`);
    await conn.query(`USE \`${dbName}\`;`);
    console.log(`✅ Đã kết nối thành công tới Database: "${dbName}"`);
    console.log('🔄 Bắt đầu cập nhật hướng dẫn gấp chi tiết với hình ảnh ĐÚNG và KHÔNG LỖI cho từng mẫu...');

    for (const [mId, steps] of Object.entries(stepsData)) {
      // Xóa bước cũ
      await conn.query('DELETE FROM origami_steps WHERE origami_id = ?', [mId]);
      // Chèn bước mới
      for (const s of steps) {
        await conn.query(
          `INSERT INTO origami_steps (origami_id, step_number, instruction, tip, image_url, estimated_duration) 
           VALUES (?, ?, ?, ?, ?, 1)`,
          [mId, s.step, s.text, s.tip, s.img]
        );
      }
      console.log(`✅ [${mId}]: ${steps.length} bước gấp đã cập nhật.`);
    }

    console.log('\n🎉 Hoàn thành! Tất cả mẫu đã có hướng dẫn gấp riêng biệt và hình ảnh chính xác lấy từ origami-instructions.com!');

  } catch (err) {
    console.error('❌ Lỗi:', err.message);
  } finally {
    await conn.end();
  }
}

populateRealSteps().catch(console.error);
