# Wireframe Our Budget

1. Mở tệp [Our Budget](https://www.figma.com/design/PYUVQbAKdYyTAcvQGcxzfg/Our-Budget?node-id=2-45) bằng Figma Desktop với quyền chỉnh sửa.
2. Nếu **Our Budget · Wireframes** chưa có trong **Plugins → Development**, chọn **Import plugin from manifest…** và mở `manifest.json` trong thư mục này. Nếu plugin đã có, kể cả khi Figma hiện `undefined` lúc thử import lại, chuyển thẳng sang bước 3. Sau khi sửa `code.js`, chạy lại plugin từ cùng menu.
3. Trong **Plugins → Development → Our Budget · Wireframes**, chọn **Giao diện chi tiết** để tạo trang **Giao diện chi tiết · Our Budget** hoặc **Wireframe 36 khung** để mở bộ wireframe. Nếu Figma vẫn hiển thị plugin dưới dạng một lệnh, chạy lệnh đó để mở giao diện chi tiết. Chạy lại sẽ mở trang tương ứng đã tạo.
4. Mở **Present** và chọn **Ghi chép hằng ngày**. Bộ wireframe 36 khung còn có luồng **Tài khoản và đăng nhập**.

Trang giao diện chi tiết có bảy màn hình chính. Các nút mở biểu mẫu, bộ lọc và xác nhận được thể hiện như điểm bắt đầu thao tác. Xem [user flow UC1–UC24](../../docs/user-flow-our-budget.md) để theo dõi từng bước.

Bộ wireframe có 36 khung 390 × 844 px và sử dụng các instance, biến màu và kiểu chữ Inter từ tệp Our Budget. Luồng ghi chép gồm các mẫu nhập chi, nhập thu, đổi nguồn tiền, mở trường tùy chọn và lỗi nhập liệu. Trang Ngân sách dùng ba ví dụ 60%, 85% và 102%. Các mẫu còn lại bao phủ lịch sử, bộ lọc, báo cáo, tài khoản, nguồn tiền và danh mục.

Các giao dịch và số dư là dữ liệu mẫu. Prototype mô phỏng chuyển màn hình và các trạng thái biểu mẫu.

Kiểm tra ở tỷ lệ 100% trong Figma. Mở **Đăng ký** để kiểm tra nhãn, ô nhập và dòng báo lỗi. Mở **Lọc giao dịch** và **Xóa giao dịch** để kiểm tra tiêu đề, nội dung và nút thao tác nằm trong khung. Trong **Báo cáo thống kê**, kiểm tra hai biểu đồ nằm trong thẻ riêng và các nhóm cột có chung đường đáy.
