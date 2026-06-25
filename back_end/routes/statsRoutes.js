const express = require('express');
const router = express.Router();
const statsController = require('../controllers/statsController');
const authMiddleware = require('../middlewares/authMiddleware');

// Leaderboard có thể public để khách xem được
router.get('/leaderboard', statsController.getLeaderboard);

// Các API còn lại yêu cầu đăng nhập
router.get('/analytics', authMiddleware, statsController.getUserAnalytics);
router.get('/badges', authMiddleware, statsController.getUserBadges);
router.get('/daily-challenge', authMiddleware, statsController.getDailyChallenge);
router.post('/daily-challenge/complete', authMiddleware, statsController.completeDailyChallenge);

module.exports = router;
