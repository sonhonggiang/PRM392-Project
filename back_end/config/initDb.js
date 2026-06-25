const mysql = require('mysql2/promise');
require('dotenv').config();

async function initializeDatabase() {
  const connectionConfig = {
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
  };

  const dbName = process.env.DB_NAME || 'origami_app_db';
  let connection;

  try {
    console.log('🔄 Đang kết nối tới MySQL để kiểm tra/khởi tạo cơ sở dữ liệu...');
    connection = await mysql.createConnection(connectionConfig);

    // 1. Tạo Database nếu chưa tồn tại
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`);
    console.log(`✅ Đã xác minh/tạo Cơ sở dữ liệu: "${dbName}"`);

    // Chọn cơ sở dữ liệu
    await connection.query(`USE \`${dbName}\`;`);

    // 2. Tạo bảng users
    await connection.query(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(191) NOT NULL UNIQUE,
        password_hash VARCHAR(255) NOT NULL,
        display_name VARCHAR(100) NOT NULL,
        role ENUM('user', 'admin') DEFAULT 'user',
        avatar_url VARCHAR(255) DEFAULT '',
        xp INT DEFAULT 0,
        streak_count INT DEFAULT 0,
        last_active_date DATE DEFAULT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      );
    `);

    // 3. Tạo bảng otps
    await connection.query(`
      CREATE TABLE IF NOT EXISTS otps (
        id INT AUTO_INCREMENT PRIMARY KEY,
        email VARCHAR(191) NOT NULL,
        otp_code VARCHAR(6) NOT NULL,
        expired_at TIMESTAMP NOT NULL,
        is_used TINYINT(1) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // 4. Tạo bảng categories
    await connection.query(`
      CREATE TABLE IF NOT EXISTS categories (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(50) NOT NULL UNIQUE,
        emoji VARCHAR(10) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Chèn danh mục mặc định
    await connection.query(`
      INSERT IGNORE INTO categories (id, name, emoji) VALUES 
      (1, 'Động vật', '🐰'),
      (2, 'Hoa cỏ', '🌺'),
      (3, 'Đồ vật', '✈️');
    `);

    // 5. Tạo bảng origami_models
    await connection.query(`
      CREATE TABLE IF NOT EXISTS origami_models (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        emoji VARCHAR(10) NOT NULL,
        difficulty ENUM('Dễ', 'Trung bình', 'Khó') DEFAULT 'Dễ',
        estimated_time INT NOT NULL COMMENT 'Đơn vị: phút',
        paper_size VARCHAR(50) DEFAULT '15x15 cm',
        paper_type VARCHAR(100) DEFAULT 'Washi',
        category_id INT NOT NULL,
        creator_id INT NOT NULL,
        status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
        rejection_reason TEXT DEFAULT NULL,
        rating DECIMAL(2,1) DEFAULT 0.0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      );
    `);

    // 6. Tạo bảng origami_steps
    await connection.query(`
      CREATE TABLE IF NOT EXISTS origami_steps (
        id INT AUTO_INCREMENT PRIMARY KEY,
        origami_id INT NOT NULL,
        step_number INT NOT NULL,
        instruction TEXT NOT NULL,
        tip TEXT DEFAULT NULL,
        image_url VARCHAR(255) DEFAULT '',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (origami_id) REFERENCES origami_models(id) ON DELETE CASCADE,
        UNIQUE KEY uq_origami_step (origami_id, step_number)
      );
    `);

    // 7. Tạo bảng favorites
    await connection.query(`
      CREATE TABLE IF NOT EXISTS favorites (
        user_id INT NOT NULL,
        origami_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (user_id, origami_id),
        FOREIGN KEY (origami_id) REFERENCES origami_models(id) ON DELETE CASCADE
      );
    `);

    // 8. Tạo bảng user_progress
    await connection.query(`
      CREATE TABLE IF NOT EXISTS user_progress (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        origami_id INT NOT NULL,
        current_step INT DEFAULT 1,
        is_completed TINYINT(1) DEFAULT 0,
        completed_at TIMESTAMP NULL DEFAULT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        FOREIGN KEY (origami_id) REFERENCES origami_models(id) ON DELETE CASCADE,
        UNIQUE KEY uq_user_origami (user_id, origami_id)
      );
    `);

    // 9. Tạo bảng badges
    await connection.query(`
      CREATE TABLE IF NOT EXISTS badges (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(100) NOT NULL UNIQUE,
        emoji VARCHAR(10) NOT NULL,
        description TEXT NOT NULL,
        condition_type VARCHAR(50) NOT NULL COMMENT 'Loại điều kiện mở khóa',
        condition_value INT NOT NULL COMMENT 'Giá trị cần đạt',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);

    // Chèn huy hiệu mặc định
    await connection.query(`
      INSERT IGNORE INTO badges (id, name, emoji, description, condition_type, condition_value) VALUES 
      (1, 'Người mới', '🌱', 'Hoàn thành mẫu đầu tiên', 'first_fold', 1),
      (2, 'Fan Hạc giấy', '🦢', 'Gấp hạc giấy 5 lần', 'fold_swan', 5),
      (3, 'Chuỗi 7 ngày', '🔥', 'Học liên tục 7 ngày', 'streak_day', 7),
      (4, 'Người học chăm chỉ', '⭐', 'Hoàn thành 10 mẫu', 'total_fold', 10);
    `);

    // 10. Tạo bảng user_badges
    await connection.query(`
      CREATE TABLE IF NOT EXISTS user_badges (
        user_id INT NOT NULL,
        badge_id INT NOT NULL,
        earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (user_id, badge_id),
        FOREIGN KEY (badge_id) REFERENCES badges(id) ON DELETE CASCADE
      );
    `);

    // 11. Tạo bảng daily_challenges
    await connection.query(`
      CREATE TABLE IF NOT EXISTS daily_challenges (
        id INT AUTO_INCREMENT PRIMARY KEY,
        date DATE NOT NULL UNIQUE,
        origami_id INT NOT NULL,
        reward_xp INT DEFAULT 100,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (origami_id) REFERENCES origami_models(id) ON DELETE CASCADE
      );
    `);

    // 12. Tạo bảng user_daily_challenge_logs
    await connection.query(`
      CREATE TABLE IF NOT EXISTS user_daily_challenge_logs (
        user_id INT NOT NULL,
        challenge_id INT NOT NULL,
        is_completed TINYINT(1) DEFAULT 0,
        completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (user_id, challenge_id),
        FOREIGN KEY (challenge_id) REFERENCES daily_challenges(id) ON DELETE CASCADE
      );
    `);

    // 13. Tạo bảng daily_learning_statistics
    await connection.query(`
      CREATE TABLE IF NOT EXISTS daily_learning_statistics (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        date DATE NOT NULL,
        duration_minutes INT DEFAULT 0 COMMENT 'Thời lượng học (phút)',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY uq_user_date (user_id, date)
      );
    `);

    // 14. Kiểm tra xem có dữ liệu Origami mẫu chưa, nếu chưa có thì chèn vài mẫu mẫu cho đẹp mắt
    const [origamiCount] = await connection.query('SELECT COUNT(*) as count FROM origami_models');
    if (origamiCount[0].count === 0) {
      console.log('🌱 Đang chèn các mẫu Origami mẫu...');
      
      // Tạo một admin user mặc định để sở hữu các bài mẫu (Mật khẩu: 123456)
      // password_hash của '123456' sử dụng bcrypt là '$2a$10$iMh7i92sTkyr45/yM.hZ9.fH0u1f4PZzQ6.J8wTteVzHh/lJqM3aO' (hoặc tương tự)
      const mockAdminPasswordHash = '$2a$10$iMh7i92sTkyr45/yM.hZ9.fH0u1f4PZzQ6.J8wTteVzHh/lJqM3aO';
      const [adminResult] = await connection.query(
        "INSERT IGNORE INTO users (id, email, password_hash, display_name, role, xp) VALUES (1, 'admin@origami.com', ?, 'Admin trang gấp giấy', 'admin', 500)",
        [mockAdminPasswordHash]
      );
      
      // Lấy admin_id (bằng 1)
      const adminId = 1;

      // Chèn các mẫu
      const [heartResult] = await connection.query(
        `INSERT INTO origami_models (id, name, emoji, difficulty, estimated_time, paper_size, paper_type, category_id, creator_id, status, rating) 
         VALUES (1, 'Trái Tim', '❤️', 'Dễ', 8, '15x15 cm', 'Washi', 3, ?, 'approved', 4.6)`,
        [adminId]
      );

      const [swanResult] = await connection.query(
        `INSERT INTO origami_models (id, name, emoji, difficulty, estimated_time, paper_size, paper_type, category_id, creator_id, status, rating) 
         VALUES (2, 'Hạc Giấy', 'swan', 'Trung bình', 15, '15x15 cm', 'Washi', 1, ?, 'approved', 4.9)`,
        [adminId]
      );
      // Sửa emoji hạc thành 🦢
      await connection.query("UPDATE origami_models SET emoji = ' Swan ' WHERE id = 2");

      const [dragonResult] = await connection.query(
        `INSERT INTO origami_models (id, name, emoji, difficulty, estimated_time, paper_size, paper_type, category_id, creator_id, status, rating) 
         VALUES (3, 'Rồng Lửa', '🐲', 'Khó', 60, '20x20 cm', 'Kami', 1, ?, 'approved', 5.0)`,
        [adminId]
      );

      // Chèn các bước gấp cho Trái Tim
      await connection.query(`
        INSERT INTO origami_steps (origami_id, step_number, instruction, tip) VALUES 
        (1, 1, 'Gấp đôi tờ giấy theo đường chéo rồi mở ra để lấy nếp.', 'Nên miết nhẹ tay trước.'),
        (1, 2, 'Gấp mép dưới lên trùng với nếp gấp trung tâm.', 'Hãy căn thật chuẩn.'),
        (1, 3, 'Gấp hai bên cánh lên trên tạo thành hình trái tim.', 'Miết mạnh mép gấp để giữ nếp.');
      `);

      // Chèn các bước gấp cho Hạc Giấy
      await connection.query(`
        INSERT INTO origami_steps (origami_id, step_number, instruction, tip) VALUES 
        (2, 1, 'Bắt đầu với nếp gấp vuông cơ bản.', 'Dùng giấy hai mặt màu khác nhau để dễ gấp.'),
        (2, 2, 'Gấp 4 góc của tờ giấy vào trung tâm.', 'Đảm bảo nếp gấp thẳng và sắc nét.'),
        (2, 3, 'Gấp ngược cánh lên để tạo mỏ và đuôi hạc.', 'Nhẹ tay để tránh làm rách giấy.');
      `);

      console.log('✅ Đã tạo dữ liệu mẫu Origami thành công!');
    }

    console.log('✅ Khởi tạo Cơ sở dữ liệu và dữ liệu ban đầu hoàn tất!');
  } catch (error) {
    console.error('❌ Lỗi trong quá trình khởi tạo Cơ sở dữ liệu:', error.message);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

module.exports = initializeDatabase;
