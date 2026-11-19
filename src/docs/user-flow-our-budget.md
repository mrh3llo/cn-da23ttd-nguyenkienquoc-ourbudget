# Our Budget — Giao diện chính và user flow

Bản thiết kế để duyệt trước khi lập trình. Đối chiếu với [đặc tả UC1–UC24](use-case-diagram.md), [đề xuất kiến trúc](system-architecture.md), [wireframe và hướng dẫn xuất Figma](../dgr/wireframes-figma/README.md).

## Giao diện chính

Bảy khung Android 390 × 844 dùng Inter, các biến màu và component của hệ thống thiết kế Our Budget. Thanh điều hướng giữ bốn tab **Trang chủ**, **Lịch sử**, **Ngân sách**, **Cá nhân** và nút **+** ghi giao dịch nhanh. Mỗi khung thể hiện nội dung chính và điểm bắt đầu thao tác. Biểu mẫu, hộp xác nhận, thông báo và nhánh lỗi được đặc tả ở các bảng bên dưới.

| Màn hình | Nội dung | Điều hướng và thao tác |
| --- | --- | --- |
| Trang chủ | Tổng số dư khả dụng, tiến độ ngân sách tháng, ba giao dịch gần đây | Nút **+** mở UC15. Thẻ ngân sách mở **Ngân sách**. **Xem tất cả** mở **Lịch sử**. |
| Lịch sử | Giao dịch theo ngày, số tiền có dấu, ví và mốc giờ. Chip cho kỳ, ví và danh mục. | Tìm và lọc theo UC17. Chọn giao dịch để sửa hoặc xóa theo UC18–UC19. |
| Ngân sách | Kỳ hiện tại, hạn mức, số đã chi, tỷ lệ và nhãn trạng thái | Thêm ngân sách, chọn đúng ngân sách để quản lý, mở **Báo cáo thống kê**. |
| Báo cáo thống kê | Kỳ, phạm vi ví, tổng thu/chi, cơ cấu chi và xu hướng theo tuần | Đổi kỳ hoặc ví để tải lại các số liệu cùng phạm vi. Quay lại màn hình đã mở báo cáo. |
| Cá nhân | Tên, email, các mục quản lý tài khoản | Chỉnh sửa hồ sơ, mở **Nguồn tiền**, **Danh mục**, **Báo cáo thống kê**, hoặc đăng xuất. |
| Nguồn tiền | Tổng số dư, số dư từng ví, ví mặc định | Thêm ví, mở ví đã chọn để sửa/xóa, chuyển tiền nội bộ. |
| Danh mục | Hai nhóm **Chi tiêu** và **Thu nhập** trên cùng khung | Thêm danh mục, chọn danh mục theo loại để sửa hoặc xóa. |

## Tài khoản

| UC | Luồng thành công | Nhánh và tiêu chí nghiệm thu |
| --- | --- | --- |
| UC1 · Đăng ký | Đăng nhập → Tạo tài khoản → nhập thông tin → xác nhận → vào Trang chủ khi đã có phiên hợp lệ. | Email trùng hoặc dữ liệu sai giữ người dùng ở bước đăng ký. Nếu API yêu cầu xác thực email, chỉ mở Trang chủ sau khi hoàn tất. |
| UC2 · Đăng nhập | Mở ứng dụng → nhập thông tin → máy chủ xác thực → lưu phiên → Trang chủ. | Sai thông tin thì ở lại bước đăng nhập. Phiên hết hạn chuyển về cổng đăng nhập, không hiển thị dữ liệu của phiên cũ. |
| UC3 · Quên mật khẩu | Đăng nhập → Quên mật khẩu → gửi yêu cầu qua email → xác minh OTP → đặt mật khẩu mới → quay về Đăng nhập. | OTP sai, hết hạn hoặc đã dùng phải bị từ chối. Cho gửi lại có giới hạn. Phản hồi yêu cầu gửi mã không tiết lộ email có tồn tại. |
| UC4 · Đăng xuất | Cá nhân → Đăng xuất → kết thúc phiên → Đăng nhập. | Xóa phiên và dữ liệu tài khoản trên thiết bị, không cho nút Back mở lại màn hình được bảo vệ. |
| UC5 · Cập nhật hồ sơ | Cá nhân → Thông tin cá nhân → đổi tên, ảnh hoặc mật khẩu → lưu → Cá nhân. | Giữ dữ liệu nhập nếu lưu lỗi. Đổi mật khẩu cần xác minh mật khẩu hiện tại. Chỉ hiện hồ sơ mới sau khi máy chủ xác nhận. |

