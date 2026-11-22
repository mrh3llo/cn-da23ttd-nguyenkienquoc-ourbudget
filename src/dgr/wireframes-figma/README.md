# Wireframe Our Budget

1. Mở tệp [Our Budget](https://www.figma.com/design/PYUVQbAKdYyTAcvQGcxzfg/Our-Budget?node-id=2-45) bằng Figma Desktop với quyền chỉnh sửa.
2. Nếu **Our Budget · Wireframes** chưa có trong **Plugins → Development**, chọn **Import plugin from manifest…** và mở `manifest.json` trong thư mục này. Nếu plugin đã có, kể cả khi Figma hiện `undefined` lúc thử import lại, chuyển thẳng sang bước 3. Sau khi sửa `code.js`, chạy lại plugin từ cùng menu.
3. Trong **Plugins → Development → Our Budget · Wireframes**, chọn **Giao diện chi tiết** hoặc **Wireframe 36 khung**. Mỗi lệnh xuất một trang có hậu tố **· Xác thực** để giữ bản cũ cho việc đối chiếu. Chạy lại cùng lệnh sẽ mở trang tương ứng đã tạo.
4. Mở **Present** và chọn **Tài khoản và đăng nhập**. Dùng cụm nút **Đăng nhập / Đăng ký** để chuyển chế độ. Nút Google dưới biểu mẫu mô phỏng xác thực thành công bằng cách mở **Trang chủ**. Cả hai trang đều có luồng **Ghi chép hằng ngày**.

Trang giao diện chi tiết có chín màn hình, gồm bảy màn hình chức năng và hai màn hình tài khoản. Luồng khôi phục mật khẩu có trong bộ wireframe. Xem [user flow UC1–UC24](../../docs/user-flow-our-budget.md) để theo dõi từng bước.

[Logo chữ Our Budget dạng SVG](our-budget-wordmark.svg) có nền trong suốt và chữ đã chuyển thành đường vector. Cả hai bộ đặt logo phía trên tiêu đề **Đăng nhập** và **Đăng ký**. Nút Google dùng biểu tượng G từ [bộ nhận diện của Google](https://developers.google.com/identity/branding-guidelines).

Bộ wireframe có 36 khung 390 × 844 px và sử dụng các instance, biến màu và kiểu chữ Inter từ tệp Our Budget. Luồng ghi chép gồm các mẫu nhập chi, nhập thu, đổi nguồn tiền, mở trường tùy chọn và lỗi nhập liệu. Trang Ngân sách dùng ba ví dụ 60%, 85% và 102%. Các mẫu còn lại bao phủ lịch sử, bộ lọc, báo cáo, tài khoản, nguồn tiền và danh mục.

Các giao dịch và số dư là dữ liệu mẫu. Prototype mô phỏng chuyển màn hình và các trạng thái biểu mẫu.

Kiểm tra ở tỷ lệ 100% trong Figma. Mở **Đăng nhập** và **Đăng ký** để kiểm tra nhãn, ô nhập và nút chuyển màn hình. Mở **Lọc giao dịch** và **Xóa giao dịch** trong bộ wireframe để kiểm tra tiêu đề, nội dung và nút thao tác nằm trong khung. Trong **Báo cáo thống kê**, kiểm tra hai biểu đồ nằm trong thẻ riêng và các nhóm cột có chung đường đáy.
