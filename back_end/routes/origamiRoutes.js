const express = require('express');
const router = express.Router();
const origamiController = require('../controllers/origamiController');
const authMiddleware = require('../middlewares/authMiddleware');
const roleMiddleware = require('../middlewares/roleMiddleware');

router.get('/', origamiController.getAllOrigami);
router.get('/pending', authMiddleware, roleMiddleware(['admin']), origamiController.getPendingOrigami);
router.get('/:id', origamiController.getOrigamiById);
router.post('/', authMiddleware, roleMiddleware(['admin']), origamiController.createOrigami);
router.put('/:id/approval', authMiddleware, roleMiddleware(['admin']), origamiController.approveOrRejectOrigami);

module.exports = router;
