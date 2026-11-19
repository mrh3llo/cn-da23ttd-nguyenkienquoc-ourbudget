# BUG-001 — Figma báo `Our Budget . undefined`

- **Trạng thái** Đã sửa lỗi điều hướng về chính khung hiện tại trong mã nguồn, chờ chạy lại trên Figma Desktop.
- **Phạm vi** Plugin phát triển **Our Budget · Wireframes** trên Figma Desktop.
- **Ảnh hưởng** Chưa xác nhận plugin tạo được trang wireframe đầy đủ khi chạy lại.

## Tái hiện theo báo cáo của người dùng

1. Mở tệp **Our Budget** trong Figma Desktop và làm theo [hướng dẫn plugin](../dgr/wireframes-figma/README.md).
2. Sau khi sửa lỗi tên trường `arcData`, thử import lại `manifest.json`. Ở bước này, người dùng từng thấy thông báo `undefined`.
3. Chạy lại plugin đã đăng ký qua **Plugins → Development → Our Budget · Wireframes**. Khi tái hiện, kiểm tra thông báo xuất hiện lúc import, ngay sau khi chọn plugin hay khi plugin đang tạo trang. Báo cáo mới nhất xác nhận nội dung `Our Budget . undefined`, nhưng chưa xác nhận chính xác thời điểm phát sinh.

## Kết quả mong đợi

Plugin tạo trang **Wireframes · Our Budget** với 36 khung và hai luồng prototype. Nếu trang đã tồn tại, plugin mở trang đó và báo đã có. Khi gặp lỗi, thông báo hoặc bảng điều khiển cung cấp đủ chi tiết để tìm bước thất bại.

## Kết quả thực tế và bằng chứng

- Lỗi ban đầu nêu cụ thể `set_arcData` và hai khóa không hợp lệ. Tên khóa đã được sửa thành `startingAngle` và `endingAngle`. Kiểm tra cú pháp và mô phỏng ba lát donut bằng Node.js đã đạt.
- Đã xác nhận cấu hình cục bộ của Figma trỏ tới manifest trong thư mục dự án. Ảnh chụp lần chạy sau được phân tích bên dưới. Phiên bản Figma và stack trace chưa được ghi nhận.
- Bộ dựng trong [code.js](../dgr/wireframes-figma/code.js) hiện ghi tên bước và giá trị lỗi vào console. Thông báo trong Figma hiển thị tên bước và dẫn tới console nếu lỗi thiếu nội dung. Thay đổi này giúp xác định nguyên nhân khi chạy lại.
- Kiểm tra mô phỏng bằng Node.js xác nhận 36 khung, hai điểm bắt đầu prototype, các đích điều hướng được tạo, ba lát biểu đồ và việc dọn trang khi một thao tác liên kết trả lỗi không có nội dung. Kiểm tra trên canvas Figma còn chờ quyền truy cập. Figma MCP báo đã hết lượt gọi trên Starter và công cụ điều khiển Figma Desktop không kết nối được.

## Chẩn đoán lỗi liên kết prototype

- Ảnh chụp lần chạy mới xác nhận lỗi xảy ra ở bước `Liên kết Trang chủ → home`. Nút Trang chủ của màn hình `home` được gán đích là chính khung đó. Figma yêu cầu đích `NAVIGATE` là một khung cấp cao nhất khác trên cùng trang.
- Sửa tại bước đăng ký liên kết dùng chung. Plugin xác định khung chứa nút, kiểm tra nguồn và đích cùng thuộc trang và bỏ qua liên kết về chính khung đó. Các trạng thái khác dùng cùng nhãn, như **Lịch sử · Tiền mặt** về **Lịch sử**, vẫn có liên kết điều hướng.
- Mô phỏng theo quy tắc trên tái hiện được lỗi `Trang chủ → home` khi bỏ bản sửa. Sau bản sửa, mô phỏng kiểm tra được 151 liên kết hợp lệ, 36 khung, hai luồng, mở lại trang đã có khi chạy lần hai và dọn trang tạo dở khi một liên kết thực sự thất bại. Cần xác nhận lại với các component thật trong Figma.

## Kiểm thử lại khi xử lý

1. Dùng một bản sao thử nghiệm có đủ Component Library. Ghi lại phiên bản Figma Desktop, thao tác vừa thực hiện và nội dung trong **Plugins → Development → Show/Hide console**.
2. Chạy plugin từ mục Development. Xác nhận trang có 36 khung, biểu đồ donut có ba lát và cả hai luồng mở được trong **Present**. Từ Trang chủ, bấm tab đang mở rồi chuyển qua Lịch sử và bấm Trang chủ để quay lại.
3. Chạy lần nữa và xác nhận plugin mở trang đã có, không tạo trang trùng. Nếu làm phát sinh lỗi có kiểm soát khi đang tạo trang, xác nhận console ghi được chi tiết lỗi và trang tạo dở được dọn dẹp.