## Nguồn tiền

| UC | Luồng thành công | Nhánh và tiêu chí nghiệm thu |
| --- | --- | --- |
| UC6 · Thêm nguồn tiền | Cá nhân → Nguồn tiền → Thêm nguồn tiền → nhập tên, loại và số dư ban đầu → lưu → danh sách có ví mới. | Nếu dữ liệu sai thì giữ biểu mẫu. Nếu chưa có ví để ghi thu/chi, dẫn người dùng tới luồng này. |
| UC7 · Xem nguồn tiền | Cá nhân → Nguồn tiền → xem số dư từng ví và tổng số dư. | Phân biệt trạng thái chưa có ví với lỗi tải. Dữ liệu chỉ thuộc người dùng đang đăng nhập. |
| UC8 · Sửa nguồn tiền | Nguồn tiền → chọn ví → sửa tên, biểu tượng hoặc số dư ban đầu → lưu → cập nhật ví và tổng số dư. | Lưu theo mã ví đã chọn. Khi đổi số dư ban đầu, bảo toàn các biến động đã ghi và cập nhật số dư theo quy tắc đã duyệt. |
| UC9 · Xóa nguồn tiền | Nguồn tiền → chọn ví → Xóa → xem ảnh hưởng → xác nhận → tải lại danh sách. | Hủy thì quay lại ví. Nếu còn giao dịch, xử lý theo chính sách lưu trữ/xóa được duyệt và giữ lịch sử nhất quán. |
| UC10 · Chuyển tiền | Nguồn tiền → Chuyển tiền nội bộ → chọn hai ví và số tiền → xác nhận → cập nhật số dư hai ví. | Hai ví phải khác nhau và thuộc người dùng. Số tiền phải dương. Giao tác cập nhật cả hai phía hoặc hoàn tác cả hai. Tổng thu/chi loại trừ khoản chuyển nội bộ. |

## Danh mục thu/chi

| UC | Luồng thành công | Nhánh và tiêu chí nghiệm thu |
| --- | --- | --- |
| UC11 · Thêm danh mục | Cá nhân → Danh mục → Thêm danh mục → chọn thu/chi, tên, biểu tượng, màu → lưu → hiện trong nhóm tương ứng. | Dữ liệu không hợp lệ giữ biểu mẫu. Danh mục mới chọn được trong UC15 khi loại giao dịch khớp. |
| UC12 · Xem danh mục | Cá nhân → Danh mục → xem nhóm Chi tiêu và Thu nhập. | Nếu nhóm trống, vẫn có điểm vào thao tác thêm. |
| UC13 · Sửa danh mục | Danh mục → chọn mục → sửa tên hoặc biểu tượng → lưu → cập nhật danh sách và nhãn hiển thị liên quan. | Giữ mã danh mục và kiểm tra quyền sở hữu. |
| UC14 · Xóa danh mục | Danh mục → chọn mục → Xóa → xác nhận → cập nhật nhóm tương ứng. | Hủy thì giữ nguyên. Nếu có giao dịch hoặc ngân sách liên quan, áp dụng chính sách dữ liệu được duyệt trước khi xóa. |

## Giao dịch

