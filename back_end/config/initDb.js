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
        daily_medals INT DEFAULT 0,
        weekly_trophies INT DEFAULT 0,
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
        image_url VARCHAR(255) DEFAULT NULL,
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
        difficulty ENUM('Dễ', 'Trung bình', 'Khó', 'Cực khó') DEFAULT 'Dễ',
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
        estimated_duration INT DEFAULT 0 COMMENT 'Thời gian gợi ý cho bước này (giây)',
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
        completion_duration INT DEFAULT 0 COMMENT 'Thời gian hoàn thành tính bằng giây',
        completed_at TIMESTAMP NULL DEFAULT NULL,
        rating DECIMAL(2,1) DEFAULT NULL,
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

    // Chèn huy hiệu mặc định (xóa cũ và thêm mới)
    await connection.query(`
      INSERT IGNORE INTO badges (id, name, emoji, description, condition_type, condition_value) VALUES 
      (1, 'Người mới', '🌱', 'Hoàn thành mẫu gấp đầu tiên của bạn!', 'total_fold', 1),
      (2, 'Tân binh gấp giấy', '🐣', 'Hoàn thành 5 mẫu gấp', 'total_fold', 5),
      (3, 'Thợ gấp giấy', '⭐', 'Hoàn thành 10 mẫu gấp - bạn đang tiến bộ!', 'total_fold', 10),
      (4, 'Nghệ nhân Origami', '🎭', 'Hoàn thành 15 mẫu gấp - bạn thực sự đam mê!', 'total_fold', 15),
      (5, 'Bậc thầy Origami', '🏆', 'Hoàn thành 20 mẫu gấp - kỹ năng tuyệt vời!', 'total_fold', 20),
      (6, 'Huyền thoại Origami', '👑', 'Hoàn thành 30 mẫu gấp - bạn là huyền thoại!', 'total_fold', 30);
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

    // 14. Tạo bảng support_messages (cho chat hỗ trợ thực tế giữa Admin và User)
    await connection.query(`
      CREATE TABLE IF NOT EXISTS support_messages (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        sender_id INT NOT NULL,
        message TEXT NOT NULL,
        is_read TINYINT(1) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE CASCADE
      );
    `);

    // 15. Tạo bảng notifications
    await connection.query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        type VARCHAR(50) DEFAULT 'info',
        emoji VARCHAR(10) DEFAULT '🔔',
        is_read TINYINT(1) DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      );
    `);

    // 14. Kiểm tra xem có dữ liệu Origami mẫu chưa, nếu chưa có thì chèn vài mẫu mẫu cho đẹp mắt
    const [origamiCount] = await connection.query('SELECT COUNT(*) as count FROM origami_models');
    if (origamiCount[0].count === 0) {
      console.log('🌱 Đang chèn các mẫu Origami mẫu...');
      
      // Tạo một admin user mặc định để sở hữu các bài mẫu (Mật khẩu: 123456)
      const mockAdminPasswordHash = '$2a$10$sDmHJ96MVOHjhJZUT79Ki.Xd40DvI2Xlt8silKpnrl7MHjLwvvh6m';
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

      // Chèn 10 mẫu Origami mới chưa có đánh giá (rating = 0.0)
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
        await connection.query(
          `INSERT INTO origami_models (id, name, emoji, difficulty, estimated_time, paper_size, paper_type, category_id, creator_id, status, rating) 
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'approved', 0.0)`,
          [m.id, m.name, m.emoji, m.difficulty, m.time, m.paper_size, m.paper_type, m.category_id, adminId]
        );
      // Định nghĩa dữ liệu hướng dẫn gấp thực tế chi tiết
      const heartSteps = [
        { step: 1, text: 'Chuẩn bị một tờ giấy hình vuông màu đỏ (15x15 cm). Đặt mặt màu úp xuống. Gấp đôi tờ giấy theo đường chéo tạo thành hình tam giác lớn, miết phẳng nếp gấp rồi mở ra.', tip: 'Hãy miết nếp gấp thật thẳng và chính xác ở đường chéo chính.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-1.png' },
        { step: 2, text: 'Xoay tờ giấy và tiếp tục gấp đôi theo đường chéo còn lại để tạo thành 2 đường nếp gấp chéo cắt nhau ở tâm. Mở tờ giấy phẳng ra.', tip: 'Đảm bảo giao điểm của 2 nếp gấp nằm đúng trung tâm tờ giấy.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-2.png' },
        { step: 3, text: 'Gấp đỉnh góc trên cùng của tờ giấy xuống sao cho chạm đúng vào tâm chính giữa (giao điểm của 2 nếp gấp chéo).', tip: 'Đỉnh góc nhọn phải nằm chuẩn xác trên điểm tâm.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-3.png' },
        { step: 4, text: 'Gấp góc dưới cùng của tờ giấy hướng lên trên sao cho đỉnh góc chạm vào cạnh ngang ở phần đầu trên của tờ giấy.', tip: 'Góc nhọn dưới cùng phải đi thẳng qua trục dọc trung tâm.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-4.png' },
        { step: 5, text: 'Gấp cạnh bên dưới bên trái hướng lên trên theo đường nếp gấp dọc trung tâm.', tip: 'Cạnh gấp xiên sẽ khớp khít với trục nếp gấp dọc ở giữa.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-5.png' },
        { step: 6, text: 'Gấp cạnh bên dưới bên phải tương tự hướng lên trên theo đường nếp gấp dọc trung tâm. Lúc này hình dáng trái tim cơ bản đã lộ ra.', tip: 'Hãy căn chỉnh hai bên thật đối xứng để trái tim cân đối.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-6.png' },
        { step: 7, text: 'Lật mặt sau của trái tim lại để chuẩn bị bo các góc nhọn của trái tim cho tròn trịa.', tip: 'Giữ chặt các nếp gấp trước đó để không bị xô lệch khi lật.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-7.png' },
        { step: 8, text: 'Gấp hai góc nhọn ở đỉnh phía trên xuống dưới khoảng 1-2 cm để tạo hình bo tròn cho phần đầu của trái tim.', tip: 'Gấp hai đỉnh bằng nhau để hai nửa trái tim cao bằng nhau.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-8.png' },
        { step: 9, text: 'Gấp hai góc nhọn ở hai bên rìa trái và phải hướng vào trong một chút để làm thon gọn dáng trái tim.', tip: 'Chỉ cần gấp một góc nhỏ để bo tròn cạnh hông của trái tim.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-9.png' },
        { step: 10, text: 'Lật ngược lại mặt trước. Xin chúc mừng! Bạn đã hoàn thành một Trái Tim Origami vô cùng dễ thương và ý nghĩa.', tip: 'Dùng tay vuốt nhẹ mặt trước cho phẳng phiu và cân đối.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-10.png' }
      ];

      const swanSteps = [
        { step: 1, text: 'Đặt mặt màu tờ giấy hình vuông lên trên. Gấp đôi tờ giấy theo đường chéo tạo thành hình tam giác lớn rồi mở ra để lấy nếp gấp chéo chính giữa.', tip: 'Đường chéo này sẽ làm chuẩn cho các bước tiếp theo.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-1.png' },
        { step: 2, text: 'Gấp hai cạnh dưới bên trái và bên phải hướng vào trong sao cho trùng khít với nếp gấp chéo chính giữa vừa tạo ở Bước 1. Tạo hình giống chiếc diều.', tip: 'Hãy miết phẳng và sát nếp gấp để các góc nhọn ở đuôi thật sắc nét.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-2.png' },
        { step: 3, text: 'Lật mặt sau của tờ giấy lại.', tip: 'Nhớ giữ nguyên nếp gấp của mặt trước khi lật.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-3.png' },
        { step: 4, text: 'Tiếp tục gấp hai cạnh bên ngoài hướng vào đường nếp gấp dọc ở chính giữa một lần nữa để làm thon gọn thân chú chim hạc.', tip: 'Hãy căn chỉnh thật khít và miết mạnh tay.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-4.png' },
        { step: 5, text: 'Gấp đỉnh góc nhọn phía dưới lên trên sao cho trùng khít với đỉnh góc nhọn phía trên cùng.', tip: 'Đường gấp ngang này sẽ chia đôi chiều dài của thân hạc.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-5.png' },
        { step: 6, text: 'Gấp ngược một phần nhỏ của đầu nhọn đó xuống dưới khoảng 2 cm để tạo hình chiếc mỏ cho chú hạc.', tip: 'Đây chính là phần đầu và mỏ của chim hạc.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-6.png' },
        { step: 7, text: 'Gấp đôi toàn bộ cấu trúc theo chiều dọc từ trái sang phải dọc theo nếp gấp trục giữa.', tip: 'Giữ chặt phần đầu và cổ hạc bên trong khi gấp đôi lại.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-7.png' },
        { step: 8, text: 'Kéo nhẹ nhàng phần cổ và đầu của hạc (phần có mỏ nhọn) hướng xiên lên trên một chút để tạo tư thế đứng kiêu hãnh.', tip: 'Kéo từ từ để tránh làm rách giấy ở phần nách gấp.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-8.png' },
        { step: 9, text: 'Miết phẳng nếp gấp ở phần chân cổ để cố định tư thế cho chú hạc. Kéo nhẹ phần mỏ chim nằm ngang ra.', tip: 'Tạo nếp gấp sắc nét ở cổ hạc để chú hạc có thể đứng vững.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-9.png' },
        { step: 10, text: 'Chỉnh sửa hai bên cánh rộng ra một chút. Bạn đã hoàn thành chú Hạc Origami tuyệt đẹp và thanh thoát!', tip: 'Đặt chú hạc lên bàn phẳng để kiểm tra độ cân bằng.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-10.png' }
      ];

      const modelStepsMap = {
        3: [
          { step: 1, text: 'Bắt đầu bằng cách gấp đôi tờ giấy vuông màu cam theo chiều dọc và ngang để lấy nếp gấp dấu cộng.', tip: 'Miết nếp gấp phẳng phiu.', img: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, text: 'Lật mặt sau, gấp hai đường chéo tạo nếp và thu gọn giấy về dạng xếp hình vuông cơ bản (Bird Base).', tip: 'Cần thận giữ các góc giấy cân đối.', img: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, text: 'Gấp các góc của hình vuông vào trong nếp giữa để tạo hình kim cương, thực hiện trên cả hai mặt.', tip: 'Đây là cấu trúc cơ bản của cánh hạc/rồng.', img: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, text: 'Gập đầu nhọn trên cùng xuống dưới để tạo nếp gấp nằm ngang vững chắc.', tip: 'Miết mạnh tay.', img: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, text: 'Mở rộng hai góc bên hông ra và ấn xẹp nếp gấp xuống tạo thành đôi cánh lớn cho rồng.', tip: 'Bước này đòi hỏi sự khéo léo để không làm rách nách cánh.', img: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, text: 'Gập đôi cấu trúc thân rồng dọc theo sống lưng.', tip: 'Đôi cánh hướng ra ngoài.', img: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' },
          { step: 7, text: 'Gấp ngược đầu của rồng tạo tư thế cổ ngẩng cao, tạo nếp gấp xếp ly để làm bờm và sừng rồng.', tip: 'Tạo nếp sừng tinh tế.', img: 'https://images.unsplash.com/photo-1502691876148-a84978e59fa8?q=80&w=400' },
          { step: 8, text: 'Gấp chân rồng ở cả hai bên hông bằng cách gập chéo các góc nhọn phía dưới xuống.', tip: 'Căn chỉnh hai chân trước và hai chân sau đối xứng.', img: 'https://images.unsplash.com/photo-1500485035595-cbe6f645feb1?q=80&w=400' },
          { step: 9, text: 'Uốn cong và gập ngoằn ngoèo phần đuôi rồng để tạo hiệu ứng đuôi rồng lửa sinh động.', tip: 'Tạo nếp uốn mềm mại tự nhiên.', img: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?q=80&w=400' },
          { step: 10, text: 'Mở cánh rồng rộng ra và chỉnh lại dáng đứng vững trên chân. Rồng Lửa Origami huyền thoại đã hoàn thành!', tip: 'Vuốt phẳng đôi cánh để trông oai vệ hơn.', img: 'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?q=80&w=400' }
        ],
        11: [
          { step: 1, text: 'Bắt đầu với tờ giấy hình vuông màu hồng nhạt. Gấp đôi theo đường chéo tạo hình tam giác.', tip: 'Hãy để mặt màu hướng ra ngoài.', img: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, text: 'Gấp một dải mỏng ở cạnh đáy tam giác lên trên khoảng 1.5 cm để tạo nếp tai.', tip: 'Dải này sẽ định hình chiều dài tai thỏ.', img: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, text: 'Gập góc nhọn hai bên hướng lên trên theo trục dọc chính giữa để tạo thành đôi tai thỏ dựng đứng.', tip: 'Đảm bảo hai tai thẳng hàng và bằng nhau.', img: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, text: 'Gập ngược góc nhọn dưới cùng ở cằm thỏ ra phía sau để bo tròn khuôn mặt.', tip: 'Miết phẳng nếp gấp cằm thỏ.', img: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, text: 'Gấp đầu góc nhọn phía trên trán thỏ vào trong để làm phẳng đỉnh đầu.', tip: 'Đôi tai sẽ trông rõ ràng hơn.', img: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, text: 'Lật mặt trước lại và vẽ thêm mắt, mũi xinh xắn cho chú Thỏ Con Origami của bạn!', tip: 'Có thể dùng bút màu vẽ trang trí thêm.', img: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' }
        ],
        12: [
          { step: 1, text: 'Gấp đôi tờ giấy vuông theo cả chiều dọc, chiều ngang và hai đường chéo rồi mở ra để tạo nếp gấp cơ bản.', tip: 'Các nếp gấp chéo rất quan trọng cho thân bướm.', img: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, text: 'Thu gọn giấy theo các nếp gấp chéo để tạo thành hình tam giác kép (Waterbomb Base).', tip: 'Ấn nhẹ ở tâm giấy để thu gọn dễ dàng.', img: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, text: 'Gấp hai góc nhọn ở lớp trên của tam giác hướng lên chạm vào đỉnh nhọn phía trên.', tip: 'Thực hiện đối xứng cả bên trái và bên phải.', img: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, text: 'Lật mặt sau của tam giác lại.', tip: 'Hướng đỉnh tam giác xuống phía dưới.', img: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, text: 'Kéo đỉnh nhọn phía dưới gấp ngược lên trên, để đỉnh nhọn này vượt quá cạnh ngang trên cùng khoảng 1 cm.', tip: 'Hai cạnh bên sẽ tự động căng và cong lên.', img: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, text: 'Gập đỉnh nhọn thừa đó đè qua mép ngang để khóa chặt cấu trúc.', tip: 'Miết thật chặt nếp gấp khóa này.', img: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' },
          { step: 7, text: 'Gập đôi toàn bộ chú bướm dọc theo nếp gấp thân giữa để định hình đôi cánh sinh động.', tip: 'Giữ chặt nếp gấp khóa cằm ở bước trước.', img: 'https://images.unsplash.com/photo-1502691876148-a84978e59fa8?q=80&w=400' },
          { step: 8, text: 'Mở nhẹ đôi cánh ra. Chúc mừng bạn đã hoàn thành một cánh Bướm Xinh Origami sống động!', tip: 'Uốn cong nhẹ đôi cánh để bướm trông tự nhiên hơn.', img: 'https://images.unsplash.com/photo-1500485035595-cbe6f645feb1?q=80&w=400' }
        ],
        13: [
          { step: 1, text: 'Sử dụng giấy vuông màu cam/đỏ. Gấp đôi chéo tờ giấy rồi mở ra lấy nếp gấp trục.', tip: 'Nên dùng giấy 2 mặt màu để đuôi cá nổi bật.', img: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, text: 'Gấp hai cạnh bên ngoài hướng vào nếp gấp dọc trung tâm để tạo hình chiếc diều.', tip: 'Gấp thật phẳng hai mép giấy.', img: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, text: 'Gấp phần góc nhọn phía trên xuống sát mép gấp chéo ngang bên dưới.', tip: 'Đây sẽ là đầu cá vàng.', img: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, text: 'Gấp ngược hai góc nhọn bên hông chéo xuống dưới tạo hình vây cá vàng.', tip: 'Tạo góc chéo khoảng 45 độ.', img: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, text: 'Gập đôi chú cá theo chiều dọc dọc theo nếp gấp chính giữa thân cá.', tip: 'Phần vây cá hướng chéo ra hai bên hông.', img: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, text: 'Gấp chéo phần đuôi cá nhọn phía sau hướng lên trên.', tip: 'Tạo nếp chéo xéo để đuôi vểnh lên.', img: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' },
          { step: 7, text: 'Dùng kéo cắt nhẹ một đường nhỏ ở giữa vây đuôi để tách đuôi thành 2 phần mềm mại.', tip: 'Chỉ cắt một đường thẳng khoảng 3-4 cm.', img: 'https://images.unsplash.com/photo-1502691876148-a84978e59fa8?q=80&w=400' },
          { step: 8, text: 'Tách nhẹ vây đuôi và vẽ thêm mắt tròn xoe. Con Cá Vàng Origami xinh xắn đã bơi lội thành công!', tip: 'Đặt chú cá nằm nghiêng để chụp hình cực xinh.', img: 'https://images.unsplash.com/photo-1500485035595-cbe6f645feb1?q=80&w=400' }
        ],
        14: [
          { step: 1, text: 'Gấp đôi tờ giấy đỏ theo chiều dọc và ngang để tạo nếp gấp chữ thập chính giữa.', tip: 'Đường nếp gấp phải cực kỳ rõ nét.', img: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, text: 'Gập 4 góc nhọn của tờ giấy vuông chạm vào đúng điểm tâm ở trung tâm tờ giấy.', tip: 'Đây gọi là nếp gấp Blintz.', img: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, text: 'Tiếp tục gấp 4 góc nhọn mới vào tâm trung tâm một lần nữa để thu nhỏ kích thước hình vuông.', tip: 'Hãy đè chặt nếp giấy tránh bung ra.', img: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, text: 'Lần thứ ba, gấp cả 4 góc nhọn vào tâm trung tâm để tạo nhiều lớp cánh hoa hồng.', tip: 'Bước này giấy bắt đầu dày, hãy miết bằng cạnh thước.', img: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, text: 'Lật ngược mặt sau của tờ hình vuông dày lại.', tip: 'Giữ chặt phần giấy gấp xếp lớp bên dưới.', img: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, text: 'Gấp tiếp 4 góc nhọn ở mặt sau hướng vào tâm chính giữa.', tip: 'Miết phẳng nếp gấp để định hình đế hoa.', img: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' },
          { step: 7, text: 'Gấp nhẹ 4 đỉnh nhọn ở giữa chéo ngược ra phía ngoài mép giấy.', tip: 'Đây là phần nhụy hoa trong cùng.', img: 'https://images.unsplash.com/photo-1502691876148-a84978e59fa8?q=80&w=400' },
          { step: 8, text: 'Lật nhẹ từng lớp cánh hoa từ phía dưới kéo lộn ngược ra mặt ngoài.', tip: 'Kéo nhẹ nhàng và dùng ngón tay uốn cong cánh hoa hồng.', img: 'https://images.unsplash.com/photo-1500485035595-cbe6f645feb1?q=80&w=400' },
          { step: 9, text: 'Tiếp tục lộn lớp cánh hoa tiếp theo từ phía dưới ra ngoài để tạo độ nở rộ.', tip: 'Uốn cong 4 góc cánh hoa chéo ra ngoài.', img: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?q=80&w=400' },
          { step: 10, text: 'Chỉnh trang lại các lớp cánh hoa cho đều và căng phồng. Bạn đã có đóa Hoa Hồng Origami nở rộ rực rỡ!', tip: 'Có thể làm thêm cành và lá bằng giấy xanh.', img: 'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?q=80&w=400' }
        ],
        15: [
          { step: 1, text: 'Sử dụng giấy vuông xanh lá. Gấp đôi chéo tờ giấy rồi mở ra lấy nếp gấp trục.', tip: 'Dùng giấy xanh sẫm để cây trông chân thật.', img: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, text: 'Gấp hai cạnh bên ngoài hướng vào nếp gấp dọc trung tâm để tạo hình chiếc diều.', tip: 'Miết phẳng nếp gấp từ đỉnh nhọn xuống đáy.', img: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, text: 'Gấp góc nhọn bên dưới chéo lên trên trùng với đỉnh nhọn phía trên.', tip: 'Tờ giấy sẽ tạo thành hình tam giác gọn gàng.', img: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, text: 'Gấp ngược phần chân tam giác xuống dưới chéo tạo nếp gấp xếp ly (Z-fold) làm các tầng lá cây.', tip: 'Gấp ly khoảng 1.5 cm.', img: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, text: 'Lặp lại thao tác gấp xếp ly ly một lần nữa để tạo tầng lá cây thông thứ hai.', tip: 'Hãy căn chỉnh sao cho các tầng lá nhỏ dần lên đỉnh.', img: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, text: 'Lật ngược lại mặt trước, vuốt phẳng các nếp gấp. Cây Thông Noel Origami xinh xắn đã hoàn thiện!', tip: 'Có thể dán thêm một ngôi sao vàng trên đỉnh cây.', img: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' }
        ],
        16: [
          { step: 1, text: 'Sử dụng một tờ giấy hình chữ nhật A4 hoặc A5. Gấp đôi tờ giấy theo chiều ngang.', tip: 'Đường gấp ngang hướng lên trên.', img: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, text: 'Gấp tiếp hai góc trên bên trái và bên phải hướng vào giữa trùng với trục dọc chính.', tip: 'Tờ giấy lúc này trông giống mái nhà.', img: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, text: 'Gấp dải chữ nhật bên dưới hướng lên trên ở cả mặt trước và mặt sau của thuyền.', tip: 'Gấp sát chân mái nhà tam giác.', img: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, text: 'Nhét các góc nhọn thừa của dải giấy chéo vào bên trong để khóa cấu trúc tam giác.', tip: 'Mở rộng lòng tam giác ra rồi xếp xẹp lại thành hình thoi.', img: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, text: 'Gấp góc nhọn bên dưới hướng chéo lên trên ở cả mặt trước và sau để tạo tam giác nhỏ hơn.', tip: 'Tiếp tục mở lòng tam giác và ép phẳng thành hình thoi mới.', img: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, text: 'Dùng hai tay kéo nhẹ nhàng hai góc nhọn phía trên sang hai bên rìa. Thuyền Giấy Origami truyền thống đã lộ diện!', tip: 'Mở rộng khoang thuyền bên dưới để thuyền đứng vững được trên nước.', img: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' }
        ],
        17: [
          { step: 1, text: 'Sử dụng tờ giấy hình chữ nhật A4 phẳng phiu. Gấp đôi tờ giấy theo chiều dọc rồi mở phẳng ra.', tip: 'Miết trục nếp gấp dọc thẳng thớm ở giữa.', img: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, text: 'Gấp hai góc nhọn ở đầu trên hướng vào trong sao cho trùng khít với nếp gấp dọc chính giữa.', tip: 'Tạo thành hình mũi nhọn cơ bản.', img: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, text: 'Gấp toàn bộ phần mũi nhọn tam giác hướng xuống dưới.', tip: 'Phần đỉnh nhọn chạm vào nếp gấp dọc ở đáy.', img: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, text: 'Tiếp tục gấp hai góc ở đầu trên hướng chéo vào nếp gấp dọc trục giữa một lần nữa.', tip: 'Đầu mũi nhọn sẽ nằm bên dưới các mép gấp này.', img: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, text: 'Gấp đỉnh nhọn tam giác nhỏ nằm phía dưới hướng chéo ngược lên để khóa chặt hai cánh máy bay.', tip: 'Miết phẳng nếp gấp khóa này.', img: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, text: 'Gập đôi máy bay ra phía sau dọc theo đường sống giữa, sau đó gập chéo hai bên để tạo cánh rộng. Máy bay đã sẵn sàng cất cánh bay cao!', tip: 'Miết phẳng phần cánh để máy bay bay xa hơn.', img: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' }
        ],
        18: [
          { step: 1, text: 'Gấp đôi tờ giấy vuông màu xanh theo chiều dọc để tạo nếp gấp trung tâm rồi mở ra.', tip: 'Nếp gấp này chia đôi chiều rộng xe tải.', img: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, text: 'Gấp mép giấy bên dưới lên trên khoảng 2 cm để tạo gầm xe và bánh xe.', tip: 'Miết phẳng nếp gấp chân.', img: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, text: 'Gấp hai mép dọc bên trái và bên phải hướng vào nếp gấp trục dọc ở tâm.', tip: 'Tờ giấy tạo thành dải chữ nhật dày đứng.', img: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, text: 'Gập chéo góc trên bên trái hướng xuống dưới tạo hình kính chắn gió và đầu xe tải.', tip: 'Tạo góc nghiêng 45 độ.', img: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, text: 'Gập chéo góc trên bên phải chéo xuống tạo thành phần đuôi xe tải.', tip: 'Gập vừa phải để xe có tỷ lệ cân đối.', img: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, text: 'Gập đôi toàn bộ xe tải theo chiều ngang dọc theo nếp gấp giữa.', tip: 'Các mép gấp ở bước trước nằm phía trong.', img: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' },
          { step: 7, text: 'Dùng bút màu vẽ thêm hai bánh xe hình tròn lớn ở cạnh đáy gầm xe.', tip: 'Tô bánh xe màu đen để nổi bật.', img: 'https://images.unsplash.com/photo-1502691876148-a84978e59fa8?q=80&w=400' },
          { step: 8, text: 'Vẽ thêm kính buồng lái xe và cửa thùng hàng. Xe Tải Giấy Origami siêu đáng yêu đã hoàn thành!', tip: 'Có thể vẽ thêm logo/tên hàng hóa lên thùng xe.', img: 'https://images.unsplash.com/photo-1500485035595-cbe6f645feb1?q=80&w=400' }
        ],
        19: [
          { step: 1, text: 'Sử dụng tờ giấy hình vuông màu xanh da trời. Gấp đôi theo đường chéo để tạo thành hình tam giác lớn nằm ngang.', tip: 'Cạnh gấp nằm ở phía dưới, đỉnh hướng lên trên.', img: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, text: 'Gấp góc nhọn bên dưới bên trái hướng chéo lên chạm vào mép nghiêng chéo đối diện bên phải.', tip: 'Đường gấp nằm song song với cạnh đáy.', img: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, text: 'Gấp tương tự góc nhọn bên phải hướng chéo sang bên trái chạm vào điểm mép nghiêng đối diện bên trái.', tip: 'Hai dải gấp sẽ xếp chéo bắt qua nhau.', img: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, text: 'Gập một lớp giấy góc nhọn ở đỉnh phía trên hướng xuống phía dưới đè chèn qua lớp gấp trước.', tip: 'Đây là vành cốc mặt trước.', img: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, text: 'Lật ngược chiếc cốc lại và tiếp tục gập lớp giấy góc nhọn đỉnh còn lại xuống dưới.', tip: 'Vành cốc mặt sau đã được cố định.', img: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, text: 'Dùng tay bóp nhẹ hai bên hông để mở rộng miệng chiếc Cốc Giấy Origami của bạn ra và đứng vững!', tip: 'Mẫu cốc gấp này có thể đựng được vật nhẹ.', img: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' }
        ],
        20: [
          { step: 1, text: 'Sử dụng một dải giấy dài (kích thước khoảng 1x20 cm) có màu sắc nổi bật.', tip: 'Giấy sao mỏng uốn cong dễ dàng hơn.', img: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, text: 'Uốn cong một đầu dải giấy chéo chèn qua nhau tạo thành một lỗ thắt nút thòng lọng.', tip: 'Tạo nút thắt giống ruy băng.', img: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, text: 'Luồn đầu dải giấy ngắn qua lỗ và rút nhẹ nhàng từ hai đầu thắt nút thắt chặt hình ngũ giác đều.', tip: 'Vuốt phẳng hình ngũ giác đó, gập đầu thừa ngắn luồn vào trong.', img: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, text: 'Gập dải giấy dài quấn quanh các cạnh của hình ngũ giác đều đặn.', tip: 'Dải giấy tự động chạy chéo theo các cạnh.', img: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, text: 'Tiếp tục quấn chéo dải giấy cho đến khi dải giấy chỉ còn thừa khoảng 1.5 cm.', tip: 'Quấn giấy khít với nhau nhưng không quá chặt.', img: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, text: 'Nhét đầu giấy thừa còn lại luồn chui vào khe gấp ngũ giác ở bước trước để giữ chặt dải giấy.', tip: 'Đảm bảo ngũ giác gọn gàng và chắc chắn.', img: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' },
          { step: 7, text: 'Dùng hai ngón tay cái và ngón trỏ bóp mạnh vào 5 trung điểm cạnh của ngũ giác để tạo độ phồng cho ngôi sao.', tip: 'Bóp nhẹ từ từ để các góc phồng lên tròn đều.', img: 'https://images.unsplash.com/photo-1502691876148-a84978e59fa8?q=80&w=400' },
          { step: 8, text: 'Căn chỉnh lại các đỉnh nhọn ngũ giác. Ngôi Sao May Mắn Origami của bạn đã phồng đều cực kỳ dễ thương!', tip: 'Làm thật nhiều ngôi sao bỏ vào lọ thủy tinh ước nguyện nhé.', img: 'https://images.unsplash.com/photo-1500485035595-cbe6f645feb1?q=80&w=400' }
        ]
      };

      // Chèn cho Trái Tim (ID 1)
      for (const s of heartSteps) {
        await connection.query(
          `INSERT INTO origami_steps (origami_id, step_number, instruction, tip, image_url) 
           VALUES (1, ?, ?, ?, ?)`,
          [s.step, s.text, s.tip, s.img]
        );
      }

      // Chèn cho Hạc Giấy (ID 2)
      for (const s of swanSteps) {
        await connection.query(
          `INSERT INTO origami_steps (origami_id, step_number, instruction, tip, image_url) 
           VALUES (2, ?, ?, ?, ?)`,
          [s.step, s.text, s.tip, s.img]
        );
      }

      // Chèn cho các mẫu còn lại
      for (const mId of Object.keys(modelStepsMap)) {
        const steps = modelStepsMap[mId];
        for (const s of steps) {
          await connection.query(
            `INSERT INTO origami_steps (origami_id, step_number, instruction, tip, image_url) 
             VALUES (?, ?, ?, ?, ?)`,
            [mId, s.step, s.text, s.tip, s.img]
          );
        }
      }


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
