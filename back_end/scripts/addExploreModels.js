const mysql = require('mysql2/promise');
require('dotenv').config();

async function addModels() {
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'origami_app_db',
  });

  try {
    const adminId = 1; // Admin sở hữu các mẫu này
    
    // Danh sách 10 mẫu Origami mới không có đánh giá (rating = 0.0)
    const newModels = [
      { id: 11, name: 'Thỏ Con', emoji: '🐰', difficulty: 'Dễ', time: 5, category_id: 1, paper_size: '15x15 cm', paper_type: 'Kami' },
      { id: 12, name: 'Bướm Xinh', emoji: '🦋', difficulty: 'Dễ', time: 6, category_id: 1, paper_size: '15x15 cm', paper_type: 'Washi' },
      { id: 13, name: 'Con Cá Vàng', emoji: '🐟', difficulty: 'Dễ', time: 7, category_id: 1, paper_size: '15x15 cm', paper_type: 'Kami' },
      { id: 14, name: 'Hoa Hồng', emoji: '🌹', difficulty: 'Khó', time: 20, category_id: 2, paper_size: '20x20 cm', paper_type: 'Tant' },
      { id: 15, name: 'Cây Thông', emoji: '🌲', difficulty: 'Dễ', time: 10, category_id: 2, paper_size: '15x15 cm', paper_type: 'Kami' },
      { id: 16, name: 'Thuyền Giấy', emoji: '⛵', difficulty: 'Dễ', time: 4, category_id: 3, paper_size: '15x15 cm', paper_type: 'Kami' },
      { id: 17, name: 'Máy Bay Giấy', emoji: '✈️', difficulty: 'Dễ', time: 3, category_id: 3, paper_size: '15x15 cm', paper_type: 'Kami' },
      { id: 18, name: 'Xe Tải Giấy', emoji: '🚚', difficulty: 'Trung bình', time: 12, category_id: 3, paper_size: '18x18 cm', paper_type: 'Kraft' },
      { id: 19, name: 'Chiếc Cốc Giấy', emoji: '🥛', difficulty: 'Dễ', time: 5, category_id: 3, paper_size: '12x12 cm', paper_type: 'Kami' },
      { id: 20, name: 'Ngôi Sao May Mắn', emoji: '⭐', difficulty: 'Dễ', time: 8, category_id: 3, paper_size: '1x20 cm Strip', paper_type: 'Star Paper' },
    ];

    for (const m of newModels) {
      // Chèn mẫu Origami
      await conn.query(
        `INSERT INTO origami_models (id, name, emoji, difficulty, estimated_time, paper_size, paper_type, category_id, creator_id, status, rating) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'approved', 0.0)
         ON DUPLICATE KEY UPDATE name=VALUES(name), emoji=VALUES(emoji), difficulty=VALUES(difficulty), estimated_time=VALUES(estimated_time)`,
        [m.id, m.name, m.emoji, m.difficulty, m.time, m.paper_size, m.paper_type, m.category_id, adminId]
      );

      // Chèn ít nhất 2 bước gấp mẫu cho mỗi Origami mới để không bị trống
      await conn.query(`DELETE FROM origami_steps WHERE origami_id = ?`, [m.id]);
      await conn.query(
        `INSERT INTO origami_steps (origami_id, step_number, instruction, tip) VALUES 
         (?, 1, 'Chuẩn bị giấy và gấp đôi để tạo nếp trung tâm.', 'Hãy vuốt thật thẳng.'),
         (?, 2, 'Tiếp tục gấp các góc theo hướng dẫn tạo hình cơ bản.', 'Chú ý căn chỉnh các góc đối xứng.')`,
        [m.id, m.id]
      );
    }

    console.log('✅ Da them thanh cong 10 mau gap moi chua co danh gia (rating = 0.0) vao DB!');
  } finally {
    await conn.end();
  }
}

addModels().catch(console.error);
