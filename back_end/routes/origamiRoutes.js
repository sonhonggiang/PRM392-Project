const express = require('express');
const router = express.Router();
const origamiController = require('../controllers/origamiController');
const authMiddleware = require('../middlewares/authMiddleware');
const roleMiddleware = require('../middlewares/roleMiddleware');
const db = require('../config/db');

// Middleware cho phép Admin hoặc User có >= 2000 XP đóng góp mẫu Origami
const canCreateOrigami = async (req, res, next) => {
  if (!req.user) {
    return res.status(401).json({ message: 'Người dùng chưa được xác thực!' });
  }
  try {
    const [rows] = await db.query('SELECT role, xp FROM users WHERE id = ?', [req.user.id]);
    if (rows.length === 0) {
      return res.status(404).json({ message: 'Người dùng không tồn tại!' });
    }
    const user = rows[0];
    if (user.role === 'admin' || user.xp >= 2000) {
      req.user.role = user.role;
      req.user.xp = user.xp;
      next();
    } else {
      return res.status(403).json({ message: 'Bạn cần đạt tối thiểu 2000 XP để sáng tạo và đóng góp mẫu!' });
    }
  } catch (error) {
    return res.status(500).json({ message: 'Lỗi kiểm tra quyền hạn sáng tạo!', error: error.message });
  }
};

router.get('/', origamiController.getAllOrigami);
router.get('/pending', authMiddleware, roleMiddleware(['admin']), origamiController.getPendingOrigami);
router.get('/:id', origamiController.getOrigamiById);
router.post('/', authMiddleware, canCreateOrigami, origamiController.createOrigami);
router.put('/:id/approval', authMiddleware, roleMiddleware(['admin']), origamiController.approveOrRejectOrigami);
router.post('/:id/rate', authMiddleware, origamiController.rateOrigami);

module.exports = router;

