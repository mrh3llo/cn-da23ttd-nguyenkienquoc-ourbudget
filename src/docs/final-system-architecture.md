# Kiến trúc hệ thống OurBudget
Cập nhật triển khai 22/11/2026: ứng dụng hiện dùng Supabase PostgreSQL qua API PHP. Các mô tả MySQL phía dưới phản ánh báo cáo hoặc phương án ban đầu; xem [ghi chú chuyển đổi](supabase-migration.md) và [hướng dẫn Supabase](../../supabase/SUPABASE.md).

**Cập nhật 22/11/2026:** chỉ dùng bảng và thuộc tính trong Word, trừ ngoại lệ đã duyệt tại [chuyển CSDL sang Supabase PostgreSQL](../../supabase/SUPABASE.md). các migration PostgreSQL trong supabase/migrations là nguồn schema triển khai; chưa áp dụng CSDL cá nhân.

Bản chốt thiết kế cho OurBudget trên Android. Phiên bản đầu bao phủ UC1–UC24, gồm tài khoản, nguồn tiền nhập thủ công, danh mục thu/chi, giao dịch, ngân sách và báo cáo. Ảnh hóa đơn thuộc hướng phát triển sau phiên bản đầu. Ví điện tử và tài khoản ngân hàng được theo dõi như nguồn tiền nhập thủ công, độc lập với hệ thống của tổ chức cung cấp dịch vụ.

## Đối chiếu với báo cáo đề tài

Kiến trúc đề xuất tương thích với nền tảng công nghệ và phạm vi nghiệp vụ chính trong bản Word. Các khác biệt nằm ở hợp đồng API, quy ước dữ liệu và mức chi tiết của đặc tả. Bảng dưới đây ghi rõ phần báo cáo đã có và các điểm cần đồng bộ theo bản chốt. [Bản Word](../../thesis/doc/2.%20Báo%20cáo%20đề%20tài.docx) · [Bản đề xuất](system-architecture.md) · [Đặc tả use-case](use-case-diagram.md)

| Nội dung | Đối chiếu với bản Word | Nội dung cần đồng bộ |
| --- | --- | --- |
| Nền tảng và phân tầng | §1.3.2, §2.4 và §3.1.3 thống nhất Flutter/Dart, PHP RESTful API và MySQL. §3.2.2 đã mô tả Provider và giao tác ghi nhận thu/chi. | Bổ sung trách nhiệm từng tầng và các ranh giới giao tác vào §3.5. |
| Hợp đồng HTTP | §3.2.1, §3.2.2 và Hình 3.2 vẫn minh họa đường dẫn cũ hoặc mã thành công `200` cho thao tác tạo giao dịch. | Dùng `POST /api/v1/transactions` và `201 Created` trong văn bản và Hình 3.2. |
| Tiền và thời gian | §3.3.2 dùng `BIGINT` cho số tiền giao dịch và số dư ví, còn hạn mức dùng `DECIMAL`. Báo cáo đã chọn múi giờ Việt Nam. Bản đề xuất ban đầu dùng `DECIMAL` và chuỗi thập phân. | Dùng `BIGINT` theo đơn vị đồng cho mọi giá trị tiền tệ, truyền bằng chuỗi số nguyên và thống nhất biên kỳ theo `Asia/Ho_Chi_Minh`. |
| Danh mục, ví và chuyển nội bộ | §3.3 đã tách `income_categories` và `outcome_categories`, thêm ví đích và độ ưu tiên của ví. Từ điển dữ liệu vẫn có `expensecate_id`, trong khi quan hệ sở hữu danh mục chưa được thể hiện. | Đồng bộ khóa danh mục và quyền sở hữu ở §3.3, cách chọn ví mặc định ở §3.3–3.4 và quy tắc ghi nhận chuyển nội bộ ở §3.2–3.3. |
| Ngân sách và báo cáo | §3.1.2 và giao diện Trang chủ có ngân sách tổng. §3.2.1–3.2.2 mô tả chủ yếu ngân sách theo danh mục và đã có công thức, ngưỡng cảnh báo. | Bổ sung phạm vi ngân sách tổng ở §3.2–3.3, đồng bộ nguồn dữ liệu và quy tắc loại trừ chuyển nội bộ. |
| Mô hình vật lý và xác thực | §3.3.2 mô tả MySQL, nhưng Hình 3.5 và tệp PDM còn theo SAP SQL Anywhere 17. Thuộc tính phiên và khôi phục chưa được mô tả đầy đủ. | Giữ 7 thực thể, bổ sung thuộc tính trong users; chuyển đích PDM sang MySQL InnoDB và cập nhật từ điển dữ liệu. |
| Phạm vi ảnh hóa đơn | §3.1.1 nhắc ảnh hóa đơn trong phần định hướng. Phạm vi UC1–UC24 và mô hình dữ liệu chưa có nghiệp vụ tương ứng. | Ghi rõ ảnh hóa đơn là hướng phát triển sau phiên bản đầu tại §3.1.1. |

