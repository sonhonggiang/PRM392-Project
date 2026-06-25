const express = require('express');
const cors = require('cors');
const authRoutes = require('./routes/authRoutes');
const origamiRoutes = require('./routes/origamiRoutes');
const userRoutes = require('./routes/userRoutes');
const statsRoutes = require('./routes/statsRoutes');

const app = express();

// Middlewares
app.use(cors());
app.use(express.json());

// Định tuyến API endpoints
app.use('/api/auth', authRoutes);
app.use('/api/origami', origamiRoutes);
app.use('/api/users', userRoutes);
app.use('/api', statsRoutes);

// Route mặc định kiểm tra sức khỏe server (Health Check)
app.get('/', (req, res) => {
  res.json({
    message: 'Chào mừng bạn đến với Origami App API! Server đang chạy ổn định.',
    status: 'Healthy',
    timestamp: new Date()
  });
});

// Xử lý Route không tìm thấy (404 Not Found)
app.use((req, res, next) => {
  res.status(404).json({ message: `API Endpoint ${req.originalUrl} không tồn tại!` });
});

// Middleware xử lý lỗi tập trung (Global Error Handler)
app.use((err, req, res, next) => {
  console.error('Error Trace:', err.stack);
  res.status(err.status || 500).json({
    message: 'Đã xảy ra lỗi không mong muốn trên hệ thống!',
    error: err.message
  });
});

module.exports = app;
