const db = require('../config/db');

// 1. Lấy bảng xếp hạng (Leaderboard) theo XP
async function getLeaderboard(req, res) {
  const { type } = req.query; // weekly, monthly, alltime

  try {
    // Để làm bảng xếp hạng đơn giản và tối ưu, ta sắp xếp theo điểm XP tích lũy
    // Trong môi trường production, có thể lưu lịch sử XP theo tuần/tháng, ở đây xếp hạng theo tổng XP
    const limit = 20;
    const [rows] = await db.query(
      `SELECT id, display_name as displayName, avatar_url as avatarUrl, xp, streak_count as streakCount
       FROM users
       WHERE role != 'admin'
       ORDER BY xp DESC
       LIMIT ?`,
      [limit]
    );

    res.status(200).json(rows);
  } catch (error) {
    console.error('Lỗi lấy bảng xếp hạng:', error);
    res.status(500).json({ message: 'Không thể lấy bảng xếp hạng!', error: error.message });
  }
}

// 2. Lấy thống kê chi tiết hành trình học tập (vẽ biểu đồ)
async function getUserAnalytics(req, res) {
  const userId = req.user.id;

  try {
    // 2.1. Lấy thống kê học tập trong tuần (7 ngày gần nhất)
    const [weeklyStats] = await db.query(
      `SELECT date, duration_minutes as duration
       FROM daily_learning_statistics
       WHERE user_id = ? AND date >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)
       ORDER BY date ASC`,
      [userId]
    );

    // Mặc định tạo dữ liệu cho 7 ngày gần nhất nếu chưa có log
    const weekdayMap = {};
    for (let i = 6; i >= 0; i--) {
      const d = new Date();
      d.setDate(d.getDate() - i);
      const dateStr = d.toISOString().split('T')[0];
      weekdayMap[dateStr] = 0;
    }

    weeklyStats.forEach(row => {
      const key = new Date(row.date).toISOString().split('T')[0];
      if (weekdayMap[key] !== undefined) {
        weekdayMap[key] = row.duration;
      }
    });

    const weeklyChart = Object.keys(weekdayMap).map(date => ({
      date,
      duration: weekdayMap[date]
    }));

    // 2.2. Lấy phân bổ thể loại Origami đã hoàn thành (Pie Chart)
    const [categoryStats] = await db.query(
      `SELECT c.name as category, COUNT(up.id) as count
       FROM user_progress up
       JOIN origami_models om ON up.origami_id = om.id
       JOIN categories c ON om.category_id = c.id
       WHERE up.user_id = ? AND up.is_completed = 1
       GROUP BY c.id`,
      [userId]
    );

    res.status(200).json({
      weeklyChart,
      categoryStats
    });
  } catch (error) {
    console.error('Lỗi lấy thống kê học tập:', error);
    res.status(500).json({ message: 'Lỗi lấy thống kê học tập!', error: error.message });
  }
}

// 3. Lấy danh sách đầy đủ các huy hiệu và trạng thái khóa/mở của User
async function getUserBadges(req, res) {
  const userId = req.user.id;

  try {
    // Truy vấn tất cả huy hiệu và xem user đã sở hữu chưa
    const [rows] = await db.query(
      `SELECT b.id, b.name, b.emoji, b.description, 
              IF(ub.user_id IS NOT NULL, 1, 0) as earned,
              ub.earned_at as earnedAt
       FROM badges b
       LEFT JOIN user_badges ub ON b.id = ub.badge_id AND ub.user_id = ?
       ORDER BY b.id ASC`,
      [userId]
    );

    // Convert earned thành boolean
    const formattedBadges = rows.map(r => ({
      ...r,
      earned: r.earned === 1
    }));

    res.status(200).json(formattedBadges);
  } catch (error) {
    console.error('Lỗi lấy danh sách huy hiệu:', error);
    res.status(500).json({ message: 'Lỗi lấy danh sách huy hiệu!', error: error.message });
  }
}

