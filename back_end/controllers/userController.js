const db = require('../config/db');
const bcrypt = require('bcryptjs');

// Helper check và mở khóa huy hiệu động dựa trên số mẫu hoàn thành (mỗi 5 mẫu = 1 huy hiệu mới)
async function checkAndUnlockBadges(userId) {
  const unlockedBadges = [];
  try {
    const [progressRows] = await db.query(
      "SELECT COUNT(*) as completed_count FROM user_progress WHERE user_id = ? AND is_completed = 1",
      [userId]
    );
    const completedCount = progressRows[0].completed_count;

    // Huy hiệu 1: Hoàn thành 1 mẫu đầu tiên (Người mới)
    if (completedCount >= 1) {
      const [r] = await db.query("INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, 1)", [userId]);
      if (r.affectedRows > 0) unlockedBadges.push(1);
    }
    // Huy hiệu 2: Hoàn thành 5 mẫu (Tân binh gấp giấy)
    if (completedCount >= 5) {
      const [r] = await db.query("INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, 2)", [userId]);
      if (r.affectedRows > 0) unlockedBadges.push(2);
    }
    // Huy hiệu 3: Hoàn thành 10 mẫu (Thợ gấp giấy)
    if (completedCount >= 10) {
      const [r] = await db.query("INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, 3)", [userId]);
      if (r.affectedRows > 0) unlockedBadges.push(3);
    }
    // Huy hiệu 4: Hoàn thành 15 mẫu (Nghệ nhân Origami)
    if (completedCount >= 15) {
      const [r] = await db.query("INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, 4)", [userId]);
      if (r.affectedRows > 0) unlockedBadges.push(4);
    }
    // Huy hiệu 5: Hoàn thành 20 mẫu (Bậc thầy Origami)
    if (completedCount >= 20) {
      const [r] = await db.query("INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, 5)", [userId]);
      if (r.affectedRows > 0) unlockedBadges.push(5);
    }
    // Huy hiệu 6: Hoàn thành 30 mẫu (Huyền thoại Origami)
    if (completedCount >= 30) {
      const [r] = await db.query("INSERT IGNORE INTO user_badges (user_id, badge_id) VALUES (?, 6)", [userId]);
      if (r.affectedRows > 0) unlockedBadges.push(6);
    }
  } catch (err) {
    console.error('Lỗi kiểm tra mở khóa huy hiệu:', err.message);
  }
  return unlockedBadges;
}

// 5. Lấy danh sách huy hiệu của user
async function getUserBadges(req, res) {
  const userId = req.user.id;
  try {
    const [allBadges] = await db.query('SELECT * FROM badges');
    const [userBadges] = await db.query('SELECT badge_id, earned_at FROM user_badges WHERE user_id = ?', [userId]);

    const userBadgeIds = userBadges.map(b => b.badge_id);

    const result = allBadges.map(badge => ({
      ...badge,
      earned: userBadgeIds.includes(badge.id),
      earned_at: userBadges.find(ub => ub.badge_id === badge.id)?.earned_at || null
    }));

    res.status(200).json(result);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy huy hiệu!', error: error.message });
  }
}

// 6. Lấy phân tích học tập (XP, Completed, Favorites, Streak)
async function getUserAnalytics(req, res) {
  const userId = req.user.id;
  try {
    const [user] = await db.query('SELECT xp, streak_count FROM users WHERE id = ?', [userId]);
    const [completed] = await db.query('SELECT COUNT(*) as count FROM user_progress WHERE user_id = ? AND is_completed = 1', [userId]);
    const [favorites] = await db.query('SELECT COUNT(*) as count FROM favorites WHERE user_id = ?', [userId]);
    const [badges] = await db.query('SELECT COUNT(*) as count FROM user_badges WHERE user_id = ?', [userId]);

    res.status(200).json({
      xp: user[0].xp,
      streakCount: user[0].streak_count,
      completedCount: completed[0].count,
      favoritesCount: favorites[0].count,
      badgesCount: badges[0].count
    });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy phân tích!', error: error.message });
  }
}

// 0. Lấy thông tin cá nhân của User (XP, Streak,...)
async function getProfile(req, res) {
  const userId = req.user.id;
  try {
    const [rows] = await db.query(
      'SELECT id, email, display_name, role, avatar_url, xp, streak_count, daily_medals, weekly_trophies FROM users WHERE id = ?',
      [userId]
    );
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Không tìm thấy người dùng!' });
    }
    res.status(200).json(rows[0]);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy thông tin cá nhân!', error: error.message });
  }
}

