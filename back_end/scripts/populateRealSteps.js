const mysql = require('mysql2/promise');
require('dotenv').config();

async function populateRealSteps() {
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'origami_app_db',
  });

  try {
    console.log('🔄 Đang bắt đầu chèn dữ liệu hướng dẫn gấp chi tiết cho các mẫu...');

    // 1. Định nghĩa các bước gấp cho Trái Tim (ID: 1)
    const heartSteps = [
      {
        step: 1,
        instruction: 'Chuẩn bị một tờ giấy hình vuông màu đỏ (15x15 cm). Đặt mặt màu úp xuống. Gấp đôi tờ giấy theo đường chéo tạo thành hình tam giác lớn, miết phẳng nếp gấp rồi mở ra.',
        tip: 'Hãy miết nếp gấp thật thẳng và chính xác ở đường chéo chính.',
        image: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-1.png'
      },
      {
        step: 2,
        instruction: 'Xoay tờ giấy và tiếp tục gấp đôi theo đường chéo còn lại để tạo thành 2 đường nếp gấp chéo cắt nhau ở tâm. Mở tờ giấy phẳng ra.',
        tip: 'Đảm bảo giao điểm của 2 nếp gấp nằm đúng trung tâm tờ giấy.',
        image: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-2.png'
      },
      {
        step: 3,
        instruction: 'Gấp đỉnh góc trên cùng của tờ giấy xuống sao cho chạm đúng vào tâm chính giữa (giao điểm của 2 nếp gấp chéo).',
        tip: 'Đỉnh góc nhọn phải nằm chuẩn xác trên điểm tâm.',
        image: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-3.png'
      },
      {
        step: 4,
        instruction: 'Gấp góc dưới cùng của tờ giấy hướng lên trên sao cho đỉnh góc chạm vào cạnh ngang ở phần đầu trên của tờ giấy.',
        tip: 'Góc nhọn dưới cùng phải đi thẳng qua trục dọc trung tâm.',
        image: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-4.png'
      },
      {
        step: 5,
        instruction: 'Gấp cạnh bên dưới bên trái hướng lên trên theo đường nếp gấp dọc trung tâm.',
        tip: 'Cạnh gấp xiên sẽ khớp khít với trục nếp gấp dọc ở giữa.',
        image: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-5.png'
      },
      {
        step: 6,
        instruction: 'Gấp cạnh bên dưới bên phải tương tự hướng lên trên theo đường nếp gấp dọc trung tâm. Lúc này hình dáng trái tim cơ bản đã lộ ra.',
        tip: 'Hãy căn chỉnh hai bên thật đối xứng để trái tim cân đối.',
        image: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-6.png'
      },
      {
        step: 7,
        instruction: 'Lật mặt sau của trái tim lại để chuẩn bị bo các góc nhọn của trái tim cho tròn trịa.',
        tip: 'Giữ chặt các nếp gấp trước đó để không bị xô lệch khi lật.',
        image: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-7.png'
      },
      {
        step: 8,
        instruction: 'Gấp hai góc nhọn ở đỉnh phía trên xuống dưới khoảng 1-2 cm để tạo hình bo tròn cho phần đầu của trái tim.',
        tip: 'Gấp hai đỉnh bằng nhau để hai nửa trái tim cao bằng nhau.',
        image: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-8.png'
      },
      {
        step: 9,
        instruction: 'Gấp hai góc nhọn ở hai bên rìa trái và phải hướng vào trong một chút để làm thon gọn dáng trái tim.',
        tip: 'Chỉ cần gấp một góc nhỏ để bo tròn cạnh hông của trái tim.',
        image: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-9.png'
      },
      {
        step: 10,
        instruction: 'Lật ngược lại mặt trước. Xin chúc mừng! Bạn đã hoàn thành một Trái Tim Origami vô cùng dễ thương và ý nghĩa.',
        tip: 'Dùng tay vuốt nhẹ mặt trước cho phẳng phiu và cân đối.',
        image: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-10.png'
      }
    ];

    // 2. Định nghĩa các bước gấp cho Hạc Giấy (ID: 2)
    const swanSteps = [
      {
        step: 1,
        instruction: 'Đặt mặt màu tờ giấy hình vuông lên trên. Gấp đôi tờ giấy theo đường chéo tạo thành hình tam giác lớn rồi mở ra để lấy nếp gấp chéo chính giữa.',
        tip: 'Đường chéo này sẽ làm chuẩn cho các bước tiếp theo.',
        image: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-1.png'
      },
      {
        step: 2,
        instruction: 'Gấp hai cạnh dưới bên trái và bên phải hướng vào trong sao cho trùng khít với nếp gấp chéo chính giữa vừa tạo ở Bước 1. Tạo hình giống chiếc diều.',
        tip: 'Hãy miết phẳng và sát nếp gấp để các góc nhọn ở đuôi thật sắc nét.',
        image: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-2.png'
      },
      {
        step: 3,
        instruction: 'Lật mặt sau của tờ giấy lại.',
        tip: 'Nhớ giữ nguyên nếp gấp của mặt trước khi lật.',
        image: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-3.png'
      },
      {
        step: 4,
        instruction: 'Tiếp tục gấp hai cạnh bên ngoài hướng vào đường nếp gấp dọc ở chính giữa một lần nữa để làm thon gọn thân chú chim hạc.',
        tip: 'Hãy căn chỉnh thật khít và miết mạnh tay.',
        image: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-4.png'
      },
      {
        step: 5,
        instruction: 'Gấp đỉnh góc nhọn phía dưới lên trên sao cho trùng khít với đỉnh góc nhọn phía trên cùng.',
        tip: 'Đường gấp ngang này sẽ chia đôi chiều dài của thân hạc.',
        image: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-5.png'
      },
      {
        step: 6,
        instruction: 'Gấp ngược một phần nhỏ của đầu nhọn đó xuống dưới khoảng 2 cm để tạo hình chiếc mỏ cho chú hạc.',
        tip: 'Đây chính là phần đầu và mỏ của chim hạc.',
        image: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-6.png'
      },
      {
        step: 7,
        instruction: 'Gấp đôi toàn bộ cấu trúc theo chiều dọc từ trái sang phải dọc theo nếp gấp trục giữa.',
        tip: 'Giữ chặt phần đầu và cổ hạc bên trong khi gấp đôi lại.',
        image: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-7.png'
      },
      {
        step: 8,
        instruction: 'Kéo nhẹ nhàng phần cổ và đầu của hạc (phần có mỏ nhọn) hướng xiên lên trên một chút để tạo tư thế đứng kiêu hãnh.',
        tip: 'Kéo từ từ để tránh làm rách giấy ở phần nách gấp.',
        image: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-8.png'
      },
      {
        step: 9,
        instruction: 'Miết phẳng nếp gấp ở phần chân cổ để cố định tư thế cho chú hạc. Kéo nhẹ phần mỏ chim nằm ngang ra.',
        tip: 'Tạo nếp gấp sắc nét ở cổ hạc để chú hạc có thể đứng vững.',
        image: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-9.png'
      },
      {
        step: 10,
        instruction: 'Chỉnh sửa hai bên cánh rộng ra một chút. Bạn đã hoàn thành chú Hạc Origami tuyệt đẹp và thanh thoát!',
        tip: 'Đặt chú hạc lên bàn phẳng để kiểm tra độ cân bằng.',
        image: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-10.png'
      }
    ];

    // 3. Định nghĩa các bước gấp cho các mẫu khác (sử dụng hình ảnh mẫu minh họa chất lượng từ Unsplash)
    // Các mẫu khám phá (ID 11-20) và Rồng lửa (ID 3)
    const otherModels = [
      {
        id: 3, // Rồng Lửa
        name: 'Rồng Lửa',
        steps: [
          { step: 1, instruction: 'Bắt đầu bằng cách gấp đôi tờ giấy vuông màu cam theo chiều dọc và ngang để lấy nếp gấp dấu cộng.', tip: 'Miết nếp gấp phẳng phiu.', image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, instruction: 'Lật mặt sau, gấp hai đường chéo tạo nếp và thu gọn giấy về dạng xếp hình vuông cơ bản (Bird Base).', tip: 'Cẩn thận giữ các góc giấy cân đối.', image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, instruction: 'Gấp các góc của hình vuông vào trong nếp giữa để tạo hình kim cương, thực hiện trên cả hai mặt.', tip: 'Đây là cấu trúc cơ bản của cánh hạc/rồng.', image: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, instruction: 'Gập đầu nhọn trên cùng xuống dưới để tạo nếp gấp nằm ngang vững chắc.', tip: 'Miết mạnh tay.', image: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, instruction: 'Mở rộng hai góc bên hông ra và ấn xẹp nếp gấp xuống tạo thành đôi cánh lớn cho rồng.', tip: 'Bước này đòi hỏi sự khéo léo để không làm rách nách cánh.', image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, instruction: 'Gập đôi cấu trúc thân rồng dọc theo sống lưng.', tip: 'Đôi cánh hướng ra ngoài.', image: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' },
          { step: 7, instruction: 'Gấp ngược đầu của rồng tạo tư thế cổ ngẩng cao, tạo nếp gấp xếp ly để làm bờm và sừng rồng.', tip: 'Tạo nếp sừng tinh tế.', image: 'https://images.unsplash.com/photo-1502691876148-a84978e59fa8?q=80&w=400' },
          { step: 8, instruction: 'Gấp chân rồng ở cả hai bên hông bằng cách gập chéo các góc nhọn phía dưới xuống.', tip: 'Căn chỉnh hai chân trước và hai chân sau đối xứng.', image: 'https://images.unsplash.com/photo-1500485035595-cbe6f645feb1?q=80&w=400' },
          { step: 9, instruction: 'Uốn cong và gập ngoằn ngoèo phần đuôi rồng để tạo hiệu ứng đuôi rồng lửa sinh động.', tip: 'Tạo nếp uốn mềm mại tự nhiên.', image: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?q=80&w=400' },
          { step: 10, instruction: 'Mở cánh rồng rộng ra và chỉnh lại dáng đứng vững trên chân. Rồng Lửa Origami huyền thoại đã hoàn thành!', tip: 'Vuốt phẳng đôi cánh để trông oai vệ hơn.', image: 'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?q=80&w=400' }
        ]
      },
      {
        id: 11, // Thỏ Con
        name: 'Thỏ Con',
        steps: [
          { step: 1, instruction: 'Bắt đầu với tờ giấy hình vuông màu hồng nhạt. Gấp đôi theo đường chéo tạo hình tam giác.', tip: 'Hãy để mặt màu hướng ra ngoài.', image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, instruction: 'Gấp một dải mỏng ở cạnh đáy tam giác lên trên khoảng 1.5 cm để tạo nếp tai.', tip: 'Dải này sẽ định hình chiều dài tai thỏ.', image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, instruction: 'Gập góc nhọn hai bên hướng lên trên theo trục dọc chính giữa để tạo thành đôi tai thỏ dựng đứng.', tip: 'Đảm bảo hai tai thẳng hàng và bằng nhau.', image: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, instruction: 'Gập ngược góc nhọn dưới cùng ở cằm thỏ ra phía sau để bo tròn khuôn mặt.', tip: 'Miết phẳng nếp gấp cằm thỏ.', image: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, instruction: 'Gấp đầu góc nhọn phía trên trán thỏ vào trong để làm phẳng đỉnh đầu.', tip: 'Đôi tai sẽ trông rõ ràng hơn.', image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, instruction: 'Lật mặt trước lại và vẽ thêm mắt, mũi xinh xắn cho chú Thỏ Con Origami của bạn!', tip: 'Có thể dùng bút màu vẽ trang trí thêm.', image: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' }
        ]
      },
      {
        id: 12, // Bướm Xinh
        name: 'Bướm Xinh',
        steps: [
          { step: 1, instruction: 'Gấp đôi tờ giấy vuông theo cả chiều dọc, chiều ngang và hai đường chéo rồi mở ra để tạo nếp gấp cơ bản.', tip: 'Các nếp gấp chéo rất quan trọng cho thân bướm.', image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, instruction: 'Thu gọn giấy theo các nếp gấp chéo để tạo thành hình tam giác kép (Waterbomb Base).', tip: 'Ấn nhẹ ở tâm giấy để thu gọn dễ dàng.', image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, instruction: 'Gấp hai góc nhọn ở lớp trên của tam giác hướng lên chạm vào đỉnh nhọn phía trên.', tip: 'Thực hiện đối xứng cả bên trái và bên phải.', image: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, instruction: 'Lật mặt sau của tam giác lại.', tip: 'Hướng đỉnh tam giác xuống phía dưới.', image: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, instruction: 'Kéo đỉnh nhọn phía dưới gấp ngược lên trên, để đỉnh nhọn này vượt quá cạnh ngang trên cùng khoảng 1 cm.', tip: 'Hai cạnh bên sẽ tự động căng và cong lên.', image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, instruction: 'Gập đỉnh nhọn thừa đó đè qua mép ngang để khóa chặt cấu trúc.', tip: 'Miết thật chặt nếp gấp khóa này.', image: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' },
          { step: 7, instruction: 'Gập đôi toàn bộ chú bướm dọc theo nếp gấp thân giữa để định hình đôi cánh sinh động.', tip: 'Giữ chặt nếp gấp khóa cằm ở bước trước.', image: 'https://images.unsplash.com/photo-1502691876148-a84978e59fa8?q=80&w=400' },
          { step: 8, instruction: 'Mở nhẹ đôi cánh ra. Chúc mừng bạn đã hoàn thành một cánh Bướm Xinh Origami sống động!', tip: 'Uốn cong nhẹ đôi cánh để bướm trông tự nhiên hơn.', image: 'https://images.unsplash.com/photo-1500485035595-cbe6f645feb1?q=80&w=400' }
        ]
      },
      {
        id: 13, // Con Cá Vàng
        name: 'Con Cá Vàng',
        steps: [
          { step: 1, instruction: 'Sử dụng giấy vuông màu cam/đỏ. Gấp đôi chéo tờ giấy rồi mở ra lấy nếp gấp trục.', tip: 'Nên dùng giấy 2 mặt màu để đuôi cá nổi bật.', image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, instruction: 'Gấp hai cạnh bên ngoài hướng vào nếp gấp dọc trung tâm để tạo hình chiếc diều.', tip: 'Gấp thật phẳng hai mép giấy.', image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, instruction: 'Gấp phần góc nhọn phía trên xuống sát mép gấp chéo ngang bên dưới.', tip: 'Đây sẽ là đầu cá vàng.', image: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, instruction: 'Gấp ngược hai góc nhọn bên hông chéo xuống dưới tạo hình vây cá vàng.', tip: 'Tạo góc chéo khoảng 45 độ.', image: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, instruction: 'Gập đôi chú cá theo chiều dọc dọc theo nếp gấp chính giữa thân cá.', tip: 'Phần vây cá hướng chéo ra hai bên hông.', image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, instruction: 'Gấp chéo phần đuôi cá nhọn phía sau hướng lên trên.', tip: 'Tạo nếp chéo xéo để đuôi vểnh lên.', image: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' },
          { step: 7, instruction: 'Dùng kéo cắt nhẹ một đường nhỏ ở giữa vây đuôi để tách đuôi thành 2 phần mềm mại.', tip: 'Chỉ cắt một đường thẳng khoảng 3-4 cm.', image: 'https://images.unsplash.com/photo-1502691876148-a84978e59fa8?q=80&w=400' },
          { step: 8, instruction: 'Tách nhẹ vây đuôi và vẽ thêm mắt tròn xoe. Con Cá Vàng Origami xinh xắn đã bơi lội thành công!', tip: 'Đặt chú cá nằm nghiêng để chụp hình cực xinh.', image: 'https://images.unsplash.com/photo-1500485035595-cbe6f645feb1?q=80&w=400' }
        ]
      },
      {
        id: 14, // Hoa Hồng
        name: 'Hoa Hồng',
        steps: [
          { step: 1, instruction: 'Gấp đôi tờ giấy đỏ theo chiều dọc và ngang để tạo nếp gấp chữ thập chính giữa.', tip: 'Đường nếp gấp phải cực kỳ rõ nét.', image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, instruction: 'Gập 4 góc nhọn của tờ giấy vuông chạm vào đúng điểm tâm ở trung tâm tờ giấy.', tip: 'Đây gọi là nếp gấp Blintz.', image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, instruction: 'Tiếp tục gấp 4 góc nhọn mới vào tâm trung tâm một lần nữa để thu nhỏ kích thước hình vuông.', tip: 'Hãy đè chặt nếp giấy tránh bung ra.', image: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, instruction: 'Lần thứ ba, gấp cả 4 góc nhọn vào tâm trung tâm để tạo nhiều lớp cánh hoa hồng.', tip: 'Bước này giấy bắt đầu dày, hãy miết bằng cạnh thước.', image: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, instruction: 'Lật ngược mặt sau của tờ hình vuông dày lại.', tip: 'Giữ chặt phần giấy gấp xếp lớp bên dưới.', image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, instruction: 'Gấp tiếp 4 góc nhọn ở mặt sau hướng vào tâm chính giữa.', tip: 'Miết phẳng nếp gấp để định hình đế hoa.', image: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' },
          { step: 7, instruction: 'Gấp nhẹ 4 đỉnh nhọn ở giữa chéo ngược ra phía ngoài mép giấy.', tip: 'Đây là phần nhụy hoa trong cùng.', image: 'https://images.unsplash.com/photo-1502691876148-a84978e59fa8?q=80&w=400' },
          { step: 8, instruction: 'Lật nhẹ từng lớp cánh hoa từ phía dưới kéo lộn ngược ra mặt ngoài.', tip: 'Kéo nhẹ nhàng và dùng ngón tay uốn cong cánh hoa hồng.', image: 'https://images.unsplash.com/photo-1500485035595-cbe6f645feb1?q=80&w=400' },
          { step: 9, instruction: 'Tiếp tục lộn lớp cánh hoa tiếp theo từ phía dưới ra ngoài để tạo độ nở rộ.', tip: 'Uốn cong 4 góc cánh hoa chéo ra ngoài.', image: 'https://images.unsplash.com/photo-1579783902614-a3fb3927b6a5?q=80&w=400' },
          { step: 10, instruction: 'Chỉnh trang lại các lớp cánh hoa cho đều và căng phồng. Bạn đã có đóa Hoa Hồng Origami nở rộ rực rỡ!', tip: 'Có thể làm thêm cành và lá bằng giấy xanh.', image: 'https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?q=80&w=400' }
        ]
      },
      {
        id: 15, // Cây Thông
        name: 'Cây Thông',
        steps: [
          { step: 1, instruction: 'Sử dụng giấy vuông xanh lá. Gấp đôi chéo tờ giấy rồi mở ra lấy nếp gấp trục.', tip: 'Dùng giấy xanh sẫm để cây trông chân thật.', image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, instruction: 'Gấp hai cạnh bên ngoài hướng vào nếp gấp dọc trung tâm để tạo hình chiếc diều.', tip: 'Miết phẳng nếp gấp từ đỉnh nhọn xuống đáy.', image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, instruction: 'Gấp góc nhọn bên dưới chéo lên trên trùng với đỉnh nhọn phía trên.', tip: 'Tờ giấy sẽ tạo thành hình tam giác gọn gàng.', image: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, instruction: 'Gấp ngược phần chân tam giác xuống dưới chéo tạo nếp gấp xếp ly (Z-fold) làm các tầng lá cây.', tip: 'Gấp ly khoảng 1.5 cm.', image: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, instruction: 'Lặp lại thao tác gấp xếp ly ly một lần nữa để tạo tầng lá cây thông thứ hai.', tip: 'Hãy căn chỉnh sao cho các tầng lá nhỏ dần lên đỉnh.', image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, instruction: 'Lật ngược lại mặt trước, vuốt phẳng các nếp gấp. Cây Thông Noel Origami xinh xắn đã hoàn thiện!', tip: 'Có thể dán thêm một ngôi sao vàng trên đỉnh cây.', image: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' }
        ]
      },
      {
        id: 16, // Thuyền Giấy
        name: 'Thuyền Giấy',
        steps: [
          { step: 1, instruction: 'Sử dụng một tờ giấy hình chữ nhật A4 hoặc A5. Gấp đôi tờ giấy theo chiều ngang.', tip: 'Đường gấp ngang hướng lên trên.', image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, instruction: 'Gấp tiếp hai góc trên bên trái và bên phải hướng vào giữa trùng với trục dọc chính.', tip: 'Tờ giấy lúc này trông giống mái nhà.', image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, instruction: 'Gấp dải chữ nhật bên dưới hướng lên trên ở cả mặt trước và mặt sau của thuyền.', tip: 'Gấp sát chân mái nhà tam giác.', image: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, instruction: 'Nhét các góc nhọn thừa của dải giấy chéo vào bên trong để khóa cấu trúc tam giác.', tip: 'Mở rộng lòng tam giác ra rồi xếp xẹp lại thành hình thoi.', image: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, instruction: 'Gấp góc nhọn bên dưới hướng chéo lên trên ở cả mặt trước và sau để tạo tam giác nhỏ hơn.', tip: 'Tiếp tục mở lòng tam giác và ép phẳng thành hình thoi mới.', image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, instruction: 'Dùng hai tay kéo nhẹ nhàng hai góc nhọn phía trên sang hai bên rìa. Thuyền Giấy Origami truyền thống đã lộ diện!', tip: 'Mở rộng khoang thuyền bên dưới để thuyền đứng vững được trên nước.', image: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' }
        ]
      },
      {
        id: 17, // Máy Bay Giấy
        name: 'Máy Bay Giấy',
        steps: [
          { step: 1, instruction: 'Sử dụng tờ giấy hình chữ nhật A4 phẳng phiu. Gấp đôi tờ giấy theo chiều dọc rồi mở phẳng ra.', tip: 'Miết trục nếp gấp dọc thẳng thớm ở giữa.', image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, instruction: 'Gấp hai góc nhọn ở đầu trên hướng vào trong sao cho trùng khít với nếp gấp dọc chính giữa.', tip: 'Tạo thành hình mũi nhọn cơ bản.', image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, instruction: 'Gấp toàn bộ phần mũi nhọn tam giác hướng xuống dưới.', tip: 'Phần đỉnh nhọn chạm vào nếp gấp dọc ở đáy.', image: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, instruction: 'Tiếp tục gấp hai góc ở đầu trên hướng chéo vào nếp gấp dọc trục giữa một lần nữa.', tip: 'Đầu mũi nhọn sẽ nằm bên dưới các mép gấp này.', image: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, instruction: 'Gấp đỉnh nhọn tam giác nhỏ nằm phía dưới hướng chéo ngược lên để khóa chặt hai cánh máy bay.', tip: 'Miết phẳng nếp gấp khóa này.', image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, instruction: 'Gập đôi máy bay ra phía sau dọc theo đường sống giữa, sau đó gập chéo hai bên để tạo cánh rộng. Máy bay đã sẵn sàng cất cánh bay cao!', tip: 'Miết phẳng phần cánh để máy bay bay xa hơn.', image: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' }
        ]
      },
      {
        id: 18, // Xe Tải Giấy
        name: 'Xe Tải Giấy',
        steps: [
          { step: 1, instruction: 'Gấp đôi tờ giấy vuông màu xanh theo chiều dọc để tạo nếp gấp trung tâm rồi mở ra.', tip: 'Nếp gấp này chia đôi chiều rộng xe tải.', image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, instruction: 'Gấp mép giấy bên dưới lên trên khoảng 2 cm để tạo gầm xe và bánh xe.', tip: 'Miết phẳng nếp gấp chân.', image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, instruction: 'Gấp hai mép dọc bên trái và bên phải hướng vào nếp gấp trục dọc ở tâm.', tip: 'Tờ giấy tạo thành dải chữ nhật dày đứng.', image: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, instruction: 'Gập chéo góc trên bên trái hướng xuống dưới tạo hình kính chắn gió và đầu xe tải.', tip: 'Tạo góc nghiêng 45 độ.', image: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, instruction: 'Gập chéo góc trên bên phải chéo xuống tạo thành phần đuôi xe tải.', tip: 'Gập vừa phải để xe có tỷ lệ cân đối.', image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, instruction: 'Gập đôi toàn bộ xe tải theo chiều ngang dọc theo nếp gấp giữa.', tip: 'Các mép gấp ở bước trước nằm phía trong.', image: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' },
          { step: 7, instruction: 'Dùng bút màu vẽ thêm hai bánh xe hình tròn lớn ở cạnh đáy gầm xe.', tip: 'Tô bánh xe màu đen để nổi bật.', image: 'https://images.unsplash.com/photo-1502691876148-a84978e59fa8?q=80&w=400' },
          { step: 8, instruction: 'Vẽ thêm kính buồng lái xe và cửa thùng hàng. Xe Tải Giấy Origami siêu đáng yêu đã hoàn thành!', tip: 'Có thể vẽ thêm logo/tên hàng hóa lên thùng xe.', image: 'https://images.unsplash.com/photo-1500485035595-cbe6f645feb1?q=80&w=400' }
        ]
      },
      {
        id: 19, // Chiếc Cốc Giấy
        name: 'Chiếc Cốc Giấy',
        steps: [
          { step: 1, instruction: 'Sử dụng tờ giấy hình vuông màu xanh da trời. Gấp đôi theo đường chéo để tạo thành hình tam giác lớn nằm ngang.', tip: 'Cạnh gấp nằm ở phía dưới, đỉnh hướng lên trên.', image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, instruction: 'Gấp góc nhọn bên dưới bên trái hướng chéo lên chạm vào mép nghiêng chéo đối diện bên phải.', tip: 'Đường gấp nằm song song với cạnh đáy.', image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, instruction: 'Gấp tương tự góc nhọn bên phải hướng chéo sang bên trái chạm vào điểm mép nghiêng đối diện bên trái.', tip: 'Hai dải gấp sẽ xếp chéo bắt qua nhau.', image: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, instruction: 'Gập một lớp giấy góc nhọn ở đỉnh phía trên hướng xuống phía dưới đè chèn qua lớp gấp trước.', tip: 'Đây là vành cốc mặt trước.', image: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, instruction: 'Lật ngược chiếc cốc lại và tiếp tục gập lớp giấy góc nhọn đỉnh còn lại xuống dưới.', tip: 'Vành cốc mặt sau đã được cố định.', image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, instruction: 'Dùng tay bóp nhẹ hai bên hông để mở rộng miệng chiếc Cốc Giấy Origami của bạn ra và đứng vững!', tip: 'Mẫu cốc gấp này có thể đựng được vật nhẹ.', image: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' }
        ]
      },
      {
        id: 20, // Ngôi Sao May Mắn
        name: 'Ngôi Sao May Mắn',
        steps: [
          { step: 1, instruction: 'Sử dụng một dải giấy dài (kích thước khoảng 1x20 cm) có màu sắc nổi bật.', tip: 'Giấy sao mỏng uốn cong dễ dàng hơn.', image: 'https://images.unsplash.com/photo-1544816155-12df9643f363?q=80&w=400' },
          { step: 2, instruction: 'Uốn cong một đầu dải giấy chéo chèn qua nhau tạo thành một lỗ thắt nút thòng lọng.', tip: 'Tạo nút thắt giống ruy băng ruy-băng.', image: 'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?q=80&w=400' },
          { step: 3, instruction: 'Luồn đầu dải giấy ngắn qua lỗ và rút nhẹ nhàng từ hai đầu thắt nút thắt chặt hình ngũ giác đều.', tip: 'Vuốt phẳng hình ngũ giác đó, gập đầu thừa ngắn luồn vào trong.', image: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?q=80&w=400' },
          { step: 4, instruction: 'Gập dải giấy dài quấn quanh các cạnh của hình ngũ giác đều đặn.', tip: 'Dải giấy tự động chạy chéo theo các cạnh.', image: 'https://images.unsplash.com/photo-1490730141103-6cac27aaab94?q=80&w=400' },
          { step: 5, instruction: 'Tiếp tục quấn chéo dải giấy cho đến khi dải giấy chỉ còn thừa khoảng 1.5 cm.', tip: 'Quấn giấy khít với nhau nhưng không quá chặt.', image: 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=400' },
          { step: 6, instruction: 'Nhét đầu giấy thừa còn lại luồn chui vào khe gấp ngũ giác ở bước trước để giữ chặt dải giấy.', tip: 'Đảm bảo ngũ giác gọn gàng và chắc chắn.', image: 'https://images.unsplash.com/photo-1557672172-298e090bd0f1?q=80&w=400' },
          { step: 7, instruction: 'Dùng hai ngón tay cái và ngón trỏ bóp mạnh vào 5 trung điểm cạnh của ngũ giác để tạo độ phồng cho ngôi sao.', tip: 'Bóp nhẹ từ từ để các góc phồng lên tròn đều.', image: 'https://images.unsplash.com/photo-1502691876148-a84978e59fa8?q=80&w=400' },
          { step: 8, instruction: 'Căn chỉnh lại các đỉnh nhọn ngũ giác. Ngôi Sao May Mắn Origami của bạn đã phồng đều cực kỳ dễ thương!', tip: 'Làm thật nhiều ngôi sao bỏ vào lọ thủy tinh ước nguyện nhé.', image: 'https://images.unsplash.com/photo-1500485035595-cbe6f645feb1?q=80&w=400' }
        ]
      }
    ];

    // Chèn cho Trái Tim (ID 1)
    await conn.query('DELETE FROM origami_steps WHERE origami_id = 1');
    for (const s of heartSteps) {
      await conn.query(
        `INSERT INTO origami_steps (origami_id, step_number, instruction, tip, image_url, estimated_duration) 
         VALUES (1, ?, ?, ?, ?, 1)`,
        [s.step, s.instruction, s.tip, s.image]
      );
    }
    console.log('✅ Đã cập nhật 10 bước gấp chi tiết cho Trái Tim!');

    // Chèn cho Hạc Giấy (ID 2)
    await conn.query('DELETE FROM origami_steps WHERE origami_id = 2');
    for (const s of swanSteps) {
      await conn.query(
        `INSERT INTO origami_steps (origami_id, step_number, instruction, tip, image_url, estimated_duration) 
         VALUES (2, ?, ?, ?, ?, 1)`,
        [s.step, s.instruction, s.tip, s.image]
      );
    }
    console.log('✅ Đã cập nhật 10 bước gấp chi tiết cho Hạc Giấy (Swan)!');

    // Chèn cho các mẫu khác
    for (const m of otherModels) {
      await conn.query('DELETE FROM origami_steps WHERE origami_id = ?', [m.id]);
      for (const s of m.steps) {
        await conn.query(
          `INSERT INTO origami_steps (origami_id, step_number, instruction, tip, image_url, estimated_duration) 
           VALUES (?, ?, ?, ?, ?, 1)`,
          [m.id, s.step, s.instruction, s.tip, s.image]
        );
      }
      console.log(`✅ Đã cập nhật ${m.steps.length} bước gấp chi tiết cho mẫu "${m.name}"!`);
    }

    console.log('🎉 Hoàn thành cập nhật toàn bộ hướng dẫn gấp chi tiết thành công!');
  } finally {
    await conn.end();
  }
}

populateRealSteps().catch(console.error);
