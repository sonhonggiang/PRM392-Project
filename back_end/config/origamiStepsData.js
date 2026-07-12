const stepsData = {
  1: [ // Trái Tim
    { step: 1, text: 'Chuẩn bị một tờ giấy hình vuông màu đỏ (15x15 cm). Đặt mặt màu úp xuống. Gấp đôi tờ giấy theo đường chéo tạo thành hình tam giác lớn, miết phẳng nếp gấp rồi mở ra.', tip: 'Hãy miết nếp gấp thật thẳng và chính xác ở đường chéo chính.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-1.png' },
    { step: 2, text: 'Xoay tờ giấy và tiếp tục gấp đôi theo đường chéo còn lại để tạo thành 2 đường nếp gấp chéo cắt nhau ở tâm. Mở tờ giấy phẳng ra.', tip: 'Đảm bảo giao điểm của 2 nếp gấp nằm đúng trung tâm tờ giấy.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-2.png' },
    { step: 3, text: 'Gấp đỉnh góc trên cùng của tờ giấy xuống sao cho chạm đúng vào tâm chính giữa (giao điểm của 2 nếp gấp chéo).', tip: 'Đỉnh góc nhọn phải nằm chuẩn xác trên điểm tâm.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-3.png' },
    { step: 4, text: 'Gấp góc dưới cùng của tờ giấy hướng lên trên sao cho đỉnh góc chạm vào cạnh ngang ở phần đầu trên của tờ giấy.', tip: 'Góc nhọn dưới cùng phải đi thẳng qua trục dọc trung tâm.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-4.png' },
    { step: 5, text: 'Gấp cạnh bên dưới bên trái hướng lên trên theo đường nếp gấp dọc trung tâm.', tip: 'Cạnh gấp xiên sẽ khớp khít với trục nếp gấp dọc ở giữa.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-5.png' },
    { step: 6, text: 'Gấp cạnh bên dưới bên phải tương tự hướng lên trên theo đường nếp gấp dọc trung tâm. Lúc này hình dáng trái tim cơ bản đã lộ ra.', tip: 'Hãy căn chỉnh hai bên thật đối xứng để trái tim cân đối.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-6.png' },
    { step: 7, text: 'Lật mặt sau của trái tim lại để chuẩn bị bo các góc nhọn của trái tim cho tròn trịa.', tip: 'Giữ chặt các nếp gấp trước đó để không bị xô lệch khi lật.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-7.png' },
    { step: 8, text: 'Gấp hai góc nhọn ở đỉnh phía trên xuống dưới khoảng 1-2 cm để tạo hình bo tròn cho phần đầu của trái tim.', tip: 'Gấp hai đỉnh bằng nhau để hai nửa trái tim cao bằng nhau.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-8.png' },
    { step: 9, text: 'Gấp hai góc nhọn ở hai bên rìa trái và phải hướng vào trong một chút để làm thon gọn dáng trái tim.', tip: 'Chỉ cần gấp một góc nhỏ để bo tròn cạnh hông của trái tim.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-9.png' },
    { step: 10, text: 'Lật ngược lại mặt trước. Xin chúc mừng! Bạn đã hoàn thành một Trái Tim Origami vô cùng dễ thương và ý nghĩa.', tip: 'Dùng tay vuốt nhẹ mặt trước cho phẳng phiu và cân đối.', img: 'https://origami.me/wp-content/uploads/2024/02/origami-heart-diagram-step-10.png' }
  ],
  2: [ // Hạc Giấy
    { step: 1, text: 'Đặt mặt màu tờ giấy hình vuông lên trên. Gấp đôi tờ giấy theo đường chéo tạo thành hình tam giác lớn rồi mở ra để lấy nếp gấp chéo chính giữa.', tip: 'Đường chéo này sẽ làm chuẩn cho các bước tiếp theo.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-1.png' },
    { step: 2, text: 'Gấp hai cạnh dưới bên trái và bên phải hướng vào trong sao cho trùng khít với nếp gấp chéo chính giữa vừa tạo ở Bước 1. Tạo hình giống chiếc diều.', tip: 'Hãy miết phẳng và sát nếp gấp để các góc nhọn ở đuôi thật sắc nét.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-2.png' },
    { step: 3, text: 'Lật mặt sau của tờ giấy lại.', tip: 'Nhớ giữ nguyên nếp gấp của mặt trước khi lật.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-3.png' },
    { step: 4, text: 'Tiếp tục gấp hai cạnh bên ngoài hướng vào đường nếp gấp dọc ở chính giữa một lần nữa để làm thon gọn thân chú chim hạc.', tip: 'Hãy căn chỉnh thật khít và miết mạnh tay.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-4.png' },
    { step: 5, text: 'Gấp đỉnh góc nhọn phía dưới lên trên sao cho trùng khít với đỉnh góc nhọn phía trên cùng.', tip: 'Đường gấp ngang này sẽ chia đôi chiều dài của thân hạc.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-5.png' },
    { step: 6, text: 'Gấp ngược một phần nhỏ của đầu nhọn đó xuống dưới khoảng 2 cm để tạo hình chiếc mỏ cho chú hạc.', tip: 'Đây chính là phần đầu và mỏ của chim hạc.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-6.png' },
    { step: 7, text: 'Gấp đôi toàn bộ cấu trúc theo chiều dọc từ trái sang phải dọc theo nếp gấp trục giữa.', tip: 'Giữ chặt phần đầu và cổ hạc bên trong khi gấp đôi lại.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-7.png' },
    { step: 8, text: 'Kéo nhẹ nhàng phần cổ và đầu của hạc (phần có mỏ nhọn) hướng xiên lên trên một chút để tạo tư thế đứng kiêu hãnh.', tip: 'Kéo từ từ để tránh làm rách giấy ở phần nách gấp.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-8.png' },
    { step: 9, text: 'Miết phẳng nếp gấp ở phần chân cổ để cố định tư thế cho chú hạc. Kéo nhẹ phần mỏ chim nằm ngang ra.', tip: 'Tạo nếp gấp sắc nét ở cổ hạc để chú hạc có thể đứng vững.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-9.png' },
    { step: 10, text: 'Chỉnh sửa hai bên cánh rộng ra một chút. Bạn đã hoàn thành chú Hạc Origami tuyệt đẹp và thanh thoát!', tip: 'Đặt chú hạc lên bàn phẳng để kiểm tra độ cân bằng.', img: 'https://origami.me/wp-content/uploads/2026/06/origami-swan-diagram-step-10.png' }
  ],
  3: [ // Rồng Lửa
    { step: 1, text: 'Bắt đầu bằng cách gấp dọc và ngang tạo nếp gấp chữ thập trên tờ giấy vuông.', tip: 'Miết nếp gấp phẳng phiu.', img: 'https://www.origami-instructions.com/images/dragon/thumbnails/01-origami-dragon.jpg' },
    { step: 2, text: 'Tiếp tục gấp chéo các góc để tạo nếp gấp X hướng vào tâm.', tip: 'Hãy gấp thật đối xứng.', img: 'https://www.origami-instructions.com/images/dragon/thumbnails/04-origami-dragon.jpg' },
    { step: 3, text: 'Thu gọn giấy theo các nếp vừa tạo để đưa về dạng hình vuông cơ sở (Square Base).', tip: 'Tạo hình thoi có các mép mở hướng xuống.', img: 'https://www.origami-instructions.com/images/dragon/thumbnails/07-origami-dragon.jpg' },
    { step: 4, text: 'Gấp các góc bên hông hướng vào đường dọc chính giữa của hình vuông.', tip: 'Miết mạnh tay để lấy nếp gấp.', img: 'https://www.origami-instructions.com/images/dragon/thumbnails/10-origami-dragon.jpg' },
    { step: 5, text: 'Mở rộng lớp giấy trên cùng hướng lên trên để tạo thành cánh hình thoi dài (Petal Fold).', tip: 'Vuốt phẳng phần giấy bên trong cánh.', img: 'https://www.origami-instructions.com/images/dragon/thumbnails/14-origami-dragon.jpg' },
    { step: 6, text: 'Gấp ngược cánh giấy đó hướng thẳng lên trên để tạo sống lưng rồng.', tip: 'Vuốt dọc nếp lưng rồng.', img: 'https://www.origami-instructions.com/images/dragon/thumbnails/18-origami-dragon.jpg' },
    { step: 7, text: 'Thực hiện gấp ngược bên trong (Inside Reverse Fold) góc nhọn phía trước để tạo đầu và cổ rồng.', tip: 'Kéo nhẹ góc nghiêng khoảng 45 độ.', img: 'https://www.origami-instructions.com/images/dragon/thumbnails/22-origami-dragon.jpg' },
    { step: 8, text: 'Uốn nếp nhỏ trên đầu rồng để tạo sừng rồng oai vệ.', tip: 'Bóp nhẹ đầu nhọn để tạo dáng mỏ rồng.', img: 'https://www.origami-instructions.com/images/dragon/thumbnails/26-origami-dragon.jpg' },
    { step: 9, text: 'Gấp các nếp nhỏ phía chân rồng ở cả hai bên hông.', tip: 'Căn chỉnh hai chân trước và chân sau cân bằng.', img: 'https://www.origami-instructions.com/images/dragon/thumbnails/30-origami-dragon.jpg' },
    { step: 10, text: 'Mở rộng cánh rồng sang hai bên hông và uốn nhẹ đuôi rồng cong oai vệ. Rồng Lửa Origami đã hoàn tất!', tip: 'Mở cánh rồng căng rộng để rồng trông dũng mãnh nhất.', img: 'https://www.origami-instructions.com/images/dragon/thumbnails/35-origami-dragon.jpg' }
  ],
  11: [ // Thỏ Con
    { step: 1, text: 'Đặt giấy vuông chéo dạng kim cương. Gấp đôi chéo tạo hình tam giác nằm ngang.', tip: 'Mặt màu của tờ giấy nằm ở bên ngoài.', img: 'https://www.origami-instructions.com/images/rabbit/thumbnails/01-origami-rabbit.jpg' },
    { step: 2, text: 'Gấp góc nhọn bên trái chéo hướng lên trên trùng với đỉnh tam giác dọc giữa.', tip: 'Miết thẳng nếp gấp hông trái.', img: 'https://www.origami-instructions.com/images/rabbit/thumbnails/02-origami-rabbit.jpg' },
    { step: 3, text: 'Gấp tương tự góc nhọn bên phải chéo lên trên trùng khít với đỉnh tam giác dọc giữa.', tip: 'Lúc này mô hình có dạng hình thoi đứng.', img: 'https://www.origami-instructions.com/images/rabbit/thumbnails/03-origami-rabbit.jpg' },
    { step: 4, text: 'Gập đầu nhọn đuôi thỏ bên dưới ngược lên trên một đoạn ngắn để tạo đuôi.', tip: 'Phần gấp lên này sẽ tạo đuôi thỏ xinh xắn.', img: 'https://www.origami-instructions.com/images/rabbit/thumbnails/06-origami-rabbit.jpg' },
    { step: 5, text: 'Gập đôi toàn bộ mô hình theo trục dọc chính giữa (lật mặt sau ra ngoài).', tip: 'Đôi tai thỏ sẽ tự động lộ ra phía trên.', img: 'https://www.origami-instructions.com/images/rabbit/thumbnails/08-origami-rabbit.jpg' },
    { step: 6, text: 'Kéo nhẹ đôi tai thỏ hướng đứng xiên lên trên và vuốt chặt nếp gấp giữ dáng.', tip: 'Kéo vừa phải để tai thỏ hướng chéo cân đối.', img: 'https://www.origami-instructions.com/images/rabbit/thumbnails/10-origami-rabbit.jpg' },
    { step: 7, text: 'Gấp nhẹ phần mũi thỏ vào trong để làm mõm thỏ tròn trịa.', tip: 'Dùng ngón tay ấn nhẹ nếp cằm vào phía trong.', img: 'https://www.origami-instructions.com/images/rabbit/thumbnails/12-origami-rabbit.jpg' },
    { step: 8, text: 'Đặt chú thỏ đứng cân bằng trên bàn phẳng. Chúc mừng bạn đã hoàn thành chú Thỏ Con Origami tinh nghịch!', tip: 'Bạn có thể vẽ thêm mắt và mũi tròn màu hồng bằng bút lông.', img: 'https://www.origami-instructions.com/images/rabbit/thumbnails/16-origami-rabbit.jpg' }
  ],
  12: [ // Bướm Xinh
    { step: 1, text: 'Gấp đôi tờ giấy vuông theo cả chiều dọc, ngang và chéo rồi mở ra để tạo nếp.', tip: 'Các nếp chéo giúp thu xếp giấy thành hình tam giác kép.', img: 'https://www.origami-instructions.com/images/easy-butterfly/thumbnails/01-origami-easy-butterfly.jpg' },
    { step: 2, text: 'Thu gọn giấy theo các nếp chéo chéo tạo thành hình tam giác kép (Waterbomb Base).', tip: 'Ép xẹp tam giác xuống đều hai bên.', img: 'https://www.origami-instructions.com/images/easy-butterfly/thumbnails/01a-origami-easy-butterfly.jpg' },
    { step: 3, text: 'Gấp hai góc nhọn ở mép dưới hướng lên trên chạm sát đỉnh nhọn của tam giác.', tip: 'Chỉ gấp lớp giấy trên cùng, chừa lớp dưới lại.', img: 'https://www.origami-instructions.com/images/easy-butterfly/thumbnails/03-origami-easy-butterfly.jpg' },
    { step: 4, text: 'Lật ngược mặt sau của mô hình hướng lên phía trước.', tip: 'Đỉnh tam giác giờ chỉ xuống phía dưới.', img: 'https://www.origami-instructions.com/images/easy-butterfly/thumbnails/03a-origami-easy-butterfly.jpg' },
    { step: 5, text: 'Kéo đỉnh nhọn tam giác ngược lên phía trên vượt quá cạnh ngang khoảng 1 cm.', tip: 'Hai cạnh bên hông sẽ hơi cong nhẹ lên tự nhiên.', img: 'https://www.origami-instructions.com/images/easy-butterfly/thumbnails/04-origami-easy-butterfly.jpg' },
    { step: 6, text: 'Gập góc nhọn nhô ra đó đè chèn qua mép ngang để khóa chặt cấu trúc cánh bướm.', tip: 'Miết thật phẳng nếp khóa cằm này.', img: 'https://www.origami-instructions.com/images/easy-butterfly/thumbnails/04a-origami-easy-butterfly.jpg' },
    { step: 7, text: 'Gập đôi toàn bộ cánh bướm theo trục dọc sống lưng giữa.', tip: 'Nếp gấp giúp đôi cánh bướm vểnh lên 3D sống động.', img: 'https://www.origami-instructions.com/images/easy-butterfly/thumbnails/05-origami-easy-butterfly.jpg' },
    { step: 8, text: 'Mở cánh bướm rộng sang hai bên. Bướm Xinh Origami rực rỡ đã đậu thành công!', tip: 'Dùng tay uốn cong nhẹ hai cánh trên để bướm trông chân thật hơn.', img: 'https://www.origami-instructions.com/images/easy-butterfly/thumbnails/08-origami-easy-butterfly.jpg' }
  ],
  13: [ // Con Cá Vàng
    { step: 1, text: 'Gấp chéo tờ giấy hình vuông màu cam để tạo thành tam giác lớn.', tip: 'Đặt cạnh dài tam giác nằm ngang ở dưới.', img: 'https://www.origami-instructions.com/images/easy-goldfish/thumbnails/01-easy-origami-goldfish.jpg' },
    { step: 2, text: 'Gập hai góc nhọn bên hông hướng chéo xuống chạm vào trục giữa cằm cá.', tip: 'Tạo thành hình dạng con thoi cơ bản.', img: 'https://www.origami-instructions.com/images/easy-goldfish/thumbnails/02-easy-origami-goldfish.jpg' },
    { step: 3, text: 'Gấp ngược hai góc nhọn đó chéo sang hai bên rìa để tạo hình vây cá bơi.', tip: 'Góc nghiêng khoảng 30 độ hướng ra ngoài.', img: 'https://www.origami-instructions.com/images/easy-goldfish/thumbnails/02a-easy-origami-goldfish.jpg' },
    { step: 4, text: 'Gấp đỉnh nhọn phía sau đuôi cá hướng xiên lên trên tạo dáng vây đuôi cá.', tip: 'Đuôi vểnh giúp cá giữ thăng bằng.', img: 'https://www.origami-instructions.com/images/easy-goldfish/thumbnails/03-easy-origami-goldfish.jpg' },
    { step: 5, text: 'Gập đôi toàn bộ con cá dọc theo sống lưng chính giữa.', tip: 'Hai vây cá đối xứng nằm ở hai bên.', img: 'https://www.origami-instructions.com/images/easy-goldfish/thumbnails/04-easy-origami-goldfish.jpg' },
    { step: 6, text: 'Dùng kéo cắt nhẹ một đường thẳng ở vây đuôi cá và vuốt xòe rộng sang hai bên.', tip: 'Cắt nhẹ nhàng tránh phạm vào thân cá.', img: 'https://www.origami-instructions.com/images/easy-goldfish/thumbnails/05-easy-origami-goldfish.jpg' },
    { step: 7, text: 'Tách nhẹ vây đuôi, vẽ thêm mắt tròn xinh xắn cho chú Cá Vàng Origami lướt sóng!', tip: 'Đặt chú cá vàng lên bàn phẳng để trông sinh động nhất.', img: 'https://www.origami-instructions.com/images/easy-goldfish/thumbnails/08-easy-origami-goldfish.jpg' }
  ],
  14: [ // Hoa Hồng
    { step: 1, text: 'Gấp dọc và ngang tạo nếp gấp 4x4 ô vuông trên tờ giấy đỏ.', tip: 'Vuốt phẳng các đường nếp thật thẳng thớm.', img: 'https://www.origami-instructions.com/images/rose/thumbnails/01-origami-rose.jpg' },
    { step: 2, text: 'Gấp cả 4 góc nhọn ngoài vào tâm chính giữa tờ giấy (Blintz Fold).', tip: 'Tạo hình vuông mới nhỏ hơn.', img: 'https://www.origami-instructions.com/images/rose/thumbnails/02-origami-rose.jpg' },
    { step: 3, text: 'Tiếp tục gấp 4 góc của hình vuông vào tâm chính giữa lần thứ hai.', tip: 'Miết chặt mép nếp gấp.', img: 'https://www.origami-instructions.com/images/rose/thumbnails/03-origami-rose.jpg' },
    { step: 4, text: 'Tiếp tục gấp 4 góc vào tâm chính giữa lần thứ ba để tạo nhiều lớp cánh xếp.', tip: 'Sử dụng cạnh phẳng để miết do giấy đã khá dày.', img: 'https://www.origami-instructions.com/images/rose/thumbnails/04-origami-rose.jpg' },
    { step: 5, text: 'Lật ngược mặt sau của mô hình dày ra trước.', tip: 'Đè nhẹ ở tâm tránh bung cánh.', img: 'https://www.origami-instructions.com/images/rose/thumbnails/05-origami-rose.jpg' },
    { step: 6, text: 'Tiếp tục gấp 4 góc của mặt sau hướng vào tâm chính giữa.', tip: 'Đây là đế của đóa hoa hồng.', img: 'https://www.origami-instructions.com/images/rose/thumbnails/06-origami-rose.jpg' },
    { step: 7, text: 'Gấp chéo nhẹ 4 đỉnh nhọn ở giữa ra phía ngoài mép.', tip: 'Tạo nhụy hoa lõi trong cùng.', img: 'https://www.origami-instructions.com/images/rose/thumbnails/07-origami-rose.jpg' },
    { step: 8, text: 'Kéo nhẹ nhàng từng cánh hoa từ lớp dưới kéo lộn ngược ra mặt ngoài.', tip: 'Cẩn thận kẻo rách giấy ở góc nách.', img: 'https://www.origami-instructions.com/images/rose/thumbnails/09-origami-rose.jpg' },
    { step: 9, text: 'Uốn cong và chỉnh lại các mép cánh hoa hồng nở bung phồng rực rỡ.', tip: 'Chúc mừng bạn đã hoàn thiện đóa Hoa Hồng Origami nở rộ tuyệt đẹp!', img: 'https://www.origami-instructions.com/images/rose/thumbnails/11-origami-rose.jpg' }
  ],
  15: [ // Cây Thông
    { step: 1, text: 'Gấp chéo tờ giấy xanh tạo tam giác lớn, đặt đỉnh tam giác hướng lên trên.', tip: 'Mặt màu nằm ở bên ngoài.', img: 'https://www.origami-instructions.com/images/easy-christmas-tree/thumbnails/01-easy-christmas-tree.jpg' },
    { step: 2, text: 'Gấp góc nhọn bên trái hướng lên trên chạm đỉnh nhọn tam giác.', tip: 'Vuốt thẳng nếp gấp dọc bên trái.', img: 'https://www.origami-instructions.com/images/easy-christmas-tree/thumbnails/02-easy-christmas-tree.jpg' },
    { step: 3, text: 'Gấp tương tự góc nhọn bên phải chéo lên trên trùng khít đỉnh tam giác.', tip: 'Hình dạng mô hình chuyển thành hình thoi đứng.', img: 'https://www.origami-instructions.com/images/easy-christmas-tree/thumbnails/03-easy-christmas-tree.jpg' },
    { step: 4, text: 'Gấp cạnh bên ngoài hình thoi chéo vào đường nếp trục dọc giữa.', tip: 'Thực hiện cho cả hai bên hông.', img: 'https://www.origami-instructions.com/images/easy-christmas-tree/thumbnails/04-easy-christmas-tree.jpg' },
    { step: 5, text: 'Mở rộng lớp giấy chéo và ép xẹp xuống (Squash Fold) để tạo thành tán cành lá.', tip: 'Căn chỉnh hai tán lá đối xứng cân đối.', img: 'https://www.origami-instructions.com/images/easy-christmas-tree/thumbnails/06-easy-christmas-tree.jpg' },
    { step: 6, text: 'Gấp mép giấy thừa ở đáy hướng chéo lên trên để làm đế thân cây thông.', tip: 'Gấp vuông vắn để cây thông đứng thẳng.', img: 'https://www.origami-instructions.com/images/easy-christmas-tree/thumbnails/07a-easy-christmas-tree.jpg' },
    { step: 7, text: 'Tách nhẹ các nếp gấp tầng lá ra để tạo độ xum xuê 3D cho Cây Thông Noel Origami!', tip: 'Có thể dán một ngôi sao vàng nhỏ lên đỉnh cây thông.', img: 'https://www.origami-instructions.com/images/easy-christmas-tree/thumbnails/12-easy-christmas-tree.jpg' }
  ],
  16: [ // Thuyền Giấy
    { step: 1, text: 'Sử dụng một tờ giấy hình chữ nhật. Gấp đôi tờ giấy theo chiều ngang.', tip: 'Đường gấp nằm ở phía trên.', img: 'https://www.origami-instructions.com/images/simple-boat/thumbnails/01-simple-origami-boat.jpg' },
    { step: 2, text: 'Gấp hai góc trên hướng vào trục dọc ở giữa tạo hình mái nhà tam giác.', tip: 'Căn chỉnh hai góc chạm khít nhau ở giữa.', img: 'https://www.origami-instructions.com/images/simple-boat/thumbnails/02-simple-origami-boat.jpg' },
    { step: 3, text: 'Gấp dải giấy chữ nhật phía dưới hướng chéo lên trên sát chân tam giác.', tip: 'Lật mặt sau và làm tương tự cho dải giấy còn lại.', img: 'https://www.origami-instructions.com/images/simple-boat/thumbnails/03-simple-origami-boat.jpg' },
    { step: 4, text: 'Nhét các góc nhọn nhô ra của dải giấy vào phía trong để khóa cấu trúc tam giác.', tip: 'Miết phẳng nếp viền hai bên hông.', img: 'https://www.origami-instructions.com/images/simple-boat/thumbnails/04-simple-origami-boat.jpg' },
    { step: 5, text: 'Mở rộng lòng tam giác ra từ phía dưới rồi xếp ép xẹp lại thành hình thoi.', tip: 'Ấn nhẹ góc đáy thoi phẳng phiu.', img: 'https://www.origami-instructions.com/images/simple-boat/thumbnails/05-simple-origami-boat.jpg' },
    { step: 6, text: 'Với hình thoi, gấp góc dưới chéo lên trên trùng với đỉnh nhọn đầu (làm cả 2 mặt).', tip: 'Tạo thành hình tam giác nhỏ hơn.', img: 'https://www.origami-instructions.com/images/simple-boat/thumbnails/06-simple-origami-boat.jpg' },
    { step: 7, text: 'Tiếp tục mở lòng tam giác và ép phẳng thành hình thoi nhỏ mới.', tip: 'Đây là bước chuẩn bị kéo mạn thuyền.', img: 'https://www.origami-instructions.com/images/simple-boat/thumbnails/07-simple-origami-boat.jpg' },
    { step: 8, text: 'Dùng hai tay kéo nhẹ nhàng hai góc nhọn phía trên mạn thoi sang hai bên rộng ra. Thuyền Giấy đã lộ diện!', tip: 'Mở rộng khoang đáy thuyền giúp thuyền giấy đứng vững trên nước.', img: 'https://www.origami-instructions.com/images/simple-boat/thumbnails/08-simple-origami-boat.jpg' }
  ],
  17: [ // Máy Bay Giấy
    { step: 1, text: 'Sử dụng một tờ giấy chữ nhật A4 phẳng phiu đặt theo chiều dọc.', tip: 'Để mặt màu hướng ra ngoài.', img: 'https://www.origami-instructions.com/images/simplest-airplane/thumbnails/rectangle-ready.jpg' },
    { step: 2, text: 'Gấp đôi tờ giấy theo chiều dọc để lấy nếp gấp sống giữa rồi mở ra.', tip: 'Nếp dọc giữa này là trục chính của máy bay.', img: 'https://www.origami-instructions.com/images/simplest-airplane/thumbnails/first-fold.jpg' },
    { step: 3, text: 'Gấp góc nhọn bên trái hướng chéo vào nếp gấp dọc trung tâm.', tip: 'Miết phẳng nếp gấp vai chéo.', img: 'https://www.origami-instructions.com/images/simplest-airplane/thumbnails/single-corner-fold.jpg' },
    { step: 4, text: 'Gấp góc nhọn bên phải tương tự vào sát nếp gấp dọc trung tâm.', tip: 'Mô hình tạo thành hình mũi nhọn cân đối.', img: 'https://www.origami-instructions.com/images/simplest-airplane/thumbnails/both-corners-folded.jpg' },
    { step: 5, text: 'Gập đôi toàn bộ máy bay dọc theo đường sống dọc ở trục giữa.', tip: 'Hai cánh máy bay úp vào nhau.', img: 'https://www.origami-instructions.com/images/simplest-airplane/thumbnails/main-fold.jpg' },
    { step: 6, text: 'Gấp cánh máy bay chéo xuống song song với sống lưng và lặp lại cho cánh kia.', tip: 'Cánh máy bay đối xứng hoàn hảo giúp máy bay lượn xa.', img: 'https://www.origami-instructions.com/images/simplest-airplane/thumbnails/first-wing.jpg' },
    { step: 7, text: 'Nâng cánh máy bay lên góc Y nhẹ. Bạn có thể dùng một chiếc kẹp giấy nhỏ cố định mũi máy bay để bay thẳng.', tip: 'Máy Bay Giấy Origami oai vệ đã sẵn sàng lướt gió!', img: 'https://www.origami-instructions.com/images/simplest-airplane/thumbnails/paper-clip.jpg' }
  ],
  18: [ // Xe Tải Giấy
    { step: 1, text: 'Chuẩn bị tờ giấy hình vuông, mặt màu úp xuống dưới.', tip: 'Dùng giấy xanh da trời hoặc đỏ tùy ý thích.', img: 'https://www.origami-instructions.com/images/truck/thumbnails/01-origami-truck.jpg' },
    { step: 2, text: 'Gấp đôi tờ giấy theo chiều dọc và chiều ngang để lấy nếp gấp dấu cộng.', tip: 'Mở phẳng tờ giấy ra sau khi lấy nếp.', img: 'https://www.origami-instructions.com/images/truck/thumbnails/03-origami-truck.jpg' },
    { step: 3, text: 'Gấp mép giấy phía dưới lên khoảng 2 cm để tạo gầm xe.', tip: 'Miết phẳng nếp gấp gầm xe.', img: 'https://www.origami-instructions.com/images/truck/thumbnails/05-origami-truck.jpg' },
    { step: 4, text: 'Gập chéo góc trên bên trái xuống dưới tạo kính chắn cabin và đầu xe tải.', tip: 'Tạo góc chéo cabin khoảng 45 độ.', img: 'https://www.origami-instructions.com/images/truck/thumbnails/07-origami-truck.jpg' },
    { step: 5, text: 'Gấp góc nhọn bên phải hướng chéo vào trong để làm thùng hàng xe tải vuông vắn.', tip: 'Gấp thẳng đứng vuông góc.', img: 'https://www.origami-instructions.com/images/truck/thumbnails/10-origami-truck.jpg' },
    { step: 6, text: 'Gập các góc nhọn nhỏ ở gầm xe chéo ngược ra sau để tạo vị trí lắp bánh xe.', tip: 'Gấp lút giấu góc nhọn vào phía trong.', img: 'https://www.origami-instructions.com/images/truck/thumbnails/12-origami-truck.jpg' },
    { step: 7, text: 'Vẽ thêm hai bánh xe tròn màu đen, cửa buồng lái cabin và kính xe. Xe Tải Origami đã hoàn tất!', tip: 'Bạn có thể tô màu trang trí thêm cho thùng hàng oai phong.', img: 'https://www.origami-instructions.com/images/truck/thumbnails/16-origami-truck.jpg' }
  ],
  19: [ // Chiếc Cốc Giấy
    { step: 1, text: 'Dùng giấy vuông. Gấp đôi chéo tạo hình tam giác lớn, đặt cạnh đáy tam giác nằm ở phía trên.', tip: 'Đỉnh tam giác nhọn hướng chéo xuống dưới.', img: 'https://www.origami-instructions.com/images/cowboy-hat/thumbnails/01a-cowboy-hat.jpg' },
    { step: 2, text: 'Gấp góc nhọn đáy bên trái chéo hướng sang chạm mép cạnh đối diện bên phải.', tip: 'Mép nếp gấp song song với cạnh đỉnh trên.', img: 'https://www.origami-instructions.com/images/cowboy-hat/thumbnails/02-cowboy-hat.jpg' },
    { step: 3, text: 'Gấp tương tự góc nhọn đáy bên phải chéo sang chạm mép cạnh đối diện bên trái.', tip: 'Hai mép gấp chéo chồng bắt chéo nhau đẹp mắt.', img: 'https://www.origami-instructions.com/images/cowboy-hat/thumbnails/03-cowboy-hat.jpg' },
    { step: 4, text: 'Gập một lớp góc nhọn ở đỉnh phía trên xuống phía dưới đè chèn qua mép.', tip: 'Đây là vành trước của chiếc cốc.', img: 'https://www.origami-instructions.com/images/cowboy-hat/thumbnails/04-cowboy-hat.jpg' },
    { step: 5, text: 'Lật ngược lại mặt sau và gập nốt lớp góc nhọn đỉnh còn lại xuống.', tip: 'Vành cốc mặt sau đã được khóa chặt phiu.', img: 'https://www.origami-instructions.com/images/cowboy-hat/thumbnails/05-cowboy-hat.jpg' },
    { step: 6, text: 'Dùng ngón tay luồn vào trong bóp nhẹ hai hông để chiếc cốc giấy phồng ra.', tip: 'Cốc có khoang đựng được hạt đậu nhỏ.', img: 'https://www.origami-instructions.com/images/cup/thumbnails/07-origami-cup.jpg' },
    { step: 7, text: 'Cốc giấy Origami của bạn đã sẵn sàng đứng vững chắc trên bàn!', tip: 'Nên dùng giấy xi màu chống thấm nếu muốn đựng đồ ẩm.', img: 'https://www.origami-instructions.com/images/cup/thumbnails/08-origami-cup.jpg' }
  ],
  20: [ // Ngôi Sao May Mắn
    { step: 1, text: 'Chuẩn bị một dải giấy màu kích thước dài mảnh khoảng 1.5x30 cm.', tip: 'Dải giấy phẳng phiu giúp ngôi sao cân đối.', img: 'https://www.origami-instructions.com/images/lucky-star/thumbnails/01-origami-lucky-star.jpg' },
    { step: 2, text: 'Uốn đầu dải giấy chéo chèn qua nhau tạo thành một lỗ thắt nút đơn giản.', tip: 'Tạo vòng thắt nút lỏng trước khi thắt chặt.', img: 'https://www.origami-instructions.com/images/lucky-star/thumbnails/02-origami-lucky-star.jpg' },
    { step: 3, text: 'Rút nhẹ hai đầu dải giấy tạo thành hình ngũ giác phẳng đều, luồn đuôi giấy ngắn thừa giấu vào trong.', tip: 'Rút vừa tay, không bóp nẹp làm dẹt hình ngũ giác.', img: 'https://www.origami-instructions.com/images/lucky-star/thumbnails/03-origami-lucky-star.jpg' },
    { step: 4, text: 'Quấn dải giấy dài chạy dọc theo các cạnh của hình ngũ giác đều đặn.', tip: 'Giấy sẽ tự động chạy dọc theo góc cạnh ngũ giác.', img: 'https://www.origami-instructions.com/images/lucky-star/thumbnails/07-origami-lucky-star.jpg' },
    { step: 5, text: 'Tiếp tục quấn cho tới khi dải giấy còn thừa đoạn ngắn khoảng 2 cm, luồn đầu thừa vào khe nếp gấp để khóa lại.', tip: 'Dùng ngón tay ấn chặt chốt khóa.', img: 'https://www.origami-instructions.com/images/lucky-star/thumbnails/11-origami-lucky-star.jpg' },
    { step: 6, text: 'Dùng hai ngón tay cái và trỏ bóp mạnh vào giữa mỗi cạnh ngũ giác để tạo độ phồng ngôi sao.', tip: 'Bóp lần lượt cả 5 cạnh để góc phồng tròn đều.', img: 'https://www.origami-instructions.com/images/lucky-star/thumbnails/15-origami-lucky-star.jpg' },
    { step: 7, text: 'Ngôi Sao May Mắn Origami của bạn đã hoàn thành thật căng phồng dễ thương!', tip: 'Gấp thật nhiều ngôi sao ước nguyện bỏ lọ thủy tinh trang trí phòng cực đẹp.', img: 'https://www.origami-instructions.com/images/lucky-star/thumbnails/20-origami-lucky-star.jpg' }
  ]
};

module.exports = stepsData;