// 0.1 Cập nhật thông tin cá nhân
async function updateProfile(req, res) {
  const userId = req.user.id;
  const { displayName, avatarUrl, email, password } = req.body;
  try {
    let sql = 'UPDATE users SET display_name = ?, avatar_url = ?';
    const params = [displayName, avatarUrl || ''];

    if (email) {
      // Kiểm tra trùng lặp email
      const [existing] = await db.query('SELECT id FROM users WHERE email = ? AND id != ?', [email, userId]);
      if (existing.length > 0) {
        return res.status(400).json({ message: 'Email này đã được sử dụng bởi người dùng khác!' });
      }
      sql += ', email = ?';
      params.push(email);
    }

    if (password && password.toString().trim() !== '') {
      const salt = bcrypt.genSaltSync(10);
      const passwordHash = bcrypt.hashSync(password.toString().trim(), salt);
      sql += ', password_hash = ?';
      params.push(passwordHash);
    }

    sql += ' WHERE id = ?';
    params.push(userId);

    await db.query(sql, params);
    res.status(200).json({ message: 'Cập nhật hồ sơ thành công!' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi cập nhật hồ sơ!', error: error.message });
  }
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
  const { currentStep, isCompleted, duration } = req.body;

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
      `INSERT INTO user_progress (user_id, origami_id, current_step, is_completed, completion_duration, completed_at)
       VALUES (?, ?, ?, ?, ?, ?)
       ON DUPLICATE KEY UPDATE 
         current_step = VALUES(current_step),
         is_completed = VALUES(is_completed),
         completion_duration = IF(VALUES(is_completed) = 1, VALUES(completion_duration), completion_duration),
         completed_at = IF(VALUES(is_completed) = 1, NOW(), completed_at)`,
      [userId, origamiId, currentStep, isCompleted ? 1 : 0, duration || 0, completedAt]
    );

    let xpReward = 0;
    let unlockedBadges = [];

    // Luôn ghi nhận thời gian học vào daily_learning_statistics (kể cả chưa hoàn thành)
    if (duration && duration > 0) {
      const today = new Date().toISOString().split('T')[0];
      await db.query(
        `INSERT INTO daily_learning_statistics (user_id, date, duration_minutes)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE duration_minutes = duration_minutes + VALUES(duration_minutes)`,
        [userId, today, Math.ceil(duration / 60)] // duration gửi lên là giây, chuyển sang phút
      );
    }

    // Cộng điểm kinh nghiệm XP nếu hoàn thành mới
    if (isNewlyCompleted) {
      const multiplier = parseInt(req.body.boosterMultiplier) || 1;
      xpReward = 50 * multiplier; // Thưởng nhân với multiplier
      await db.query('UPDATE users SET xp = xp + ? WHERE id = ?', [xpReward, userId]);
      
      // Tạo thông báo hoàn thành
      await db.query(
        'INSERT INTO notifications (user_id, title, message, type, emoji) VALUES (?, ?, ?, ?, ?)',
        [userId, 'Tuyệt vời!', `Bạn đã hoàn thành một mẫu gấp mới và nhận được ${xpReward} XP.`, 'badge', '🏆']
      );

      // Kiểm tra và mở khóa huy hiệu
      unlockedBadges = await checkAndUnlockBadges(userId);
      if (unlockedBadges.length > 0) {
        for (const badgeId of unlockedBadges) {
          const [badgeInfo] = await db.query('SELECT name, emoji FROM badges WHERE id = ?', [badgeId]);
          if (badgeInfo.length > 0) {
            await db.query(
              'INSERT INTO notifications (user_id, title, message, type, emoji) VALUES (?, ?, ?, ?, ?)',
              [userId, 'Huy hiệu mới!', `Bạn vừa mở khóa huy hiệu "${badgeInfo[0].name}".`, 'badge', badgeInfo[0].emoji]
            );
          }
        }
      }
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

// 7. Lấy danh sách thông báo của user
async function getNotifications(req, res) {
  const userId = req.user.id;
  try {
    const [rows] = await db.query(
      'SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 20',
      [userId]
    );
    res.status(200).json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy thông báo!', error: error.message });
  }
}

// 8. Đánh dấu đã đọc thông báo
async function markNotificationRead(req, res) {
  const userId = req.user.id;
  const { id } = req.params;
  try {
    await db.query(
      'UPDATE notifications SET is_read = 1 WHERE id = ? AND user_id = ?',
      [id, userId]
    );
    res.status(200).json({ message: 'Đã đánh dấu thông báo là đã đọc.' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi cập nhật thông báo!', error: error.message });
  }
}

module.exports = {
  getProfile,
  updateProfile,
  getFavorites,
  toggleFavorite,
  getProgress,
  updateProgress,
  getUserBadges,
  getUserAnalytics,
  getNotifications,
  markNotificationRead,
  claimCampaign
};

async function claimCampaign(req, res) {
  const userId = req.user.id;
  const { campId } = req.params;
  try {
    let xpBonus = campId === '1' ? 150 : 200;
    await db.query('UPDATE users SET xp = xp + ? WHERE id = ?', [xpBonus, userId]);
    
    // Tạo thông báo nhận quà
    await db.query(
      'INSERT INTO notifications (user_id, title, message, type, emoji) VALUES (?, ?, ?, ?, ?)',
      [userId, 'Đã nhận thưởng!', `Chúc mừng bạn đã nhận ${xpBonus} XP từ chiến dịch!`, 'badge', '🎁']
    );

    res.status(200).json({ message: 'Claimed successfully', xpBonus });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi nhận phần thưởng chiến dịch!', error: error.message });
  }
}
