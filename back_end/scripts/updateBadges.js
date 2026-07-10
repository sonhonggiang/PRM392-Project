const mysql = require('mysql2/promise');
require('dotenv').config();

async function updateBadges() {
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'origami_app_db',
  });

  try {
    // Xóa user_badges cũ có badge_id 2,3,4 để không conflict
    await conn.query('DELETE FROM user_badges WHERE badge_id IN (2,3,4,5,6)');
    // Xóa badges cũ
    await conn.query('DELETE FROM badges WHERE id IN (2,3,4,5,6)');
    // Thêm 6 badges mới
    await conn.query(`
      INSERT INTO badges (id, name, emoji, description, condition_type, condition_value) VALUES 
      (2, 'Tân binh gấp giấy', '🐣', 'Hoàn thành 5 mẫu gấp', 'total_fold', 5),
      (3, 'Thợ gấp giấy', '⭐', 'Hoàn thành 10 mẫu gấp - bạn đang tiến bộ!', 'total_fold', 10),
      (4, 'Nghệ nhân Origami', '🎭', 'Hoàn thành 15 mẫu gấp - bạn thực sự đam mê!', 'total_fold', 15),
      (5, 'Bậc thầy Origami', '🏆', 'Hoàn thành 20 mẫu gấp - kỹ năng tuyệt vời!', 'total_fold', 20),
      (6, 'Huyền thoại Origami', '👑', 'Hoàn thành 30 mẫu gấp - bạn là huyền thoại!', 'total_fold', 30)
    `);
    // Cập nhật badge 1
    await conn.query("UPDATE badges SET description='Hoàn thành mẫu gấp đầu tiên của bạn!' WHERE id=1");
    
    const [rows] = await conn.query('SELECT * FROM badges ORDER BY id');
    console.log('Badges hien tai:');
    rows.forEach(b => console.log(`  [${b.id}] ${b.emoji} ${b.name} - ${b.description}`));
    console.log('Cap nhat badges thanh cong!');
  } finally {
    await conn.end();
  }
}

updateBadges().catch(console.error);