## Thành phần và trách nhiệm

| Thành phần | Trách nhiệm |
| --- | --- |
| Ứng dụng Flutter/Dart | Phát triển bằng Android Studio, chạy trên Android. Giao diện kiểm tra biểu mẫu, gửi yêu cầu HTTPS/JSON và dùng Provider để cập nhật trạng thái hiển thị từ dữ liệu máy chủ. |
| RESTful API PHP | Triển khai một ứng dụng máy chủ, tổ chức theo phân hệ. Bộ định tuyến và controller xử lý HTTP/JSON, lớp xác thực xác định tài khoản, lớp dịch vụ kiểm tra nghiệp vụ và quản lý giao tác, lớp truy cập dữ liệu dùng PDO với câu lệnh tham số hóa. |
| MySQL InnoDB | Nguồn dữ liệu chính, dùng `utf8mb4`, khóa ngoại và chỉ mục cho lịch sử giao dịch, ngân sách và báo cáo. Kết nối cơ sở dữ liệu thuộc về API PHP. |
| Google Identity (đề xuất) | Xác minh danh tính Google để backend liên kết tài khoản và cấp phiên OurBudget. |
| Worker email | Đọc queue tệp riêng sau commit, khóa tệp khi gửi và retry tối đa năm lần. |

## Phân hệ và hợp đồng API

| Phân hệ | Use-case | Tài nguyên API |
| --- | --- | --- |
| Tài khoản | UC1–UC5 | `/api/v1/auth/…`, `/api/v1/me` |
| Nguồn tiền | UC6–UC10 | `/api/v1/wallets`, `/api/v1/transfers` |
| Danh mục thu/chi | UC11–UC14 | `/api/v1/categories`. Tham số loại phân biệt danh mục thu và chi. |
| Giao dịch | UC15–UC19 | `/api/v1/transactions`. UC17 lọc và tìm kiếm trên danh sách giao dịch. |
| Ngân sách và báo cáo | UC20–UC22 | `/api/v1/budgets`, `/api/v1/reports`. |

UC23 cập nhật số dư và UC24 kiểm tra hạn mức được thực hiện bên trong API. Thao tác tạo khoản thu hoặc chi dùng `POST /api/v1/transactions`, còn tạo chuyển tiền nội bộ dùng `POST /api/v1/transfers`. Tạo thành công trả `201 Created`, kèm bản ghi và số dư các ví đã cập nhật. API dùng `401` cho phiên thiếu, hết hạn hoặc không hợp lệ, `404` cho tài nguyên không tồn tại hoặc ngoài phạm vi truy cập, `409` cho xung đột nghiệp vụ và `422` cho dữ liệu đầu vào không hợp lệ. Lỗi máy chủ ngoài dự kiến trả `500`. Hợp đồng API chi tiết sẽ quy định trường dữ liệu, bộ lọc, phân trang và cấu trúc phản hồi.

## Mô hình dữ liệu và quy tắc nghiệp vụ

**Tiền tệ.** Lưu số tiền giao dịch, số dư đầu kỳ, số dư hiện tại và hạn mức bằng `BIGINT` có dấu, theo đơn vị đồng Việt Nam. API biểu diễn tiền dưới dạng chuỗi số nguyên, ví dụ `"25000"` hoặc `"-25000"`. Các phép tính số dư và tổng hợp tiền dùng số nguyên chính xác. Khoản thu mang dấu dương, khoản chi mang dấu âm và hạn mức phải lớn hơn 0.

**Danh mục.** Giữ hai bảng `income_categories` và `outcome_categories` theo bản Word. Mỗi bảng có khóa ngoại `users_id` cho danh mục do người dùng tạo. Giá trị `NULL` dành cho danh mục hệ thống dùng chung và chỉ đọc đối với tài khoản thông thường. API cung cấp một tài nguyên danh mục chung và xác định bảng theo loại danh mục. Khoản thu tham chiếu đúng một `income_id`, khoản chi tham chiếu đúng một `outcome_id`, còn chuyển nội bộ để trống cả hai. Các tham chiếu này thay cho `expensecate_id` cũ.