| UC | Luồng thành công | Nhánh và tiêu chí nghiệm thu |
| --- | --- | --- |
| UC15 · Ghi thu/chi | Nút **+** → chọn Thu nhập hoặc Chi tiêu → nhập số tiền, danh mục, ví → thêm ghi chú hoặc ngày giờ nếu cần → Lưu → quay lại màn hình nguồn. | Số tiền phải dương ở biểu mẫu, máy chủ xử lý dấu theo loại. Giữ dữ liệu nếu ghi lỗi. Sau khi máy chủ xác nhận, làm mới số dư, lịch sử và kiểm tra ngân sách đối với khoản chi. |
| UC16 · Xem lịch sử | Tab Lịch sử hoặc Trang chủ → Xem tất cả → xem giao dịch nhóm theo ngày phát sinh. | Hiển thị rõ thu/chi bằng dấu và màu. Trạng thái không có giao dịch khác trạng thái tải lỗi. |
| UC17 · Tìm và lọc | Lịch sử → nhập từ khóa hoặc chọn thời gian, ví, danh mục → áp dụng → xem kết quả và bộ lọc đang dùng. | Xóa bộ lọc trả về danh sách mặc định. Bộ lọc đang áp dụng được giữ khi quay lại từ thao tác sửa/xóa. |
| UC18 · Sửa giao dịch | Lịch sử → chọn giao dịch → sửa → lưu → trở về danh sách với dữ liệu mới. | Máy chủ hoàn tác ảnh hưởng cũ rồi áp dụng ảnh hưởng mới trong cùng giao tác. Nếu đổi ngày, ví hoặc danh mục, làm mới cả nguồn và đích bị ảnh hưởng. |
| UC19 · Xóa giao dịch | Lịch sử → chọn giao dịch → Xóa → xác nhận → quay lại danh sách. | Hủy giữ giao dịch và số dư. Khi thành công, đảo ảnh hưởng của giao dịch đã xóa và làm mới báo cáo/ngân sách liên quan. |

## Ngân sách và báo cáo

| UC | Luồng thành công | Nhánh và tiêu chí nghiệm thu |
| --- | --- | --- |
| UC20 · Thiết lập ngân sách | Ngân sách → Thêm ngân sách → chọn phạm vi danh mục hoặc tổng chi, kỳ tuần/tháng, hạn mức → lưu → hiện tiến độ kỳ. | Hạn mức dương, kỳ hợp lệ. Khi trùng phạm vi và kỳ, đưa người dùng tới quyết định giữ hoặc cập nhật ngân sách đang có. |
| UC21 · Quản lý ngân sách | Ngân sách → chọn đúng thẻ ngân sách → sửa hoặc xóa → lưu/xác nhận → tải lại danh sách. | Lấy dữ liệu theo mã của thẻ đã chọn. Bấm thẻ Di chuyển hoặc Mua sắm phải mở mục tương ứng. |
| UC22 · Xem báo cáo | Ngân sách hoặc Cá nhân → Báo cáo thống kê → chọn kỳ và ví → xem tổng thu/chi, cơ cấu và xu hướng. | Tổng và biểu đồ dùng cùng bộ lọc. Trạng thái kỳ chưa có dữ liệu hiển thị rõ. Loại khoản chuyển nội bộ khỏi tổng thu/chi. |
| UC23 · Cập nhật số dư | Lưu sửa/xóa/thêm giao dịch hoặc chuyển tiền → máy chủ cập nhật ví trong giao tác → ứng dụng nạp số dư đã xác nhận. | Ghi thất bại thì hoàn tác. Khi thử lại sau mất kết nối, chống ghi trùng theo hợp đồng API đã duyệt. |
| UC24 · Kiểm tra hạn mức | Khi dữ liệu chi thay đổi → tính tổng chi trong kỳ → so với hạn mức → cập nhật trạng thái ngân sách. | Dưới 80% là an toàn, từ 80% đến dưới 100% là cảnh báo, từ 100% là chạm/vượt hạn mức. Gắn nhãn văn bản bên cạnh màu. Nếu trạng thái tải lại lỗi sau khi đã lưu giao dịch, tiếp tục hiển thị giao dịch đã lưu. |

## Bàn giao triển khai

- Dùng [đề xuất kiến trúc](system-architecture.md) để đối chiếu nhóm tài nguyên API. Duyệt hợp đồng API, chính sách xóa có liên kết, phạm vi ngân sách và cách xử lý phiên trước khi lập trình.
- Khi kiểm thử giao diện, xác nhận đủ bảy khung Figma và thử các liên kết **Trang chủ → Lịch sử**, **Ngân sách → Báo cáo** và **Cá nhân → Nguồn tiền/Danh mục**. Dùng các bảng UC để kiểm thử thành công, hủy, dữ liệu sai, mất phiên và lỗi lưu trong ứng dụng.