// 4. Lấy thử thách hàng ngày
async function getDailyChallenge(req, res) {
  const userId = req.user.id;
  const today = new Date().toISOString().split('T')[0];

  try {
    // Tìm thử thách đã được cấu hình cho hôm nay
    let [challenges] = await db.query(
      `SELECT dc.*, om.name, om.emoji, om.difficulty, om.estimated_time
       FROM daily_challenges dc
       JOIN origami_models om ON dc.origami_id = om.id
       WHERE dc.date = ?`,
      [today]
    );

    let challenge;

    if (challenges.length === 0) {
      // Nếu hôm nay chưa có thử thách nào được thiết lập -> Chọn ngẫu nhiên 1 mẫu đã duyệt
      const [approvedModels] = await db.query(
        "SELECT id FROM origami_models WHERE status = 'approved' ORDER BY RAND() LIMIT 1"
      );

      if (approvedModels.length === 0) {
        return res.status(404).json({ message: 'Không có mẫu Origami nào khả dụng để tạo thử thách hàng ngày!' });
      }

      const randomOrigamiId = approvedModels[0].id;
      
      // Chèn thử thách mới cho hôm nay
      await db.query(
        "INSERT INTO daily_challenges (date, origami_id, reward_xp) VALUES (?, ?, 100)",
        [today, randomOrigamiId]
      );

      // Query lại để lấy đầy đủ thông tin
      const [newChallengeRows] = await db.query(
        `SELECT dc.*, om.name, om.emoji, om.difficulty, om.estimated_time
         FROM daily_challenges dc
         JOIN origami_models om ON dc.origami_id = om.id
         WHERE dc.date = ?`,
        [today]
      );
      challenge = newChallengeRows[0];
    } else {
      challenge = challenges[0];
    }

    // Kiểm tra xem User đã hoàn thành thử thách hôm nay chưa
    const [logs] = await db.query(
      "SELECT is_completed FROM user_daily_challenge_logs WHERE user_id = ? AND challenge_id = ?",
      [userId, challenge.id]
    );

    challenge.isCompleted = logs.length > 0 && logs[0].is_completed === 1;

    res.status(200).json(challenge);
  } catch (error) {
    console.error('Lỗi lấy thử thách ngày:', error);
    res.status(500).json({ message: 'Lỗi lấy thử thách ngày!', error: error.message });
  }
}

// 5. Xác nhận hoàn thành thử thách hàng ngày, cộng XP và cập nhật Streak
async function completeDailyChallenge(req, res) {
  const userId = req.user.id;
  const todayStr = new Date().toISOString().split('T')[0];

  try {
    // 1. Lấy thử thách hôm nay
    const [challenges] = await db.query("SELECT * FROM daily_challenges WHERE date = ?", [todayStr]);
    if (challenges.length === 0) {
      return res.status(400).json({ message: 'Chưa có thử thách nào được tạo cho ngày hôm nay!' });
    }
    const challenge = challenges[0];

    // 2. Kiểm tra xem đã hoàn thành trước đó chưa
    const [existingLogs] = await db.query(
      "SELECT * FROM user_daily_challenge_logs WHERE user_id = ? AND challenge_id = ?",
      [userId, challenge.id]
    );

    if (existingLogs.length > 0 && existingLogs[0].is_completed === 1) {
      return res.status(400).json({ message: 'Bạn đã hoàn thành thử thách của ngày hôm nay rồi!' });
    }

    // 3. Đánh dấu hoàn thành
    await db.query(
      `INSERT INTO user_daily_challenge_logs (user_id, challenge_id, is_completed)
       VALUES (?, ?, 1)
       ON DUPLICATE KEY UPDATE is_completed = 1, completed_at = NOW()`,
      [userId, challenge.id]
    );

    // 4. Cộng điểm XP thưởng
    const rewardXp = challenge.reward_xp || 100;
    await db.query("UPDATE users SET xp = xp + ? WHERE id = ?", [rewardXp, userId]);

    // 5. Cập nhật Streak ngày liên tiếp của người dùng
    const [userRows] = await db.query("SELECT streak_count, last_active_date FROM users WHERE id = ?", [userId]);
    const user = userRows[0];
    let newStreak = user.streak_count || 0;

    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    const yesterdayStr = yesterday.toISOString().split('T')[0];

    if (user.last_active_date === yesterdayStr) {
      // Hoạt động ngày tiếp theo -> Tăng streak
      newStreak += 1;
    } else if (user.last_active_date === todayStr) {
      // Đã hoạt động hôm nay rồi -> Giữ nguyên streak
    } else {
      // Đứt chuỗi -> Reset streak về 1
      newStreak = 1;
    }

    await db.query(
      "UPDATE users SET streak_count = ?, last_active_date = ? WHERE id = ?",
      [newStreak, todayStr, userId]
    );

    // 6. Kiểm tra mở khóa huy hiệu (Đặc biệt: chuỗi 7 ngày)
    let unlockedBadges = [];
    if (newStreak >= 7) {
      const [badgeRes] = await db.query(
        "INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, 3)",
        [userId]
      );
      if (badgeRes.affectedRows > 0) {
        unlockedBadges.push(3);
      }
    }

    // Thêm log thời gian học ngày hôm nay (giả định hoàn thành thử thách mất 15 phút)
    await db.query(
      `INSERT INTO daily_learning_statistics (user_id, date, duration_minutes)
       VALUES (?, ?, 15)
       ON DUPLICATE KEY UPDATE duration_minutes = duration_minutes + 15`,
      [userId, todayStr]
    );

    res.status(200).json({
      message: 'Xin chúc mừng! Bạn đã hoàn thành thử thách hàng ngày thành công!',
      rewardXp,
      newStreak,
      unlockedBadges
    });
  } catch (error) {
    console.error('Lỗi hoàn thành thử thách ngày:', error);
    res.status(500).json({ message: 'Lỗi hoàn thành thử thách ngày!', error: error.message });
  }
}

module.exports = {
  getLeaderboard,
  getUserAnalytics,
  getUserBadges,
  getDailyChallenge,
  completeDailyChallenge
};
