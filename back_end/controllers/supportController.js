const db = require('../config/db');

// --- DÀNH CHO USER ---

// 1. Lấy danh sách tin nhắn của chính mình với Admin
async function getUserMessages(req, res) {
  const userId = req.user.id;
  try {
    const [rows] = await db.query(
      `SELECT sm.*, u.display_name as sender_name 
       FROM support_messages sm
       JOIN users u ON sm.sender_id = u.id
       WHERE sm.user_id = ?
       ORDER BY sm.created_at ASC`,
      [userId]
    );
    res.status(200).json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy tin nhắn hỗ trợ!', error: error.message });
  }
}

// 2. User gửi tin nhắn hỗ trợ cho Admin
async function sendMessageToAdmin(req, res) {
  const userId = req.user.id;
  const { message } = req.body;

  if (!message || message.trim() === '') {
    return res.status(400).json({ message: 'Tin nhắn không được rỗng!' });
  }

  try {
    await db.query(
      'INSERT INTO support_messages (user_id, sender_id, message) VALUES (?, ?, ?)',
      [userId, userId, message.trim()]
    );
    res.status(201).json({ message: 'Đã gửi tin nhắn cho Admin!' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi gửi tin nhắn!', error: error.message });
  }
}

// --- DÀNH CHO ADMIN ---

// 3. Admin lấy danh sách tất cả các cuộc hội thoại
async function getAdminConversations(req, res) {
  try {
    const [rows] = await db.query(`
      SELECT DISTINCT sm.user_id, u.display_name, u.email,
             (SELECT message FROM support_messages WHERE user_id = sm.user_id ORDER BY created_at DESC LIMIT 1) as last_message,
             (SELECT created_at FROM support_messages WHERE user_id = sm.user_id ORDER BY created_at DESC LIMIT 1) as last_message_time,
             (SELECT sender_id FROM support_messages WHERE user_id = sm.user_id ORDER BY created_at DESC LIMIT 1) as last_sender_id
      FROM support_messages sm
      JOIN users u ON sm.user_id = u.id
      ORDER BY last_message_time DESC
    `);
    res.status(200).json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy danh sách hội thoại!', error: error.message });
  }
}

// 4. Admin lấy chi tiết tin nhắn của 1 User cụ thể
async function getAdminConversationDetail(req, res) {
  const { userId } = req.params;
  try {
    const [rows] = await db.query(
      `SELECT sm.*, u.display_name as sender_name 
       FROM support_messages sm
       JOIN users u ON sm.sender_id = u.id
       WHERE sm.user_id = ?
       ORDER BY sm.created_at ASC`,
      [userId]
    );
    res.status(200).json(rows);
  } catch (error) {
    res.status(500).json({ message: 'Lỗi lấy chi tiết hội thoại!', error: error.message });
  }
}

// 5. Admin phản hồi tin nhắn cho 1 User cụ thể
async function replyToUser(req, res) {
  const adminId = req.user.id;
  const { userId } = req.params;
  const { message } = req.body;

  if (!message || message.trim() === '') {
    return res.status(400).json({ message: 'Tin nhắn phản hồi không được rỗng!' });
  }

  try {
    await db.query(
      'INSERT INTO support_messages (user_id, sender_id, message) VALUES (?, ?, ?)',
      [userId, adminId, message.trim()]
    );
    res.status(201).json({ message: 'Đã gửi phản hồi hỗ trợ thành công!' });
  } catch (error) {
    res.status(500).json({ message: 'Lỗi gửi phản hồi!', error: error.message });
  }
}

module.exports = {
  getUserMessages,
  sendMessageToAdmin,
  getAdminConversations,
  getAdminConversationDetail,
  replyToUser,
};
