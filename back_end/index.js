require('dotenv').config();
const initializeDatabase = require('./config/initDb');

const PORT = process.env.PORT || 3000;

async function startServer() {
  // 1. Tự động kiểm tra và khởi tạo Cơ sở dữ liệu cùng các Bảng
  await initializeDatabase();

  // 2. Load ứng dụng Express
  const app = require('./app');

  app.listen(PORT, () => {
    console.log(`========================================`);
    console.log(`🚀 Origami App Backend Server is running!`);
    console.log(`🔌 Local URL: http://localhost:${PORT}`);
    console.log(`📅 Started at: ${new Date().toLocaleString()}`);
    console.log(`========================================`);
  });
}

startServer();

