const { verifyToken } = require('../utils/jwt');

function authMiddleware(req, res, next) {
  const authHeader = req.headers['authorization'];
  if (!authHeader) {
    return res.status(401).json({ message: 'Không tìm thấy Token xác thực. Vui lòng đăng nhập!' });
  }

  // Lấy token từ header Authorization: Bearer <token>
  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    return res.status(401).json({ message: 'Định dạng token không chính xác. Phải là Bearer <Token>!' });
  }

  const token = parts[1];
  const decoded = verifyToken(token);

  if (!decoded) {
    return res.status(401).json({ message: 'Token không hợp lệ hoặc đã hết hạn!' });
  }

  req.user = decoded;
  next();
}

module.exports = authMiddleware;
