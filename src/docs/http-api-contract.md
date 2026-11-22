# Hợp đồng HTTP dùng chung — OurBudget
CSDL runtime: Supabase PostgreSQL; Flutter tiếp tục chỉ truy cập qua API PHP.

Phiên bản `/api/v1`; HTTPS ở production, UTF-8 JSON và `Cache-Control: no-store`. Backend sinh mã request 32 ký tự hex, trả trong `meta.request_id` và header `X-Request-ID`. Mã này dùng đối chiếu log, không nhận nguyên giá trị client cung cấp. Xem [fixture dùng chung PHP/Flutter](../contracts/http-fixtures.json).

## Kết quả và lỗi

Phản hồi thành công có `data` và `meta`. Tạo mới dùng 201, đọc/cập nhật/xóa có phản hồi dùng 200. Lỗi có `error.code`, `error.message`, `error.fields` (object, kể cả rỗng) và `meta`. Mỗi khóa trong fields chứa danh sách thông báo. Client điều hướng theo HTTP status và code; không so khớp nội dung tiếng Việt.

| HTTP | Code dùng chung | Client xử lý |
| --- | --- | --- |
| 400 | `bad_request` | JSON hoặc cấu trúc request sai |
| 401 | `unauthenticated` | Phiên thiếu/hết hạn/thu hồi; chuyển về cổng phiên |
| 404 | `not_found` | Không tồn tại hoặc không thuộc tài khoản; không tiết lộ dữ liệu người khác |
| 405 | `method_not_allowed` | Sai phương thức; trả header Allow |
| 409 | `conflict` | Xung đột nghiệp vụ/idempotency; đọc lại trước khi quyết định gửi lại |
| 422 | `validation_failed` | Giữ biểu mẫu và hiển thị lỗi theo trường |
| 429 | `rate_limited` | Tuân thủ Retry-After, không lặp tức thời |
| 500 | `internal_error` | Lỗi ngoài dự kiến; chỉ trả thông báo chung |
| 503 | `service_unavailable` | DB/schema chưa sẵn sàng; cho phép thử lại thao tác đọc |

API thật hiện có health, xác thực và hồ sơ. API tài chính/phân trang còn thuộc bước 05–09. Health trả trạng thái sẵn sàng của schema, không trả thông tin server, mật khẩu hay phiên bản PostgreSQL.

## Xác thực và dữ liệu

Bước 04 triển khai `Authorization: Bearer <OurBudget session token>`. Google ID token chỉ dùng ở endpoint trao đổi Google; không dùng làm session token cho API nghiệp vụ. Backend xác minh chữ ký, issuer, audience Web client ID và thời hạn; liên kết bằng `user_google_sub`, không tự gộp theo email. Token session ngẫu nhiên được hash SHA-256 trong `users.users_sessions_hash`. Mọi truy vấn dữ liệu cá nhân lấy users_id từ phiên, không tin users_id trong request.

ID và tiền trong JSON là chuỗi số nguyên thập phân. Tiền VND có dấu, không có dấu phân cách hay phần thập phân, không đi qua float. Thời điểm dùng ISO 8601 có `Z` hoặc offset; backend chuyển về `Asia/Ho_Chi_Minh` trước lưu DATETIME. Kỳ lọc nhận ngày địa phương `YYYY-MM-DD`, dùng khoảng nửa mở từ đầu ngày bắt đầu tới trước ngày sau ngày kết thúc. Endpoint cụ thể xác định trường bắt buộc, giới hạn và quyền ở bước tương ứng.

## Phân trang và gửi lại

Danh sách dùng `page` (mặc định 1, tối thiểu 1) và `page_size` (mặc định 20, từ 1 đến 100); sai giá trị trả 422. Trả `data` là mảng, `meta.page`, `meta.page_size`, `meta.has_more` cùng request_id. Truy vấn thêm một hàng để xác định has_more. Lịch sử sắp `transactions_occurred_at DESC, transactions_id DESC`; danh sách ví dùng `wallets_priority ASC, wallets_id ASC`. Phân trang offset có thể dịch chuyển khi thêm/xóa giữa hai lần đọc: Flutter gộp theo ID, làm mới trang đầu sau ghi hoặc đổi bộ lọc; không coi các trang là một snapshot nhất quán.

POST tạo thu/chi/chuyển tiền dự kiến dùng `Idempotency-Key` ASCII 1–128 ký tự. Bước 06–07 bổ sung khóa, hash nội dung và phản hồi tạo ban đầu trong transactions, UNIQUE theo tài khoản/khóa; ghi cùng giao dịch và số dư. Cùng khóa khác nội dung trả 409. Giữ khóa qua xóa mềm; không tạo bảng riêng. Queue email ghi sau commit, không nguyên tử với CSDL. Chưa có endpoint hoặc cột chống lặp ở bước 04.

## Endhoint bước 04 đã có

| Phương thức/đường dẫn | JSON đầu vào | Kết quả |
| --- | --- | --- |
| POST auth/register | name, email, password | 201: token, expires_at, user |
| POST auth/login | email, password | 200: token, expires_at, user |
| POST auth/google | id_token | 200: token, , user |
| POST auth/google/link | Bearer; id_token, password | 200: user |
| GET me | Bearer | 200: user |
| PATCH me | Bearer; name, email; phone/avatar_url tùy chọn; current_password hoặc id_token khi đổi email | 200: user |
| POST auth/logout | Bearer; object rỗng | 200: revoked |
| POST auth/verify-email | Bearer; code | 200: user |
| POST auth/resend-verification | Bearer; object rỗng | 200: accepted |
| POST auth/forgot-password | email | 200: accepted, kể cả email không tồn tại |
| POST auth/reset-password | email, code, new_password | 200: reset |

user gồm id dạng chuỗi, name, email, phone, avatar_url, email_verified, has_password, google_linked. Không trả hash. PATCH là biểu mẫu đầy đủ: bỏ phone/avatar_url sẽ xóa giá trị cũ. Name tối đa 50 ký tự Unicode, email 150, phone 10, avatar_url 2048. Mật khẩu 8–72 byte. Avatar chỉ nhận HTTPS không userinfo, chưa upload. Request là JSON object tối đa 32 KiB, sai content type trả 415.

Một tài khoản có một token 64 ký tự hex, tối đa 30 ngày. Đăng nhập mới thay phiên cũ. Mã xác minh 30 phút, mã reset 15 phút, dùng một lần. Sai mật khẩu trả 401 invalid_credentials; chỉ 401 unauthenticated làm client xóa phiên hiện hành. Xung đột email/Google trả 409; mã sai/hết hạn trả 422. IP giới hạn 120 request/15 phút; mỗi hành động/định danh 10, riêng đăng ký/quên mật khẩu/gửi lại mã là 5. Bộ đếm lưu tệp riêng.

Sau commit, enqueue lỗi trả data.mail_warning=true; UI báo đã lưu nhưng chưa xếp thư, không tự đăng ký lại. SMTP chạy qua worker ngoài request. Health chỉ kiểm tra tối thiểu đúng bảy bảng và cột phiên; test schema kiểm tra ràng buộc chi tiết.
