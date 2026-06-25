// Middleware kiểm tra quyền hạn (Role check)
function roleMiddleware(allowedRoles = []) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ message: 'Người dùng chưa được xác thực!' });
    }

    const { role } = req.user;
    if (!allowedRoles.includes(role)) {
      return res.status(403).json({ message: 'Bạn không có quyền thực hiện hành động này!' });
    }

    next();
  };
}

module.exports = roleMiddleware;