**Ví và chuyển tiền.** Duy trì `wallets_opening_balance` và `wallets_current_balance`. Ví mới có số dư hiện tại bằng số dư đầu kỳ. Khi thay đổi số dư đầu kỳ theo UC8, cập nhật số dư hiện tại theo phần chênh lệch trong cùng giao tác. `wallets_priority` là thứ tự không âm: ví mặc định đang hoạt động có giá trị 0, tiếp theo là 1, 2, … Chọn theo `wallets_priority ASC, wallets_id ASC`; ID là tiêu chí phụ khi dữ liệu cũ còn trùng. Thêm/đổi thứ tự/ngừng hoạt động ví phải chuẩn hóa thứ tự nhóm ví hoạt động trong cùng giao tác theo tài khoản. Khi không có ví hoạt động, người dùng cần tạo hoặc kích hoạt một ví trước khi ghi giao dịch.

Lưu chuyển nội bộ thành một bản ghi `transactions` có loại `TRANSFER`, ví nguồn tại `wallets_id`, ví đích tại `destination_wallet_id` và số tiền dương. Hai trường ví là khóa ngoại, phải trỏ đến hai ví khác nhau thuộc cùng tài khoản. Dùng trường loại giao dịch để phân biệt `INCOME`, `EXPENSE` và `TRANSFER`. Lịch sử có thể hiển thị chuyển nội bộ với loại riêng. Tổng thu, tổng chi và tổng dùng cho ngân sách chỉ lấy các loại thu hoặc chi tương ứng.

**Lưu trữ lịch sử.** Khi ví hoặc danh mục tùy chỉnh đã có bản ghi liên quan, thao tác xóa chuyển tài nguyên sang trạng thái ngừng hoạt động. Tài nguyên này vẫn hiển thị trong lịch sử và được loại khỏi danh sách lựa chọn cho giao dịch mới. Các khóa ngoại tương ứng dùng `ON DELETE RESTRICT` để bảo toàn dữ liệu tham chiếu.

**Ngân sách và thời gian.** Mỗi bản ghi `budgets` thuộc một tài khoản. Khóa ngoại `outcome_id` xác định ngân sách theo danh mục chi, còn `NULL` biểu thị ngân sách tổng. Khóa ngoại và phạm vi truy cập phải bảo đảm danh mục thuộc tài khoản hoặc là danh mục hệ thống. Kỳ tuần hoặc tháng lưu ngày bắt đầu và kết thúc theo `Asia/Ho_Chi_Minh`. PHP và phiên kết nối MySQL dùng cùng quy ước múi giờ. Ngày giờ phát sinh dùng `DATETIME` theo giờ Việt Nam, còn API trao đổi thời điểm theo ISO 8601 có độ lệch múi giờ. Truy vấn theo khoảng từ đầu ngày bắt đầu, tính cả mốc này, đến đầu ngày kế tiếp sau ngày kết thúc, loại trừ mốc cuối.

Tỷ lệ sử dụng là tổng độ lớn các khoản chi hợp lệ trong kỳ chia cho hạn mức dương và nhân 100%. Ngân sách theo danh mục lọc thêm danh mục chi, còn ngân sách tổng lấy toàn bộ khoản chi của tài khoản. Các ngưỡng là bình thường khi dưới 80%, cảnh báo từ 80% đến dưới 100% và vượt mức từ 100% trở lên. Báo cáo và ngân sách cùng lọc theo thời điểm phát sinh để thay đổi ngày hoặc danh mục được phản ánh ở cả kỳ và danh mục cũ lẫn mới khi truy vấn lại.

## Giao tác, yêu cầu gửi lại và bảo mật

Sau khi xác thực và kiểm tra dữ liệu, API mở giao tác InnoDB, kiểm tra quyền đối với tài nguyên và khóa các hàng ví liên quan bằng `SELECT ... FOR UPDATE` theo thứ tự `wallets_id` tăng dần. Khi sửa hoặc xóa, API khóa cả bản ghi giao dịch hiện tại, hoàn tác ảnh hưởng cũ và áp dụng ảnh hưởng mới nếu có. Với chuyển nội bộ, API trừ ví nguồn và cộng ví đích trong cùng giao tác. Bản ghi và số dư được commit cùng nhau hoặc cùng rollback. Khi xảy ra deadlock, API chỉ thử lại toàn bộ giao tác sau khi lần thực hiện lỗi đã được rollback.

