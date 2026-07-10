const db = require('../config/db');

// 1. Lấy danh sách danh mục
async function getCategories(req, res) {
  try {
    const [rows] = await db.query('SELECT * FROM categories');
    res.status(200).json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy danh mục', error: error.message });
  }
}

// 2. Thêm danh mục mới
async function addCategory(req, res) {
  const { name, emoji, imageUrl } = req.body;
  try {
    await db.query('INSERT INTO categories (name, emoji, image_url) VALUES (?, ?, ?)', [name, emoji, imageUrl]);
    res.status(201).json({ message: 'Thêm danh mục thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi thêm danh mục', error: error.message });
  }
}

// 3. Cập nhật danh mục
async function updateCategory(req, res) {
  const { id } = req.params;
  const { name, emoji, imageUrl } = req.body;
  try {
    await db.query('UPDATE categories SET name = ?, emoji = ?, image_url = ? WHERE id = ?', [name, emoji, imageUrl, id]);
    res.status(200).json({ message: 'Cập nhật danh mục thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi cập nhật danh mục', error: error.message });
  }
}

// 4. Xóa danh mục
async function deleteCategory(req, res) {
  const { id } = req.params;
  try {
    await db.query('DELETE FROM categories WHERE id = ?', [id]);
    res.status(200).json({ message: 'Xóa danh mục thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi xóa danh mục', error: error.message });
  }
}

// 5. Cập nhật thông tin mẫu Origami (XP, độ khó...)
async function updateOrigamiModel(req, res) {
  const { id } = req.params;
  const { difficulty, rating, status } = req.body;
  try {
    await db.query(
      'UPDATE origami_models SET difficulty = ?, rating = ?, status = ? WHERE id = ?',
      [difficulty, rating, status, id]
    );
    res.status(200).json({ message: 'Cập nhật mẫu Origami thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi cập nhật mẫu Origami', error: error.message });
  }
}

// 6. Lấy danh sách người dùng (Admin)
async function getUsers(req, res) {
  try {
    const [rows] = await db.query('SELECT id, email, display_name, role, xp, streak_count, created_at FROM users WHERE role != "admin"');
    res.status(200).json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy danh sách người dùng', error: error.message });
  }
}

// 7. Cập nhật XP người dùng (Admin)
async function updateUserXP(req, res) {
  const { id } = req.params;
  const { xp } = req.body;
  try {
    await db.query('UPDATE users SET xp = ? WHERE id = ?', [xp, id]);
    res.status(200).json({ message: 'Cập nhật XP thành công' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi cập nhật XP', error: error.message });
  }
}

module.exports = {
  getCategories,
  addCategory,
  updateCategory,
  deleteCategory,
  updateOrigamiModel,
  getUsers,
  updateUserXP
};
