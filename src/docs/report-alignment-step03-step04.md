# Nội dung cần điều chỉnh trong Báo cáo đề tài — bước 03 và 04

Ngày đối chiếu: 21/11/2026. Nguồn là `thesis/doc/2. Báo cáo đề tài.docx`, schema MySQL và mã PHP/Flutter hiện tại. Không chỉnh sửa trực tiếp Word. Quyết định mới nhất của tác giả: được thêm thuộc tính, không thêm thực thể; loại bỏ các bảng ngoài báo cáo. Quyết định này thay thế mọi đề xuất bảng kỹ thuật trong phiên bản tài liệu trước.

## Mô hình dữ liệu cần giữ nguyên

Mô hình có **bảy thực thể**: `users`, `wallet_categories`, `wallets`, `income_categories`, `outcome_categories`, `transactions` và `budgets`. Phần mô tả đang ghi “5 thực thể” cần sửa thành “7 thực thể”. Không vẽ thêm thực thể cho phiên, danh tính Google, mã xác minh, mã khôi phục, email, giới hạn truy cập hoặc phiên bản migration. Danh mục dùng chung có `users_id=NULL`; dữ liệu cá nhân thuộc một người dùng. Chuyển tiền là một loại giao dịch với ví nguồn và ví đích, không phải thực thể mới. Báo cáo thống kê được tổng hợp từ giao dịch.

Các bảng kỹ thuật trước đây (`auth_sessions`, `password_resets`, `idempotency_keys`, `user_identities`, `email_verifications`, `email_outbox`, `auth_rate_limits`, `schema_migrations`) đã bị loại khỏi thiết kế triển khai. Tệp SQL 006 chỉ chứa chuyển đổi và lệnh xóa các bảng này, không phải danh sách thực thể cần đưa vào báo cáo.

## Thuộc tính và kiểu dữ liệu

| Nội dung trong báo cáo | Nội dung triển khai cần phản ánh |
| --- | --- |
| Khóa định danh VARCHAR(10) | Khóa chính/ngoại BIGINT UNSIGNED; API truyền ID bằng chuỗi để không mất độ chính xác |
| Tiền có phần thập phân | Tiền VND nguyên dùng BIGINT, API truyền chuỗi số; không dùng float |
| Tên/email/điện thoại người dùng | VARCHAR(100), VARCHAR(254), VARCHAR(20); email UNIQUE |
| Mật khẩu TEXT | VARCHAR(255) lưu hash; NULL khi chỉ đăng nhập Google |
| Vai trò người dùng | Bản hiện tại không có phân hệ quản trị hay cột role; không mô tả chức năng quản trị đã triển khai |
| Thứ tự ví | `wallets_priority` tăng 0, 1, 2…; ví mặc định là 0. `active_priority` là cột sinh phục vụ UNIQUE cho ví hoạt động |
| Thời gian | DATETIME theo Asia/Ho_Chi_Minh; API ISO 8601 có offset |
| Đích PDM SQL Anywhere 17 | Triển khai dùng MySQL 8.0.16+ và InnoDB; phải đổi đích trước khi sinh SQL từ PowerDesigner |

Trong `users`, bổ sung `users_avatar_url`, `users_updated_at`, `users_verified_at`, `user_google_sub`, `users_sessions_hash`, `users_sessions_expires_at`, `users_verification_hash`, `users_verification_experes_at`, `users_reset_hash`, `users_reset_expires_at` và `users_welcomed_at` nếu bảng thuộc tính trong Word chưa có. Định danh Google là chuỗi so sánh chính xác và duy nhất. Ba loại mã phiên/xác minh/khôi phục được băm SHA-256 thành BINARY(32), có cột thời hạn riêng; không dùng thay thế lẫn nhau. Mã dùng xong được xóa. Các cột đầy đủ, khóa và quan hệ được ghi trong [schema metadata](../supabase/model-reference.md).

## Đoạn văn kiến trúc có thể đưa vào báo cáo

Hệ thống OurBudget được triển khai theo mô hình khách–chủ, trong đó ứng dụng Flutter trên Android đảm nhiệm giao diện và trạng thái tương tác, API PHP xử lý xác thực và quy tắc nghiệp vụ, còn MySQL InnoDB lưu trữ dữ liệu theo mô hình gồm bảy thực thể đã thiết kế. Ứng dụng không kết nối trực tiếp đến MySQL. Trao đổi dữ liệu sử dụng JSON qua các endpoint có tiền tố `/api/v1`; môi trường phát hành yêu cầu HTTPS, trong khi môi trường phát triển cục bộ sử dụng kết nối HTTP phục vụ kiểm thử.