Ứng dụng tạo một `Idempotency-Key` cho mỗi yêu cầu tạo giao dịch hoặc chuyển tiền và tái sử dụng khóa khi gửi lại cùng thao tác. Máy chủ lưu khóa cùng dấu vết nội dung yêu cầu và kết quả ghi trong cùng giao tác, với ràng buộc duy nhất theo tài khoản, thao tác và khóa. Yêu cầu lặp có cùng nội dung nhận lại kết quả ghi đã lưu. Khóa đã dùng với nội dung khác trả `409`. Sau khi nhận kết quả phát lại, ứng dụng có thể tải lại số dư mới nhất.

API kiểm tra trạng thái ngân sách sau khi commit khoản chi. Nếu bước đọc ngân sách thất bại, API vẫn xác nhận bản ghi đã lưu và báo cho ứng dụng tải lại trạng thái. Khi sửa hoặc xóa khoản chi, trạng thái liên quan được đọc lại theo các phạm vi bị ảnh hưởng. Báo cáo và ngân sách được tổng hợp từ dữ liệu giao dịch đã commit.

Quyền truy cập được kiểm tra theo người dùng lấy từ phiên xác thực cho mọi thao tác với dữ liệu cá nhân. Token phiên có hạn, phía máy chủ lưu giá trị băm của token và thu hồi phiên khi đăng xuất. Khôi phục mật khẩu qua email dùng mã có hạn và chỉ sử dụng một lần. Mật khẩu được lưu bằng `password_hash()` của PHP. Đăng nhập và khôi phục mật khẩu có giới hạn tần suất. Nhật ký kỹ thuật lưu mã yêu cầu và thông tin lỗi cần thiết, đồng thời loại bỏ mật khẩu, token và nội dung giao dịch cá nhân.

## Đặc tả triển khai và tiêu chí nghiệm thu

### Mở rộng đề xuất Google, icon và email

Google ID token được xác minh trên PHP; liên kết bằng thuộc tính UNIQUE `user_google_sub` trong users, không tự ghép theo email. Mật khẩu cho phép NULL với Google-only. Token phiên và mã xác minh/khôi phục cũng là thuộc tính users. Một tài khoản chỉ có một phiên hiện hành, tối đa 30 ngày.

Đề xuất dùng Material Icons cục bộ với mã icon ổn định và fallback; logo ví thương hiệu dùng asset có quyền sử dụng. Flaticon API là phương án thay thế qua backend nếu cần kho icon rộng hơn; không nhúng khóa API trong APK.

PHP ghi queue tệp sau commit, worker khóa tệp và kiểm tra lại người nhận trước khi gửi. Queue nằm ngoài webroot, không có bảng MySQL. Mã xác minh/khôi phục được gửi tới email liên hệ; thư chào mừng, đăng nhập và thu/chi chỉ gửi khi email đã xác minh. Khôi phục phiên không gửi thư. API tài chính phát sự kiện sẽ được nối ở bước 06–07.

### Điều kiện triển khai

ERD và PDM đích MySQL cần thể hiện các khóa ngoại, chỉ mục, quan hệ tài khoản, phiên đăng nhập, khôi phục mật khẩu và chống ghi trùng trước khi sinh DDL từ mô hình. Bước 03 dùng PHP 8.2/PDO trực tiếp, chưa cần framework; PHPMailer phụ trách MIME/SMTP. Cấu hình nằm ngoài webroot và đọc giá trị cục bộ/biến môi trường. Mô hình native còn chờ đồng bộ theo metadata MySQL; chi tiết endpoint nghiệp vụ được chốt trong bước 04–09. [Hợp đồng HTTP](http-api-contract.md) và [cách chạy](../backend/README.md).

Các ca nghiệm thu trọng tâm bao gồm cách ly hai tài khoản, thu hồi phiên, từ chối mã khôi phục hết hạn hoặc đã dùng, tạo giao dịch chỉ một lần khi gửi lại, cập nhật số dư đúng khi ghi đồng thời và rollback khi một bước ghi thất bại. Đối với báo cáo và ngân sách, cần kiểm tra chuyển nội bộ, sửa hoặc xóa khoản chi, giao dịch sát biên kỳ, các ngưỡng 80% và 100%, và trường hợp truy vấn ngân sách lỗi sau khi giao dịch đã lưu.

## Ràng buộc dữ liệu hiện hành

Không có transactions_type: xét ví đích trước dấu tiền; chuyển ví không tính vào thu/chi hoặc ngân sách. Các đề xuất khóa chống lặp, xóa mềm hoặc thuộc tính ngoài Word phải được duyệt riêng. Queue ghi sau commit, không nguyên tử với CSDL. Xem [chuẩn hóa](../../supabase/SUPABASE.md).
