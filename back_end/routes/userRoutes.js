const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');
const authMiddleware = require('../middlewares/authMiddleware');

// Tất cả các route dưới đây yêu cầu đăng nhập
router.use(authMiddleware);

router.get('/favorites', userController.getFavorites);
router.post('/favorites/:origamiId', userController.toggleFavorite);
router.get('/progress', userController.getProgress);
router.put('/progress/:origamiId', userController.updateProgress);

module.exports = router;
