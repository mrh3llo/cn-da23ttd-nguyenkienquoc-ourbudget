# Wireframe Our Budget

## Bản duyệt Cá nhân và thanh điều hướng

Chạy lại lệnh **Cá nhân và thanh điều hướng · Bản duyệt** để cập nhật nút **Đăng xuất** trên trang hiện có. Nút dùng biến màu `expense` cho nền và `surface` cho chữ.

1. Mở [Our Budget](https://www.figma.com/design/PYUVQbAKdYyTAcvQGcxzfg/Our-Budget?node-id=2-45) trong Figma Desktop bằng tài khoản có quyền chỉnh sửa.
2. Vào **Plugins → Development → Import plugin from manifest…** và chọn [manifest.json](manifest.json). Nếu đã import phiên bản cũ và menu chưa hiện lệnh mới, import lại manifest từ thư mục hiện tại.
3. Vào **Plugins → Development → Our Budget · Wireframes** và chọn **Cá nhân và thanh điều hướng · Bản duyệt**. Nếu trang **Our Budget · Cá nhân · Bản duyệt** đã có, plugin tìm bốn biến thể hiện có và xóa nhãn dưới nút **+** ngay trên component set. Nếu trang chưa có, plugin tạo trang với nút **+** chỉ hiện biểu tượng.
4. Mở **Present** và chọn **Duyệt Cá nhân và thanh điều hướng**. Thử mở **Thông tin tài khoản**, **Quản lý ví** và **Danh mục** từ menu. Thử bốn tab, nút **Thêm giao dịch**, nút quay lại và **Đăng xuất**. Thao tác chọn ảnh và lưu thông tin là mô phỏng.

Trang duyệt chứa hai màn hình hồ sơ có thể chỉnh sửa, các khung đích của prototype và component set **Bottom Navigation Bar / 5 mục**. Bốn biến thể dùng các instance điều hướng gốc và giữ vị trí, biểu tượng cùng hiệu ứng của nút nổi. Trung tâm chỉ hiện biểu tượng **+** và mở sheet **Giao dịch mới** từ Component Library. Trợ giúp, giới thiệu, thông báo và cài đặt có khung tham chiếu để thử liên kết.

Khung **Kiểm kê và ghi chú duyệt** trên cùng trang liệt kê màu và kiểu chữ lấy từ Figma khi chạy plugin, token khoảng cách và bo góc, kiểu hiệu ứng cùng các component được tìm thấy. Khi thiếu component có thể dùng, plugin dùng token cục bộ để dựng phần cần thiết và ghi tên vào khung kiểm kê. Các icon vector dự phòng cần được đối chiếu với thư viện icon của dự án khi duyệt. Nội dung trang cũ và asset gốc giữ nguyên.

Ở chế độ Present, kiểm tra nút **+** nằm chính giữa và không có chữ bên dưới, vùng an toàn ở đáy, bốn trạng thái tab, cuộn khi nội dung dài và đường dẫn từ **Cá nhân** đến **Thông tin tài khoản**. So sánh với mockup đã duyệt trước khi chuyển sang Flutter.

## Các lệnh tạo wireframe hiện có

1. Mở tệp [Our Budget](https://www.figma.com/design/PYUVQbAKdYyTAcvQGcxzfg/Our-Budget?node-id=2-45) bằng Figma Desktop với quyền chỉnh sửa.
2. Nếu **Our Budget · Wireframes** chưa có trong **Plugins → Development**, chọn **Import plugin from manifest…** và mở `manifest.json` trong thư mục này. Nếu plugin đã có, kể cả khi Figma hiện `undefined` lúc thử import lại, chuyển thẳng sang bước 3. Sau khi sửa `code.js`, chạy lại plugin từ cùng menu.
3. Trong **Plugins → Development → Our Budget · Wireframes**, chọn **Giao diện chi tiết** hoặc **Wireframe 36 khung**. Mỗi lệnh xuất một trang có hậu tố **· Xác thực** để giữ bản cũ cho việc đối chiếu. Chạy lại cùng lệnh sẽ mở trang tương ứng đã tạo.
4. Mở **Present** và chọn **Tài khoản và đăng nhập**. Dùng cụm nút **Đăng nhập / Đăng ký** để chuyển chế độ. Nút Google dưới biểu mẫu mô phỏng xác thực thành công bằng cách mở **Trang chủ**. Cả hai trang đều có luồng **Ghi chép hằng ngày**.

Trang giao diện chi tiết có chín màn hình, gồm bảy màn hình chức năng và hai màn hình tài khoản. Luồng khôi phục mật khẩu có trong bộ wireframe. Xem [user flow UC1–UC24](../../docs/user-flow-our-budget.md) để theo dõi từng bước.

[Logo chữ Our Budget dạng SVG](our-budget-wordmark.svg) có nền trong suốt và chữ đã chuyển thành đường vector. Cả hai bộ đặt logo phía trên tiêu đề **Đăng nhập** và **Đăng ký**. Nút Google dùng biểu tượng G từ [bộ nhận diện của Google](https://developers.google.com/identity/branding-guidelines).

Bộ wireframe có 36 khung 390 × 844 px và sử dụng các instance, biến màu và kiểu chữ Inter từ tệp Our Budget. Luồng ghi chép gồm các mẫu nhập chi, nhập thu, đổi nguồn tiền, mở trường tùy chọn và lỗi nhập liệu. Trang Ngân sách dùng ba ví dụ 60%, 85% và 102%. Các mẫu còn lại bao phủ lịch sử, bộ lọc, báo cáo, tài khoản, nguồn tiền và danh mục.

Các giao dịch và số dư là dữ liệu mẫu. Prototype mô phỏng chuyển màn hình và các trạng thái biểu mẫu.

Kiểm tra ở tỷ lệ 100% trong Figma. Mở **Đăng nhập** và **Đăng ký** để kiểm tra nhãn, ô nhập và nút chuyển màn hình. Mở **Lọc giao dịch** và **Xóa giao dịch** trong bộ wireframe để kiểm tra tiêu đề, nội dung và nút thao tác nằm trong khung. Trong **Báo cáo thống kê**, kiểm tra hai biểu đồ nằm trong thẻ riêng và các nhóm cột có chung đường đáy.
