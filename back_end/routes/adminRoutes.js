const express = require('express');
const router = express.Router();
const adminController = require('../controllers/adminController');
const authMiddleware = require('../middlewares/authMiddleware');

// Middleware kiểm tra quyền Admin
const adminOnly = (req, res, next) => {
  if (req.user && req.user.role === 'admin') {
    next();
  } else {
    res.status(403).json({ message: 'Quyền truy cập bị từ chối. Chỉ dành cho Admin!' });
  }
};

router.use(authMiddleware);
router.use(adminOnly);

// Quản lý danh mục
router.get('/categories', adminController.getCategories);
router.post('/categories', adminController.addCategory);
router.put('/categories/:id', adminController.updateCategory);
router.delete('/categories/:id', adminController.deleteCategory);

// Quản lý mẫu Origami
router.put('/origami/:id', adminController.updateOrigamiModel);

// Quản lý người dùng
router.get('/users', adminController.getUsers);
router.put('/users/:id/xp', adminController.updateUserXP);

module.exports = router;
