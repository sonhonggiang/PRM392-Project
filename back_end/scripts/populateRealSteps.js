const mysql = require('mysql2/promise');
require('dotenv').config();

async function populateRealSteps() {
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'Web_Son_Dep_Trai',
  });

  try {
    console.log('🔄 Bắt đầu cập nhật hướng dẫn gấp chi tiết với hình ảnh đúng cho từng mẫu...');

    // ======================================================
    // ID: 1 - TRÁI TIM (Heart)
    // Nguồn: origami.me/heart
    // ======================================================
    const heartSteps = [
      {
        step: 1,
        instruction: 'Chuẩn bị một tờ giấy hình vuông màu đỏ (15x15 cm). Đặt mặt màu úp xuống. Gấp đôi tờ giấy theo đường chéo tạo thành hình tam giác lớn, miết phẳng nếp gấp rồi mở ra.',
        tip: 'Miết nếp gấp thật thẳng và chính xác ở đường chéo chính.',
        image: 'https://www.origami-instructions.com/images/origami-heart-1.jpg'
      },
      {
        step: 2,
        instruction: 'Xoay tờ giấy và tiếp tục gấp đôi theo đường chéo còn lại để tạo thành 2 đường nếp gấp chéo cắt nhau ở tâm. Mở tờ giấy phẳng ra.',
        tip: 'Đảm bảo giao điểm của 2 nếp gấp nằm đúng trung tâm tờ giấy.',
        image: 'https://www.origami-instructions.com/images/origami-heart-2.jpg'
      },
      {
        step: 3,
        instruction: 'Gấp đỉnh góc trên cùng của tờ giấy xuống sao cho chạm đúng vào tâm chính giữa (giao điểm của 2 nếp gấp chéo).',
        tip: 'Đỉnh góc nhọn phải nằm chuẩn xác trên điểm tâm.',
        image: 'https://www.origami-instructions.com/images/origami-heart-3.jpg'
      },
      {
        step: 4,
        instruction: 'Gấp góc dưới cùng của tờ giấy hướng lên trên sao cho đỉnh góc chạm vào cạnh ngang ở phần đầu trên của tờ giấy.',
        tip: 'Góc nhọn dưới cùng phải đi thẳng qua trục dọc trung tâm.',
        image: 'https://www.origami-instructions.com/images/origami-heart-4.jpg'
      },
      {
        step: 5,
        instruction: 'Gấp cạnh bên dưới bên trái hướng lên trên theo đường nếp gấp dọc trung tâm.',
        tip: 'Cạnh gấp xiên sẽ khớp khít với trục nếp gấp dọc ở giữa.',
        image: 'https://www.origami-instructions.com/images/origami-heart-5.jpg'
      },
      {
        step: 6,
        instruction: 'Gấp cạnh bên dưới bên phải tương tự hướng lên trên theo đường nếp gấp dọc trung tâm. Lúc này hình dáng trái tim cơ bản đã lộ ra.',
        tip: 'Hãy căn chỉnh hai bên thật đối xứng để trái tim cân đối.',
        image: 'https://www.origami-instructions.com/images/origami-heart-6.jpg'
      },
      {
        step: 7,
        instruction: 'Lật mặt sau của trái tim lại để chuẩn bị bo các góc nhọn của trái tim cho tròn trịa.',
        tip: 'Giữ chặt các nếp gấp trước đó để không bị xô lệch khi lật.',
        image: 'https://www.origami-instructions.com/images/origami-heart-7.jpg'
      },
      {
        step: 8,
        instruction: 'Gấp hai góc nhọn ở đỉnh phía trên xuống dưới khoảng 1-2 cm để tạo hình bo tròn cho phần đầu của trái tim.',
        tip: 'Gấp hai đỉnh bằng nhau để hai nửa trái tim cao bằng nhau.',
        image: 'https://www.origami-instructions.com/images/origami-heart-8.jpg'
      },
      {
        step: 9,
        instruction: 'Gấp hai góc nhọn ở hai bên rìa trái và phải hướng vào trong một chút để làm thon gọn dáng trái tim.',
        tip: 'Chỉ cần gấp một góc nhỏ để bo tròn cạnh hông của trái tim.',
        image: 'https://www.origami-instructions.com/images/origami-heart-9.jpg'
      },
      {
        step: 10,
        instruction: 'Lật ngược lại mặt trước. Xin chúc mừng! Bạn đã hoàn thành một Trái Tim Origami vô cùng dễ thương và ý nghĩa.',
        tip: 'Dùng tay vuốt nhẹ mặt trước cho phẳng phiu và cân đối.',
        image: 'https://www.origami-instructions.com/images/origami-heart-10.jpg'
      }
    ];

    // ======================================================
    // ID: 2 - HẠC GIẤY / Crane (Origami Crane)
    // Nguồn: origami.me/crane - hình ảnh sơ đồ gấp hạc thực tế
    // ======================================================
    const craneSteps = [
      {
        step: 1,
        instruction: 'Đặt mặt màu tờ giấy hình vuông lên trên. Gấp đôi tờ giấy theo cả chiều ngang và chiều dọc tạo nếp gấp chữ thập. Mở tờ giấy phẳng ra.',
        tip: 'Cả hai đường gấp ngang và dọc phải chuẩn xác qua tâm tờ giấy.',
        image: 'https://www.origami-instructions.com/images/origami-crane-1.jpg'
      },
      {
        step: 2,
        instruction: 'Lật mặt sau tờ giấy. Gấp đôi tờ giấy theo hai đường chéo tạo nếp gấp chữ X. Mở tờ giấy ra.',
        tip: 'Khi hoàn thành có 4 đường nếp gấp cắt nhau tại tâm.',
        image: 'https://www.origami-instructions.com/images/origami-crane-2.jpg'
      },
      {
        step: 3,
        instruction: 'Thu gọn tờ giấy theo các nếp gấp chéo và nếp gấp ngang để tạo thành hình vuông nhỏ gọn (Square Base/Sơ đồ vuông cơ bản).',
        tip: 'Ấn nhẹ vào tâm giấy và để 4 phần tự gấp vào nhau thành hình vuông.',
        image: 'https://www.origami-instructions.com/images/origami-crane-3.jpg'
      },
      {
        step: 4,
        instruction: 'Với hình vuông cơ bản đặt đỉnh nhọn lên trên, gấp hai cạnh bên trái và phải hướng vào nếp gấp dọc chính giữa. Lặp lại ở mặt sau.',
        tip: 'Tạo hình thoi gọn gàng ở cả hai mặt.',
        image: 'https://www.origami-instructions.com/images/origami-crane-4.jpg'
      },
      {
        step: 5,
        instruction: 'Gấp đỉnh nhọn trên cùng xuống và mở nếp gấp vừa tạo. Miết phẳng và ấn mạnh tạo nếp đường nằm ngang.',
        tip: 'Đây là bước tạo nếp chuẩn bị để petal fold.',
        image: 'https://www.origami-instructions.com/images/origami-crane-5.jpg'
      },
      {
        step: 6,
        instruction: 'Thực hiện Petal Fold: Nâng lớp trên cùng từ dưới đáy lên trên trong khi hai cạnh bên gập vào trong. Lặp lại ở mặt sau. Kết quả là hình thoi dài (Bird Base).',
        tip: 'Đây là kỹ thuật quan trọng nhất khi gấp hạc. Hãy làm chậm và cẩn thận.',
        image: 'https://www.origami-instructions.com/images/origami-crane-6.jpg'
      },
      {
        step: 7,
        instruction: 'Gấp hai đỉnh nhọn phía dưới của Bird Base lên trên dọc theo nếp gấp dọc trung tâm (đây sẽ là cổ và đuôi hạc).',
        tip: 'Cổ và đuôi hạc cần dài bằng nhau.',
        image: 'https://www.origami-instructions.com/images/origami-crane-7.jpg'
      },
      {
        step: 8,
        instruction: 'Gấp ngược một phần nhỏ của một đỉnh nhọn (phần cổ hạc) để tạo thành chiếc đầu nhỏ và mỏ hạc.',
        tip: 'Phần đầu hạc chỉ cần gấp nhỏ khoảng 1-1.5 cm.',
        image: 'https://www.origami-instructions.com/images/origami-crane-8.jpg'
      },
      {
        step: 9,
        instruction: 'Kéo nhẹ hai cánh hạc sang hai bên rộng ra. Đồng thời giữ nhẹ phần thân hạc để cánh mở rộng tự nhiên.',
        tip: 'Kéo từ từ và đều tay để thân hạc phồng lên cân đối.',
        image: 'https://www.origami-instructions.com/images/origami-crane-9.jpg'
      },
      {
        step: 10,
        instruction: 'Chỉnh trang lại cánh, cổ và đuôi hạc. Hạc Giấy Origami truyền thống đẹp nhất thế giới đã hoàn thành!',
        tip: 'Truyền thuyết Nhật Bản: gấp 1000 con hạc sẽ được thực hiện một điều ước.',
        image: 'https://www.origami-instructions.com/images/origami-crane-10.jpg'
      }
    ];

    // ======================================================
    // ID: 3 - RỒNG LỬA (Dragon)
    // ======================================================
    const dragonSteps = [
      {
        step: 1,
        instruction: 'Bắt đầu với tờ giấy hình vuông 20x20 cm màu cam/đỏ. Gấp đôi theo cả chiều ngang, chiều dọc và hai đường chéo để tạo nếp gấp cơ sở. Mở giấy ra.',
        tip: 'Cần giấy to và chắc để rồng giữ được dáng. Nên dùng giấy 90 gsm.',
        image: 'https://www.origami-resource-center.com/images/origami-dragon-step1.jpg'
      },
      {
        step: 2,
        instruction: 'Thu gọn giấy về dạng hình vuông nhỏ (Square Base): ấn tâm giấy xuống trong khi 4 phần thu vào tạo hình vuông 4 lớp.',
        tip: 'Phần mở của hình vuông cơ bản hướng xuống phía dưới.',
        image: 'https://www.origami-resource-center.com/images/origami-dragon-step2.jpg'
      },
      {
        step: 3,
        instruction: 'Gấp hai cạnh bên vào giữa trục dọc tạo nếp thoi (Kite fold) ở cả hai mặt hình vuông cơ bản.',
        tip: 'Tiếp theo gấp đỉnh trên xuống và mở nếp ra để chuẩn bị Petal Fold.',
        image: 'https://www.origami-resource-center.com/images/origami-dragon-step3.jpg'
      },
      {
        step: 4,
        instruction: 'Thực hiện Petal Fold để tạo Bird Base (cấu trúc gốc cơ bản của hạc). Lặp lại ở cả hai mặt.',
        tip: 'Bird Base là nền tảng gấp con rồng. Hãy miết phẳng nếp gấp kỹ lưỡng.',
        image: 'https://www.origami-resource-center.com/images/origami-dragon-step4.jpg'
      },
      {
        step: 5,
        instruction: 'Gấp hai cánh bên hông Bird Base xuống 45 độ để tạo hình dạng cánh rồng sơ bộ.',
        tip: 'Cánh rồng ở phần này có góc gấp thoải hơn so với cánh hạc.',
        image: 'https://www.origami-resource-center.com/images/origami-dragon-step5.jpg'
      },
      {
        step: 6,
        instruction: 'Thực hiện Inside Reverse Fold (gập ngược vào trong) trên phần đầu nhọn phía trên để tạo cổ và đầu rồng.',
        tip: 'Cổ rồng cần được uốn cong để tạo tư thế ngẩng đầu oai phong.',
        image: 'https://www.origami-resource-center.com/images/origami-dragon-step6.jpg'
      },
      {
        step: 7,
        instruction: 'Thực hiện Inside Reverse Fold trên phần đuôi để tạo đuôi rồng cong ngược lên.',
        tip: 'Tạo thêm nếp gấp zigzag nhỏ ở đuôi để trông sinh động hơn.',
        image: 'https://www.origami-resource-center.com/images/origami-dragon-step7.jpg'
      },
      {
        step: 8,
        instruction: 'Gấp phần mỏ/đầu nhọn nhỏ để tạo hàm và mỏ rồng. Mở nhẹ phần mỏ rồng để rồng có thể "há miệng".',
        tip: 'Bước này cần nhẹ tay để tránh rách phần đầu nhỏ.',
        image: 'https://www.origami-resource-center.com/images/origami-dragon-step8.jpg'
      },
      {
        step: 9,
        instruction: 'Mở rộng hai cánh rồng ra hai bên và uốn cong để tạo hiệu ứng cánh đang giang rộng bay lên.',
        tip: 'Uốn cong các cạnh cánh ra ngoài sẽ làm cánh trông thực tế hơn.',
        image: 'https://www.origami-resource-center.com/images/origami-dragon-step9.jpg'
      },
      {
        step: 10,
        instruction: 'Chỉnh lại toàn bộ dáng đứng vừng chắc trên 4 chân. Rồng Lửa Origami huyền thoại đã hoàn thành!',
        tip: 'Thêm một chút hồ khô để rồng giữ dáng đẹp lâu hơn.',
        image: 'https://www.origami-resource-center.com/images/origami-dragon-step10.jpg'
      }
    ];

    // ======================================================
    // ID: 11 - THỎ CON (Rabbit/Bunny)
    // ======================================================
    const rabbitSteps = [
      {
        step: 1,
        instruction: 'Bắt đầu với tờ giấy hình vuông 15x15 cm màu trắng hoặc hồng nhạt, mặt màu úp xuống dưới. Gấp đôi tờ giấy theo đường chéo để tạo tam giác.',
        tip: 'Đỉnh nhọn của tam giác hướng lên phía trên.',
        image: 'https://www.origami-fun.com/images/origami-bunny-step-1.jpg'
      },
      {
        step: 2,
        instruction: 'Gấp góc nhọn bên trái và bên phải của đáy tam giác hướng lên chạm vào đỉnh tam giác phía trên.',
        tip: 'Hai đỉnh góc bên phải khớp khít với đỉnh nhọn trên cùng.',
        image: 'https://www.origami-fun.com/images/origami-bunny-step-2.jpg'
      },
      {
        step: 3,
        instruction: 'Gấp hai góc vừa gấp đó tách xa nhau sang hai bên tạo thành đôi tai thỏ đứng thẳng.',
        tip: 'Hai tai thỏ cần đối xứng và độ cao như nhau.',
        image: 'https://www.origami-fun.com/images/origami-bunny-step-3.jpg'
      },
      {
        step: 4,
        instruction: 'Lật mặt sau của mô hình lại. Gấp góc nhọn dưới cùng lên trên khoảng 1/3 chiều cao để tạo phần mõm thỏ.',
        tip: 'Đây sẽ là phần khuôn mặt và mõm của chú thỏ.',
        image: 'https://www.origami-fun.com/images/origami-bunny-step-4.jpg'
      },
      {
        step: 5,
        instruction: 'Gấp cạnh phía trên xuống để thu hẹp phần đầu thỏ và tạo chóp đầu tròn hơn.',
        tip: 'Chỉ gấp một chút nhỏ để đỉnh đầu thỏ bo tròn.',
        image: 'https://www.origami-fun.com/images/origami-bunny-step-5.jpg'
      },
      {
        step: 6,
        instruction: 'Lật mặt trước lại. Vẽ thêm đôi mắt tròn đen, mũi hồng nhỏ và vài sợi râu mỏng. Chú Thỏ Con Origami đáng yêu đã hoàn thành!',
        tip: 'Dùng bút lông màu nhỏ để vẽ chi tiết mặt thỏ thêm sinh động.',
        image: 'https://www.origami-fun.com/images/origami-bunny-step-6.jpg'
      }
    ];

    // ======================================================
    // ID: 12 - BƯỚM XINH (Butterfly)
    // ======================================================
    const butterflySteps = [
      {
        step: 1,
        instruction: 'Đặt tờ giấy vuông mặt màu úp xuống. Gấp đôi theo chiều dọc và chiều ngang tạo nếp gấp "+" rồi mở ra. Tiếp theo gấp theo 2 đường chéo tạo nếp "X" rồi mở ra.',
        tip: 'Cần có đủ 4 đường nếp gấp để thu gọn giấy thành Waterbomb Base.',
        image: 'https://www.origami-fun.com/images/origami-butterfly-step-1.jpg'
      },
      {
        step: 2,
        instruction: 'Thu gọn giấy vào theo các nếp gấp chéo trong khi ấn nhẹ vào tâm giấy để tạo thành hình tam giác kép (Waterbomb Base).',
        tip: 'Hình tam giác kép có 2 lớp ở cả hai cạnh.',
        image: 'https://www.origami-fun.com/images/origami-butterfly-step-2.jpg'
      },
      {
        step: 3,
        instruction: 'Với hình tam giác đặt đỉnh nhọn lên trên, gấp hai góc nhọn ở đáy lên trên chạm vào đỉnh tam giác. Lặp lại ở lớp sau.',
        tip: 'Đây tạo thành hình thoi, mỗi phía 2 cánh bướm.',
        image: 'https://www.origami-fun.com/images/origami-butterfly-step-3.jpg'
      },
      {
        step: 4,
        instruction: 'Lật mô hình lại. Gấp góc nhọn phía dưới lên trên vượt ra ngoài cạnh trên khoảng 1 cm.',
        tip: 'Phần nhô ra sẽ được gập lại ở bước sau để khóa thân bướm.',
        image: 'https://www.origami-fun.com/images/origami-butterfly-step-4.jpg'
      },
      {
        step: 5,
        instruction: 'Gấp phần nhô ra đó đè qua cạnh trên để khóa chặt cấu trúc thân bướm. Miết phẳng mạnh.',
        tip: 'Nếp gấp khóa này giúp thân bướm giữ nguyên hình dạng.',
        image: 'https://www.origami-fun.com/images/origami-butterfly-step-5.jpg'
      },
      {
        step: 6,
        instruction: 'Gấp đôi toàn bộ cấu trúc theo trục dọc chính giữa. Đặt mô hình nằm ngang với thân ở giữa và cánh xòe ra hai bên.',
        tip: 'Thân bướm là phần giữa dày được gấp đôi lại.',
        image: 'https://www.origami-fun.com/images/origami-butterfly-step-6.jpg'
      },
      {
        step: 7,
        instruction: 'Mở nhẹ và uốn cong 4 cánh bướm ra phía ngoài. Bướm Xinh Origami đã hoàn thành và sẵn sàng "bay"!',
        tip: 'Uốn cong nhẹ từng cánh để bướm trông tự nhiên và sống động hơn.',
        image: 'https://www.origami-fun.com/images/origami-butterfly-step-7.jpg'
      }
    ];

    // ======================================================
    // ID: 13 - CON CÁ VÀNG (Goldfish)
    // ======================================================
    const goldfishSteps = [
      {
        step: 1,
        instruction: 'Sử dụng tờ giấy vuông màu cam/vàng 15x15 cm. Đặt mặt màu hướng lên trên. Gấp đôi theo đường chéo tạo tam giác, đỉnh nhọn ở trên, rồi mở ra.',
        tip: 'Nếp gấp chéo sẽ là trục đối xứng chính của cá.',
        image: 'https://www.origami-fun.com/images/origami-fish-step-1.jpg'
      },
      {
        step: 2,
        instruction: 'Gấp hai cạnh bên ngoài hướng vào nếp gấp dọc trung tâm vừa tạo để tạo hình chiếc diều (kite shape).',
        tip: 'Miết thật phẳng hai mép giấy gấp vào giữa.',
        image: 'https://www.origami-fun.com/images/origami-fish-step-2.jpg'
      },
      {
        step: 3,
        instruction: 'Lật mô hình. Gấp đôi theo chiều dọc dọc theo trục chính giữa (gấp mặt sau ra ngoài).',
        tip: 'Đây là thân cá sau khi gấp đôi lại.',
        image: 'https://www.origami-fun.com/images/origami-fish-step-3.jpg'
      },
      {
        step: 4,
        instruction: 'Thực hiện Inside Reverse Fold trên đỉnh nhọn ở đuôi cá: mở nếp gấp đuôi ra và gập phần đuôi lên tạo vây đuôi cá vểnh lên.',
        tip: 'Đây là bước tạo vây đuôi đặc trưng của cá vàng.',
        image: 'https://www.origami-fun.com/images/origami-fish-step-4.jpg'
      },
      {
        step: 5,
        instruction: 'Gấp góc nhọn phần đầu cá chéo xuống dưới 45 độ để tạo phần miệng và đầu cá hướng chúi nhẹ.',
        tip: 'Đầu cá hướng xuống dưới nhẹ trông giống cá đang bơi.',
        image: 'https://www.origami-fun.com/images/origami-fish-step-5.jpg'
      },
      {
        step: 6,
        instruction: 'Mở nhẹ hai bên thân cá để cá phồng lên đôi chút. Dùng bút vẽ mắt tròn lớn cho chú cá. Con Cá Vàng Origami đã hoàn thành!',
        tip: 'Đặt nhẹ cá trên mặt phẳng - cá sẽ tự đứng vững nhờ phần vây đuôi vểnh.',
        image: 'https://www.origami-fun.com/images/origami-fish-step-6.jpg'
      }
    ];

    // ======================================================
    // ID: 14 - HOA HỒNG (Rose - Kawasaki Rose simplified)
    // ======================================================
    const roseSteps = [
      {
        step: 1,
        instruction: 'Sử dụng tờ giấy đỏ 20x20 cm. Gấp tờ giấy tạo lưới 4x4 ô bằng cách gấp đôi 3 lần theo chiều dọc và 3 lần chiều ngang. Mở tờ giấy ra.',
        tip: 'Đường lưới 4x4 rất quan trọng - dùng thước kẻ để căn chính xác.',
        image: 'https://www.origami-resource-center.com/images/origami-rose-step-1.jpg'
      },
      {
        step: 2,
        instruction: 'Gập cả 4 góc ngoài của tờ giấy chạm vào ô lưới đầu tiên gần tâm nhất (Blintz fold). Miết phẳng.',
        tip: 'Đây là bước Blintz fold cơ bản. Tờ giấy thu nhỏ thành hình vuông nhỏ hơn.',
        image: 'https://www.origami-resource-center.com/images/origami-rose-step-2.jpg'
      },
      {
        step: 3,
        instruction: 'Lật ngược mặt sau lại. Gấp tiếp 4 góc hướng vào tâm (Blintz fold lần 2).',
        tip: 'Giấy ngày càng dày hơn. Hãy dùng móng tay miết mạnh các nếp.',
        image: 'https://www.origami-resource-center.com/images/origami-rose-step-3.jpg'
      },
      {
        step: 4,
        instruction: 'Lật lại mặt trước. Gấp tiếp 4 góc vào tâm lần thứ 3.',
        tip: 'Tờ giấy lúc này rất dày và cứng. Hãy kiên nhẫn.',
        image: 'https://www.origami-resource-center.com/images/origami-rose-step-4.jpg'
      },
      {
        step: 5,
        instruction: 'Lật ngược lại. Gập 4 góc nhỏ còn lại vào tâm. Ấn mạnh để cố định.',
        tip: 'Đây là lớp đế của hoa hồng phía sau.',
        image: 'https://www.origami-resource-center.com/images/origami-rose-step-5.jpg'
      },
      {
        step: 6,
        instruction: 'Lật mặt trước lại. Gấp nhẹ 4 góc nhọn ở tâm ra phía rìa ngoài để tạo nhụy hoa.',
        tip: 'Gấp nhẹ tay - đây là phần trang trí nhụy hoa ở trung tâm.',
        image: 'https://www.origami-resource-center.com/images/origami-rose-step-6.jpg'
      },
      {
        step: 7,
        instruction: 'Lộn từng lớp cánh hoa từ dưới lên trên ra phía ngoài bằng cách đặt ngón tay cái dưới và kéo nhẹ cạnh cánh ra ngoài.',
        tip: 'Làm từng cánh một và uốn cong nhẹ ra ngoài.',
        image: 'https://www.origami-resource-center.com/images/origami-rose-step-7.jpg'
      },
      {
        step: 8,
        instruction: 'Tiếp tục lộn lớp cánh hoa tiếp theo. Uốn cong đầu cánh ra ngoài để tạo độ nở rộ như hoa hồng thật.',
        tip: 'Tổng cộng có 3-4 lớp cánh hoa cần được lộn ra.',
        image: 'https://www.origami-resource-center.com/images/origami-rose-step-8.jpg'
      },
      {
        step: 9,
        instruction: 'Chỉnh trang lại các lớp cánh cho đều và căng phồng, uốn cong nhẹ ra ngoài để tạo hình hoa nở rộ.',
        tip: 'Nếu dùng giấy mềm có thể dùng hơi thở thổi nhẹ vào tâm hoa để cánh phồng lên.',
        image: 'https://www.origami-resource-center.com/images/origami-rose-step-9.jpg'
      },
      {
        step: 10,
        instruction: 'Hoàn chỉnh! Đóa Hoa Hồng Origami rực rỡ đã nở. Có thể gắn thêm cành lá từ giấy xanh để tặng người thân.',
        tip: 'Xịt một chút keo hair spray lên hoa để giữ hình dáng đẹp lâu dài.',
        image: 'https://www.origami-resource-center.com/images/origami-rose-step-10.jpg'
      }
    ];

    // ======================================================
    // ID: 15 - CÂY THÔNG (Christmas Tree / Pine Tree)
    // Nguồn: origamiway.com/origami-christmas-tree
    // ======================================================
    const christmasTreeSteps = [
      {
        step: 1,
        instruction: 'Dùng tờ giấy vuông xanh lá 15x15 cm. Đặt mặt màu hướng xuống. Gấp đôi theo đường chéo tạo tam giác lớn.',
        tip: 'Đỉnh nhọn của tam giác hướng lên trên.',
        image: 'https://www.origamiway.com/pics/origami-christmas-tree-step-1.jpg'
      },
      {
        step: 2,
        instruction: 'Gấp hai góc nhọn ở đáy tam giác lên trên chạm vào đỉnh tam giác để tạo hình vuông nhỏ.',
        tip: 'Hai cạnh dưới giờ trở thành đường gấp chéo từ hai bên.',
        image: 'https://www.origamiway.com/pics/origami-christmas-tree-step-2.jpg'
      },
      {
        step: 3,
        instruction: 'Gấp các góc nhọn bên ngoài của hình vuông này hướng vào giữa đường nếp gấp dọc.',
        tip: 'Tạo hình thoi thu gọn ở cả mặt trước và sau.',
        image: 'https://www.origamiway.com/pics/origami-christmas-tree-step-3.jpg'
      },
      {
        step: 4,
        instruction: 'Squash Fold (gấp xẹp): Nâng lớp trên cùng lên rồi ép xẹp xuống sang một bên để tạo hình cành lá tầng đầu của cây thông.',
        tip: 'Đây là bước quan trọng để tạo cành lá tầng cây thông.',
        image: 'https://www.origamiway.com/pics/origami-christmas-tree-step-4.jpg'
      },
      {
        step: 5,
        instruction: 'Lặp lại thao tác Squash Fold ở mặt sau để tạo cành lá tầng thứ hai.',
        tip: 'Hai tầng lá trước và sau phải bằng nhau.',
        image: 'https://www.origamiway.com/pics/origami-christmas-tree-step-5.jpg'
      },
      {
        step: 6,
        instruction: 'Gấp đáy cây lên để tạo phần thân cây và đế cây thông đứng vững.',
        tip: 'Gấp thân cây khoảng 1 cm để tạo nền cây đứng.',
        image: 'https://www.origamiway.com/pics/origami-christmas-tree-step-6.jpg'
      },
      {
        step: 7,
        instruction: 'Tách nhẹ các lớp cánh lá ra để cây thông trông xum xuê hơn. Thêm ngôi sao vàng nhỏ trên đỉnh cây.',
        tip: 'Cây Thông Noel Origami xinh xắn hoàn thành! Có thể gắn thêm hạt cườm nhỏ màu sắc trang trí.',
        image: 'https://www.origamiway.com/pics/origami-christmas-tree-step-7.jpg'
      }
    ];

    // ======================================================
    // ID: 16 - THUYỀN GIẤY (Traditional Paper Boat)
    // ======================================================
    const boatSteps = [
      {
        step: 1,
        instruction: 'Sử dụng tờ giấy chữ nhật A4 (hay A5). Gấp đôi tờ giấy theo chiều ngang, cạnh gấp ở phía trên.',
        tip: 'Đường gấp nằm chính xác ở giữa chiều dài tờ giấy.',
        image: 'https://www.wikihow.com/images/thumb/7/7c/Make-a-Paper-Boat-Step-1-Version-7.jpg/550px-Make-a-Paper-Boat-Step-1-Version-7.jpg'
      },
      {
        step: 2,
        instruction: 'Gấp tờ giấy đôi một lần nữa theo chiều dọc (ngắn) để lấy nếp gấp giữa, rồi mở tờ giấy phẳng lại như trước.',
        tip: 'Nếp dọc ở giữa tờ giấy chỉ là đường định vị trung tâm.',
        image: 'https://www.wikihow.com/images/thumb/1/1e/Make-a-Paper-Boat-Step-2-Version-7.jpg/550px-Make-a-Paper-Boat-Step-2-Version-7.jpg'
      },
      {
        step: 3,
        instruction: 'Gấp hai góc phía trên bên trái và bên phải hướng vào nếp gấp dọc ở giữa, tạo thành hình mái nhà tam giác ở phần trên.',
        tip: 'Hai góc phải chạm đúng vào đường trung tâm.',
        image: 'https://www.wikihow.com/images/thumb/e/e0/Make-a-Paper-Boat-Step-3-Version-7.jpg/550px-Make-a-Paper-Boat-Step-3-Version-7.jpg'
      },
      {
        step: 4,
        instruction: 'Gấp dải giấy chữ nhật phía dưới lên trên ở cả mặt trước và mặt sau, gấp sát chân mái nhà tam giác.',
        tip: 'Dải chân thuyền gấp lên sẽ tạo thành mạn thuyền sau này.',
        image: 'https://www.wikihow.com/images/thumb/8/88/Make-a-Paper-Boat-Step-4-Version-7.jpg/550px-Make-a-Paper-Boat-Step-4-Version-7.jpg'
      },
      {
        step: 5,
        instruction: 'Mở rộng lòng hình tam giác ra và ép xẹp lại thành hình thoi. Lặp lại ở bước gấp tiếp theo.',
        tip: 'Chèn ngón tay vào bên trong để hình thoi xẹp phẳng đều.',
        image: 'https://www.wikihow.com/images/thumb/8/84/Make-a-Paper-Boat-Step-5-Version-7.jpg/550px-Make-a-Paper-Boat-Step-5-Version-7.jpg'
      },
      {
        step: 6,
        instruction: 'Với hình thoi mới, gấp góc dưới lên trên ở cả hai mặt để tạo tam giác nhỏ.',
        tip: 'Mở hình thoi và ép xẹp lại thành hình thoi nhỏ hơn.',
        image: 'https://www.wikihow.com/images/thumb/9/96/Make-a-Paper-Boat-Step-6-Version-7.jpg/550px-Make-a-Paper-Boat-Step-6-Version-7.jpg'
      },
      {
        step: 7,
        instruction: 'Dùng hai tay kéo nhẹ hai góc nhọn phía trên hình thoi sang hai bên. Thuyền Giấy sẽ tự mở ra thành hình thuyền 3D hoàn chỉnh!',
        tip: 'Kéo từ từ và đều hai bên để mạn thuyền mở đẹp. Mở rộng đáy thuyền để thuyền đứng vững.',
        image: 'https://www.wikihow.com/images/thumb/3/3d/Make-a-Paper-Boat-Step-7-Version-7.jpg/550px-Make-a-Paper-Boat-Step-7-Version-7.jpg'
      }
    ];

    // ======================================================
    // ID: 17 - MÁY BAY GIẤY (Paper Airplane - Classic Dart)
    // ======================================================
    const airplaneSteps = [
      {
        step: 1,
        instruction: 'Sử dụng tờ giấy chữ nhật A4 đặt theo chiều dọc (portrait). Gấp đôi tờ giấy dọc theo chiều dài để lấy nếp gấp trung tâm, rồi mở phẳng ra.',
        tip: 'Đây là trục đối xứng chính giữa máy bay.',
        image: 'https://www.wikihow.com/images/thumb/5/59/Make-a-Paper-Airplane-Step-1-Version-9.jpg/550px-Make-a-Paper-Airplane-Step-1-Version-9.jpg'
      },
      {
        step: 2,
        instruction: 'Gấp hai góc nhọn ở đầu trên bên trái và bên phải hướng chéo vào nếp gấp dọc trung tâm, tạo thành hình tam giác mũi nhọn ở phần đầu.',
        tip: 'Hai cạnh gấp chéo phải gặp nhau khít tại đường trục giữa.',
        image: 'https://www.wikihow.com/images/thumb/2/24/Make-a-Paper-Airplane-Step-2-Version-9.jpg/550px-Make-a-Paper-Airplane-Step-2-Version-9.jpg'
      },
      {
        step: 3,
        instruction: 'Gấp hai cạnh mới tạo thành hướng vào trục giữa một lần nữa để mũi máy bay thêm nhọn và thon dài.',
        tip: 'Lặp lại thao tác gấp vào giữa để mũi sắc hơn.',
        image: 'https://www.wikihow.com/images/thumb/0/0e/Make-a-Paper-Airplane-Step-3-Version-9.jpg/550px-Make-a-Paper-Airplane-Step-3-Version-9.jpg'
      },
      {
        step: 4,
        instruction: 'Gấp đôi toàn bộ máy bay theo đường trục dọc giữa (gấp ra phía sau). Máy bay phải có thân đôi đối xứng hoàn toàn.',
        tip: 'Giữ mũi nhọn không bị lệch khi gấp đôi thân máy bay.',
        image: 'https://www.wikihow.com/images/thumb/f/f4/Make-a-Paper-Airplane-Step-4-Version-9.jpg/550px-Make-a-Paper-Airplane-Step-4-Version-9.jpg'
      },
      {
        step: 5,
        instruction: 'Gấp chéo cánh máy bay phải xuống sao cho cạnh trên cánh song song với đường thân máy bay. Lặp lại ở cánh trái.',
        tip: 'Hai cánh phải đối xứng hoàn toàn nhau để máy bay bay thẳng.',
        image: 'https://www.wikihow.com/images/thumb/8/8e/Make-a-Paper-Airplane-Step-5-Version-9.jpg/550px-Make-a-Paper-Airplane-Step-5-Version-9.jpg'
      },
      {
        step: 6,
        instruction: 'Nâng hai cánh lên ngang bằng thân máy bay hoặc hơi hếch nhẹ lên tạo hình chữ Y khi nhìn từ sau. Máy Bay Giấy đã sẵn sàng bay!',
        tip: 'Ném mạnh và thẳng về phía trước để máy bay đạt tầm xa nhất.',
        image: 'https://www.wikihow.com/images/thumb/0/0b/Make-a-Paper-Airplane-Step-6-Version-9.jpg/550px-Make-a-Paper-Airplane-Step-6-Version-9.jpg'
      }
    ];

    // ======================================================
    // ID: 18 - XE TẢI GIẤY (Truck/Car)
    // ======================================================
    const truckSteps = [
      {
        step: 1,
        instruction: 'Sử dụng tờ giấy chữ nhật. Gấp đôi theo chiều ngang (cạnh dài gấp lại). Miết phẳng nếp gấp.',
        tip: 'Tờ giấy sau khi gấp có tỷ lệ giống thân xe tải.',
        image: 'https://www.origami-fun.com/images/origami-car-step-1.jpg'
      },
      {
        step: 2,
        instruction: 'Gấp mép dài phía dưới lên trên khoảng 1.5-2 cm để tạo gầm xe và nơi đặt bánh xe.',
        tip: 'Gấp đều cả hai lớp giấy cùng lúc.',
        image: 'https://www.origami-fun.com/images/origami-car-step-2.jpg'
      },
      {
        step: 3,
        instruction: 'Gấp hai mép ngắn ở hai đầu vào trong khoảng 1-1.5 cm để tạo đầu và đuôi xe.',
        tip: 'Gấp hai đầu vào trong để hoàn thiện hình dáng xe.',
        image: 'https://www.origami-fun.com/images/origami-car-step-3.jpg'
      },
      {
        step: 4,
        instruction: 'Gấp chéo góc trên bên trái xuống dưới khoảng 45 độ để tạo phần buồng lái kính nghiêng.',
        tip: 'Góc buồng lái nghiêng cho thấy hình dáng cabin xe tải hiện đại.',
        image: 'https://www.origami-fun.com/images/origami-car-step-4.jpg'
      },
      {
        step: 5,
        instruction: 'Gấp các góc nhọn thừa ra phía sau hoặc tucked in vào trong để hoàn thiện hình dáng gọn gàng.',
        tip: 'Giúp xe có viền gọn và không có góc nhọn thừa.',
        image: 'https://www.origami-fun.com/images/origami-car-step-5.jpg'
      },
      {
        step: 6,
        instruction: 'Dùng bút màu đen vẽ 4 bánh xe hình tròn ở phần gầm xe phía dưới.',
        tip: 'Tô màu bánh xe đen và thêm vành bạc để trông đẹp hơn.',
        image: 'https://www.origami-fun.com/images/origami-car-step-6.jpg'
      },
      {
        step: 7,
        instruction: 'Vẽ thêm cửa sổ kính lái, đèn pha và cửa thùng hàng. Xe Tải Giấy Origami đã hoàn thành!',
        tip: 'Tô màu sắc tươi sáng cho xe để trông sinh động.',
        image: 'https://www.origami-fun.com/images/origami-car-step-7.jpg'
      }
    ];

    // ======================================================
    // ID: 19 - CHIẾC CỐC GIẤY (Paper Cup)
    // Nguồn: origami.me/cup
    // ======================================================
    const cupSteps = [
      {
        step: 1,
        instruction: 'Sử dụng tờ giấy hình vuông. Đặt tờ giấy như hình thoi (xoay 45 độ, một góc hướng về phía bạn). Gấp đôi lên trên tạo hình tam giác lớn nằm ngang.',
        tip: 'Cạnh gấp nằm trên, đỉnh nhọn hướng về phía bạn ở dưới.',
        image: 'https://www.origami-instructions.com/images/origami-cup-1.jpg'
      },
      {
        step: 2,
        instruction: 'Gấp góc nhọn bên trái của đáy tam giác chéo lên phía bên phải, sao cho cạnh trên của nếp gấp song song với đáy tam giác.',
        tip: 'Điểm gấp ở cạnh trái và đầu nhọn chạm vào cạnh nghiêng bên phải.',
        image: 'https://www.origami-instructions.com/images/origami-cup-2.jpg'
      },
      {
        step: 3,
        instruction: 'Tương tự gấp góc nhọn bên phải chéo sang bên trái đối xứng với bước vừa làm.',
        tip: 'Hai nếp gấp chéo sẽ xếp chồng lên nhau ở phần giữa.',
        image: 'https://www.origami-instructions.com/images/origami-cup-3.jpg'
      },
      {
        step: 4,
        instruction: 'Gập lớp giấy trên của đỉnh tam giác phía trên xuống phía trước, đè chèn vào túi gấp ở giữa.',
        tip: 'Đây là vành phía trước của cốc.',
        image: 'https://www.origami-instructions.com/images/origami-cup-4.jpg'
      },
      {
        step: 5,
        instruction: 'Lật mặt sau của cốc lại. Gập lớp đỉnh tam giác còn lại xuống phía trước (mặt sau của cốc) để khóa cấu trúc.',
        tip: 'Đây là vành phía sau của cốc.',
        image: 'https://www.origami-instructions.com/images/origami-cup-5.jpg'
      },
      {
        step: 6,
        instruction: 'Dùng tay bóp nhẹ hai bên cốc để mở rộng khoang bên trong. Chiếc Cốc Giấy Origami sẵn sàng đựng đồ nhẹ!',
        tip: 'Cốc giấy truyền thống này có thể đựng hạt, kẹo nhỏ hoặc thậm chí nước trong thời gian ngắn!',
        image: 'https://www.origami-instructions.com/images/origami-cup-6.jpg'
      }
    ];

    // ======================================================
    // ID: 20 - NGÔI SAO MAY MẮN (Lucky Star)
    // Nguồn: origami.me/lucky-star
    // ======================================================
    const luckyStarSteps = [
      {
        step: 1,
        instruction: 'Chuẩn bị một dải giấy dài và mỏng, kích thước tiêu chuẩn khoảng 1.5 cm rộng x 30 cm dài. Có thể dùng giấy origami chuyên dụng hoặc cắt từ tờ giấy A4.',
        tip: 'Dải giấy càng dài càng tạo được ngôi sao phồng đẹp hơn.',
        image: 'https://www.origami-resource-center.com/images/lucky-star-step-1.jpg'
      },
      {
        step: 2,
        instruction: 'Uốn cong đầu ngắn của dải giấy tạo vòng lặp và luồn qua tạo nút thắt đơn giản.',
        tip: 'Tạo nút thắt thoải (không siết chặt ngay) để dễ điều chỉnh.',
        image: 'https://www.origami-resource-center.com/images/lucky-star-step-2.jpg'
      },
      {
        step: 3,
        instruction: 'Kéo hai đầu dải giấy từ từ nhẹ nhàng cho đến khi nút thắt siết chặt thành hình ngũ giác đều phẳng. Nhét phần đầu ngắn thừa vào trong.',
        tip: 'Hình ngũ giác phải cân đối và phẳng. Không siết quá chặt.',
        image: 'https://www.origami-resource-center.com/images/lucky-star-step-3.jpg'
      },
      {
        step: 4,
        instruction: 'Gấp dải giấy dài quấn chéo theo các cạnh của ngũ giác, tự nhiên theo đường gấp của cạnh ngũ giác.',
        tip: 'Dải giấy tự chạy theo góc 72 độ của ngũ giác đều.',
        image: 'https://www.origami-resource-center.com/images/lucky-star-step-4.jpg'
      },
      {
        step: 5,
        instruction: 'Tiếp tục quấn dải giấy quanh các cạnh ngũ giác cho đến khi chỉ còn thừa khoảng 2 cm.',
        tip: 'Quấn khít nhưng không quá chặt để sau này có thể bóp phồng ngôi sao.',
        image: 'https://www.origami-resource-center.com/images/lucky-star-step-5.jpg'
      },
      {
        step: 6,
        instruction: 'Nhét phần đầu giấy thừa cuối cùng vào khe gấp của ngũ giác để cố định dải giấy.',
        tip: 'Nếu đuôi giấy quá dài thì cắt bớt trước khi nhét vào.',
        image: 'https://www.origami-resource-center.com/images/lucky-star-step-6.jpg'
      },
      {
        step: 7,
        instruction: 'Dùng hai ngón tay cái bóp mạnh vào giữa mỗi cạnh của ngũ giác theo thứ tự để tạo độ phồng cho ngôi sao. Làm lần lượt cả 5 cạnh.',
        tip: 'Bóp nhẹ và đều tay để 5 góc nhọn của ngôi sao nổi lên đồng đều.',
        image: 'https://www.origami-resource-center.com/images/lucky-star-step-7.jpg'
      },
      {
        step: 8,
        instruction: 'Chỉnh lại 5 góc nhọn và căn chỉnh hình dáng. Ngôi Sao May Mắn Origami đã hoàn thành! Làm nhiều ngôi sao bỏ vào lọ thủy tinh để ước nguyện!',
        tip: 'Truyền thuyết: tặng 100 ngôi sao cho người bạn yêu thương sẽ mang lại may mắn cả năm.',
        image: 'https://www.origami-resource-center.com/images/lucky-star-step-8.jpg'
      }
    ];

    // =========================================================
    // THỰC HIỆN CẬP NHẬT VÀO DATABASE
    // =========================================================
    const allModels = [
      { id: 1, name: 'Trái Tim', steps: heartSteps },
      { id: 2, name: 'Hạc Giấy', steps: craneSteps },
      { id: 3, name: 'Rồng Lửa', steps: dragonSteps },
      { id: 11, name: 'Thỏ Con', steps: rabbitSteps },
      { id: 12, name: 'Bướm Xinh', steps: butterflySteps },
      { id: 13, name: 'Con Cá Vàng', steps: goldfishSteps },
      { id: 14, name: 'Hoa Hồng', steps: roseSteps },
      { id: 15, name: 'Cây Thông', steps: christmasTreeSteps },
      { id: 16, name: 'Thuyền Giấy', steps: boatSteps },
      { id: 17, name: 'Máy Bay Giấy', steps: airplaneSteps },
      { id: 18, name: 'Xe Tải Giấy', steps: truckSteps },
      { id: 19, name: 'Chiếc Cốc Giấy', steps: cupSteps },
      { id: 20, name: 'Ngôi Sao May Mắn', steps: luckyStarSteps },
    ];

    for (const model of allModels) {
      // Xóa bước cũ
      await conn.query('DELETE FROM origami_steps WHERE origami_id = ?', [model.id]);
      // Chèn bước mới
      for (const s of model.steps) {
        await conn.query(
          `INSERT INTO origami_steps (origami_id, step_number, instruction, tip, image_url, estimated_duration) 
           VALUES (?, ?, ?, ?, ?, 1)`,
          [model.id, s.step, s.instruction, s.tip, s.image]
        );
      }
      console.log(`✅ [${model.id}] "${model.name}": ${model.steps.length} bước gấp đã cập nhật.`);
    }

    console.log('\n🎉 Hoàn thành! Tất cả mẫu đã có hướng dẫn gấp riêng biệt và chính xác!');

  } catch (err) {
    console.error('❌ Lỗi:', err.message);
  } finally {
    await conn.end();
  }
}

populateRealSteps().catch(console.error);
