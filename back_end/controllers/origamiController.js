const db = require('../config/db');

// 1. Lấy danh sách mẫu Origami (đã duyệt)
async function getAllOrigami(req, res) {
  const { search, category, sortBy } = req.query;
  
  let sql = `
    SELECT om.*, c.name as category_name, c.emoji as category_emoji 
    FROM origami_models om
    JOIN categories c ON om.category_id = c.id
    WHERE om.status = 'approved'
  `;
  const params = [];

  if (search) {
    sql += ` AND om.name LIKE ?`;
    params.push(`%${search}%`);
  }

  if (category) {
    sql += ` AND c.name = ?`;
    params.push(category);
  }

  if (sortBy === 'rating') {
    sql += ` ORDER BY om.rating DESC`;
  } else if (sortBy === 'newest') {
    sql += ` ORDER BY om.created_at DESC`;
  } else {
    sql += ` ORDER BY om.name ASC`;
  }

  try {
    const [rows] = await db.query(sql, params);
    res.status(200).json(rows);
  } catch (error) {
    console.error('Lỗi lấy danh sách Origami:', error);
    res.status(500).json({ message: 'Không thể lấy danh sách mẫu Origami!', error: error.message });
  }
}

// 2. Lấy thông tin chi tiết và các bước của 1 mẫu
async function getOrigamiById(req, res) {
  const { id } = req.params;

  try {
    // 1. Lấy thông tin chung của mẫu
    const [models] = await db.query(
      `SELECT om.*, c.name as category_name, c.emoji as category_emoji 
       FROM origami_models om 
       JOIN categories c ON om.category_id = c.id 
       WHERE om.id = ?`,
      [id]
    );

    if (models.length === 0) {
      return res.status(404).json({ message: 'Không tìm thấy mẫu Origami yêu cầu!' });
    }

    const origami = models[0];

    // 2. Lấy danh sách các bước gấp
    const [steps] = await db.query(
      'SELECT * FROM origami_steps WHERE origami_id = ? ORDER BY step_number ASC',
      [id]
    );

    origami.steps = steps;

    res.status(200).json(origami);
  } catch (error) {
    console.error('Lỗi lấy chi tiết mẫu Origami:', error);
    res.status(500).json({ message: 'Lỗi hệ thống khi lấy chi tiết mẫu!', error: error.message });
  }
}

// 3. Admin tạo mẫu Origami mới kèm các bước gấp (Sử dụng Transaction)
async function createOrigami(req, res) {
  const { 
    name, emoji, difficulty, estimatedTime, 
    paperSize, paperType, categoryId, status, steps, xpReward
  } = req.body;

  const creatorId = req.user.id; // Lấy từ authMiddleware

  if (!name || !emoji || !estimatedTime || !categoryId || !steps || !Array.isArray(steps)) {
    return res.status(400).json({ message: 'Vui lòng điền đầy đủ các trường thông tin và danh sách các bước gấp!' });
  }

  const connection = await db.getConnection();
  try {
    // Bắt đầu giao dịch (Transaction)
    await connection.beginTransaction();

    // Mặc định cho Admin là approved luôn, hoặc theo giá trị truyền lên (để làm nháp)
    const finalStatus = status || 'approved';

    // 1. Chèn thông tin chung vào bảng origami_models
    const [modelResult] = await connection.query(
      `INSERT INTO origami_models 
       (name, emoji, difficulty, estimated_time, paper_size, paper_type, category_id, creator_id, status, xp_reward)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [name, emoji, difficulty || 'Dễ', estimatedTime, paperSize || '15x15 cm', paperType || 'Washi', categoryId, creatorId, finalStatus, xpReward || 50]
    );

    const origamiId = modelResult.insertId;

    // 2. Chèn từng bước gấp vào bảng origami_steps
    for (let i = 0; i < steps.length; i++) {
      const step = steps[i];
      const stepNum = step.stepNumber || (i + 1);
      await connection.query(
        `INSERT INTO origami_steps (origami_id, step_number, instruction, tip, image_url, estimated_duration)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [origamiId, stepNum, step.instruction, step.tip || '', step.imageUrl || '', step.duration || 0]
      );
    }

    // Hoàn tất giao dịch
    await connection.commit();

    res.status(201).json({
      message: `Tạo mẫu gấp "${name}" thành công với trạng thái: ${finalStatus}!`,
      origamiId
    });
  } catch (error) {
    // Hủy bỏ các thao tác nếu có lỗi xảy ra
    await connection.rollback();
    console.error('Lỗi khi lưu mẫu Origami mới:', error);
    res.status(500).json({ message: 'Đã xảy ra lỗi khi tạo mẫu Origami!', error: error.message });
  } finally {
    // Trả kết nối về cho Pool
    connection.release();
  }
}

// 4. Lấy danh sách mẫu Origami đang chờ phê duyệt (Admin approval dashboard)
async function getPendingOrigami(req, res) {
  try {
    const [rows] = await db.query(
      `SELECT om.*, c.name as category_name, c.emoji as category_emoji, u.display_name as creator_name
       FROM origami_models om
       JOIN categories c ON om.category_id = c.id
       JOIN users u ON om.creator_id = u.id
       WHERE om.status = 'pending'
       ORDER BY om.created_at DESC`
    );
    res.status(200).json(rows);
  } catch (error) {
    console.error('Lỗi lấy danh sách mẫu chờ duyệt:', error);
    res.status(500).json({ message: 'Lỗi lấy mẫu chờ duyệt!', error: error.message });
  }
}

// 5. Phê duyệt hoặc Từ chối xuất bản mẫu
async function approveOrRejectOrigami(req, res) {
  const { id } = req.params;
  const { status, rejectionReason } = req.body; // status: 'approved' hoặc 'rejected'

  if (!status || !['approved', 'rejected'].includes(status)) {
    return res.status(400).json({ message: 'Trạng thái phê duyệt không hợp lệ! Chỉ nhận "approved" hoặc "rejected"' });
  }

  try {
    const [result] = await db.query(
      'UPDATE origami_models SET status = ?, rejection_reason = ? WHERE id = ?',
      [status, status === 'rejected' ? rejectionReason : null, id]
    );

    if (result.affectedRows === 0) {
      return res.status(404).json({ message: 'Không tìm thấy mẫu Origami để cập nhật!' });
    }

    res.status(200).json({ message: `Cập nhật trạng thái phê duyệt mẫu thành công sang: ${status}!` });
  } catch (error) {
    console.error('Lỗi phê duyệt mẫu:', error);
    res.status(500).json({ message: 'Lỗi hệ thống khi phê duyệt mẫu!', error: error.message });
  }
}

module.exports = {
  getAllOrigami,
  getOrigamiById,
  createOrigami,
  getPendingOrigami,
  approveOrRejectOrigami
};