Thông tin xác thực được biểu diễn bằng các thuộc tính bổ sung của thực thể người dùng. Mỗi tài khoản có tối đa một phiên đang hoạt động, tồn tại tối đa 30 ngày nếu không bị thay thế hoặc thu hồi. Đăng nhập mới thay thế phiên trước, đăng xuất thu hồi phiên tương ứng và đặt lại mật khẩu thu hồi phiên hiện hành. Ứng dụng lưu token bằng cơ chế lưu trữ bảo mật của Android, kiểm tra lại với máy chủ trước khi hiển thị dữ liệu riêng và loại bỏ phản hồi thuộc phiên cũ. Khi mất mạng trong quá trình khôi phục, ứng dụng cho phép thử lại, không kết luận token đã hết hạn chỉ từ lỗi kết nối.

Đăng nhập Google được thực hiện bằng việc trao đổi Google ID token lấy phiên nội bộ. Máy chủ kiểm tra chữ ký, bên phát hành, đối tượng nhận và thời hạn; định danh liên kết là thuộc tính `sub` do Google cấp. Email trùng nhau không tự động hợp nhất hai tài khoản. Người dùng đã có tài khoản mật khẩu phải đăng nhập và xác thực lại mật khẩu trước khi liên kết Google. Email của tài khoản chỉ dùng Google có thể cần xác minh riêng nếu không thuộc miền mà Google xác nhận quyền kiểm soát.

Mã xác minh email có hiệu lực 30 phút và mã khôi phục mật khẩu có hiệu lực 15 phút, được dùng một lần. Thông báo đăng ký được tạo sau khi email được xác minh, còn thông báo đăng nhập chỉ được tạo khi người dùng chủ động đăng nhập thành công bằng địa chỉ đã xác minh. Việc khôi phục phiên không tạo thêm thư đăng nhập. Email liên hệ thay đổi phải được xác minh lại; tác vụ gửi tới địa chỉ cũ bị hủy khi worker kiểm tra lại người nhận.

Để giữ nguyên số thực thể, hàng đợi email và bộ đếm giới hạn truy cập được lưu trong thư mục riêng ngoài webroot, không đặt trong CSDL. Worker khóa từng tệp để tránh xử lý đồng thời, thử gửi tối đa năm lần và xóa mã xác minh khỏi payload khi tác vụ kết thúc. Hàng đợi được ghi sau khi giao tác MySQL thành công; do đó lỗi gửi thư không hoàn tác tài khoản hoặc giao dịch. Phương án này có giới hạn: tiến trình dừng giữa commit và ghi tệp có thể làm mất thông báo; SMTP có thể gửi trùng nếu mất phản hồi sau khi đã nhận thư. Không mô tả đây là hàng đợi nguyên tử với CSDL hay cơ chế chuyển phát đúng một lần. Triển khai hiện tại phù hợp với một máy chủ có thư mục runtime bền vững.

## Use-case, giao diện và phạm vi đã triển khai

Giữ các mã UC1–UC5, bổ sung luồng Google, xác minh email, xác thực lại khi đổi email, một phiên trên mỗi tài khoản và thông báo khi không thể thu hồi phiên do mất mạng. Avatar hiện nhận URL HTTPS; không mô tả chức năng tải ảnh từ thư viện thiết bị. Luồng khôi phục nhập email, mã nhận trong thư và mật khẩu mới, chưa có deep link HTTPS công khai.

Bước 03 đã có schema bảy bảng, seed, API health, hợp đồng HTTP, kiểm thử ràng buộc và đường chuyển đổi có sao lưu. Bước 04 đã có mã PHP/Flutter cho đăng ký, đăng nhập mật khẩu/Google, hồ sơ, liên kết Google, xác minh email, quên/đặt lại mật khẩu và đăng xuất. Kết quả kiểm thử và các mục chưa xác nhận được ghi riêng trong [TEST-005](../bugs/TEST-005-step04-report-entities.md); không suy diễn chữ ký JWT giả lập thành bằng chứng đăng nhập Google thật trên thiết bị.

Các chức năng ví, danh mục, thu/chi, chuyển tiền, ngân sách và thống kê thật thuộc bước 05–09. Giao diện mẫu bước 02 chỉ chạy khi bật `DEMO_MODE=true`; tài khoản thật không hiển thị dữ liệu tài chính mẫu. Email theo thu/chi mới có bộ xử lý hàng đợi, chưa có API thu/chi phát sự kiện. Không đưa các luồng này vào nhóm đã nghiệm thu.

Đối với bước 06–07, chống tạo giao dịch trùng sẽ dùng các thuộc tính khóa yêu cầu, hash nội dung và phản hồi tạo ban đầu trong `transactions`, với UNIQUE theo tài khoản và khóa; không tái tạo bảng idempotency. Khi bổ sung phải kiểm thử đồng thời, rollback và giữ khóa sau xóa mềm. Đây là thiết kế dự kiến, chưa có cột hoặc endpoint tương ứng trong bước 04.

Word và các tệp PowerDesigner đang được tác giả chỉnh sửa được giữ nguyên. Khi hoàn thiện quyển báo cáo, cập nhật thuộc tính và DBMS trong bản native, mở kiểm tra quan hệ rồi xuất lại hình; không thêm thực thể để khớp các bản thiết kế kỹ thuật cũ.
