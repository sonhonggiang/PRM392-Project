const db = require('../config/db');

// Helper check và mở khóa huy hiệu động dựa trên thành tích của User
async function checkAndUnlockBadges(userId) {
  const unlockedBadges = [];
  try {
    // 1. Kiểm tra huy hiệu 1 (Người mới - hoàn thành 1 bài đầu tiên)
    const [progressRows] = await db.query(
      "SELECT COUNT(*) as completed_count FROM user_progress WHERE user_id = ? AND is_completed = 1",
      [userId]
    );
    const completedCount = progressRows[0].completed_count;

    if (completedCount >= 1) {
      const [insertRes] = await db.query(
        "INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, 1)",
        [userId]
      );
      if (insertRes.affectedRows > 0) unlockedBadges.push(1);
    }

    // 2. Kiểm tra huy hiệu 4 (Người học chăm chỉ - hoàn thành 10 bài)
    if (completedCount >= 10) {
      const [insertRes] = await db.query(
        "INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, 4)",
        [userId]
      );
      if (insertRes.affectedRows > 0) unlockedBadges.push(4);
    }

    // 3. Kiểm tra huy hiệu 2 (Fan Hạc Giấy - gấp hạc giấy 5 lần)
    // Giả sử có origami_id của mẫu Hạc Giấy, hoặc ta đếm số lần hoàn thành các mẫu có tên 'Hạc Giấy'
    const [swanRows] = await db.query(
      `SELECT COUNT(*) as swan_count 
       FROM user_progress up
       JOIN origami_models om ON up.origami_id = om.id
       WHERE up.user_id = ? AND up.is_completed = 1 AND om.name LIKE '%Hạc%'`,
      [userId]
    );
    if (swanRows[0].swan_count >= 5) {
      const [insertRes] = await db.query(
        "INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, 2)",
        [userId]
      );
      if (insertRes.affectedRows > 0) unlockedBadges.push(2);
    }

    // 4. Kiểm tra huy hiệu 3 (Chuỗi 7 ngày liên tiếp - streak_count >= 7)
    const [userRows] = await db.query("SELECT streak_count FROM users WHERE id = ?", [userId]);
    if (userRows.length > 0 && userRows[0].streak_count >= 7) {
      const [insertRes] = await db.query(
        "INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, 3)",
        [userId]
      );
      if (insertRes.affectedRows > 0) unlockedBadges.push(3);
    }

  } catch (err) {
    console.error('Lỗi kiểm tra mở khóa huy hiệu:', err.message);
  }
  return unlockedBadges;
}

// 1. Lấy danh sách mẫu yêu thích
async function getFavorites(req, res) {
  const userId = req.user.id;

  try {
    const [rows] = await db.query(
      `SELECT om.*, c.name as category_name, c.emoji as category_emoji
       FROM favorites f
       JOIN origami_models om ON f.origami_id = om.id
       JOIN categories c ON om.category_id = c.id
       WHERE f.user_id = ? AND om.status = 'approved'`,
      [userId]
    );
    res.status(200).json(rows);
  } catch (error) {
    console.error('Lỗi lấy mục yêu thích:', error);
    res.status(500).json({ message: 'Lỗi hệ thống khi lấy danh sách yêu thích!', error: error.message });
  }
}

// 2. Thêm hoặc xóa khỏi danh sách yêu thích (Toggle)
async function toggleFavorite(req, res) {
  const userId = req.user.id;
  const { origamiId } = req.params;

  try {
    // Kiểm tra xem đã yêu thích chưa
    const [rows] = await db.query(
      'SELECT 1 FROM favorites WHERE user_id = ? AND origami_id = ?',
      [userId, origamiId]
    );

    if (rows.length > 0) {
      // Đã có -> Xóa đi
      await db.query(
        'DELETE FROM favorites WHERE user_id = ? AND origami_id = ?',
        [userId, origamiId]
      );
      return res.status(200).json({ message: 'Đã bỏ yêu thích mẫu Origami này!', isFavorite: false });
    } else {
      // Chưa có -> Thêm mới
      await db.query(
        'INSERT INTO favorites (user_id, origami_id) VALUES (?, ?)',
        [userId, origamiId]
      );
      return res.status(200).json({ message: 'Đã thêm mẫu Origami vào danh sách yêu thích!', isFavorite: true });
    }
  } catch (error) {
    console.error('Lỗi toggle yêu thích:', error);
    res.status(500).json({ message: 'Lỗi khi cập nhật mục yêu thích!', error: error.message });
  }
}

// 3. Lấy tiến trình học tập của User
async function getProgress(req, res) {
  const userId = req.user.id;

  try {
    const [rows] = await db.query(
      `SELECT up.*, om.name, om.emoji, om.difficulty, om.estimated_time
       FROM user_progress up
       JOIN origami_models om ON up.origami_id = om.id
       WHERE up.user_id = ?`,
      [userId]
    );
    res.status(200).json(rows);
  } catch (error) {
    console.error('Lỗi lấy tiến trình học tập:', error);
    res.status(500).json({ message: 'Lỗi hệ thống khi lấy tiến trình học tập!', error: error.message });
  }
}

// 4. Cập nhật tiến trình học tập (đang gấp hoặc hoàn thành)
async function updateProgress(req, res) {
  const userId = req.user.id;
  const { origamiId } = req.params;
  const { currentStep, isCompleted } = req.body;

  if (currentStep === undefined || isCompleted === undefined) {
    return res.status(400).json({ message: 'Vui lòng cung cấp currentStep và isCompleted!' });
  }

  try {
    // Kiểm tra trạng thái tiến trình hiện tại
    const [existingProgress] = await db.query(
      'SELECT is_completed FROM user_progress WHERE user_id = ? AND origami_id = ?',
      [userId, origamiId]
    );

    let alreadyCompleted = false;
    if (existingProgress.length > 0) {
      alreadyCompleted = existingProgress[0].is_completed === 1;
    }

    const isNewlyCompleted = isCompleted && !alreadyCompleted;
    const completedAt = isNewlyCompleted ? new Date() : null;

    // Chèn hoặc cập nhật tiến trình
    await db.query(
      `INSERT INTO user_progress (user_id, origami_id, current_step, is_completed, completed_at)
       VALUES (?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE 
         current_step = VALUES(current_step),
         is_completed = VALUES(is_completed),
         completed_at = IF(VALUES(is_completed) = 1, NOW(), completed_at)`,
      [userId, origamiId, currentStep, isCompleted ? 1 : 0, completedAt]
    );

    let xpReward = 0;
    let unlockedBadges = [];

    // Cộng điểm kinh nghiệm XP nếu hoàn thành mới
    if (isNewlyCompleted) {
      xpReward = 50; // Thưởng 50 XP khi hoàn thành gấp 1 mẫu
      await db.query('UPDATE users SET xp = xp + ? WHERE id = ?', [xpReward, userId]);
      
      // Kiểm tra và mở khóa huy hiệu
      unlockedBadges = await checkAndUnlockBadges(userId);
    }

    res.status(200).json({
      message: 'Cập nhật tiến trình học tập thành công!',
      xpReward,
      unlockedBadges,
      isCompleted: isCompleted
    });
  } catch (error) {
    console.error('Lỗi cập nhật tiến trình học:', error);
    res.status(500).json({ message: 'Lỗi cập nhật tiến trình!', error: error.message });
  }
}

module.exports = {
  getFavorites,
  toggleFavorite,
  getProgress,
  updateProgress
};
