const express = require('express');
const router = express.Router();
const supportController = require('../controllers/supportController');
const authMiddleware = require('../middlewares/authMiddleware');
const roleMiddleware = require('../middlewares/roleMiddleware');

router.use(authMiddleware);

// --- ROUTES DÀNH CHO USER ---
router.get('/messages', supportController.getUserMessages);
router.post('/messages', supportController.sendMessageToAdmin);

// --- ROUTES DÀNH CHO ADMIN ---
router.get('/conversations', roleMiddleware(['admin']), supportController.getAdminConversations);
router.get('/conversations/:userId', roleMiddleware(['admin']), supportController.getAdminConversationDetail);
router.post('/conversations/:userId', roleMiddleware(['admin']), supportController.replyToUser);

module.exports = router;
