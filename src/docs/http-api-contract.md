# Hợp đồng HTTP dùng chung — OurBudget

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

Hiện API thật chỉ có health (200/405/503) và đường không tồn tại (404). Các mã khác là hợp đồng và fixture đã kiểm tra, không phải endpoint nghiệp vụ đã triển khai. Health trả trạng thái sẵn sàng của schema, không trả thông tin server, mật khẩu hay phiên bản MySQL.

## Xác thực và dữ liệu

Bước 04 triển khai `Authorization: Bearer <OurBudget session token>`. Google ID token chỉ dùng ở endpoint trao đổi Google; không dùng làm session token cho API nghiệp vụ. Backend xác minh chữ ký, issuer, audience Web client ID và thời hạn; liên kết bằng `provider + sub`, không tự gộp theo email. Token session ngẫu nhiên được hash SHA-256 trong `auth_sessions`. Mọi truy vấn dữ liệu cá nhân lấy users_id từ phiên, không tin users_id trong request.

ID và tiền trong JSON là chuỗi số nguyên thập phân. Tiền VND có dấu, không có dấu phân cách hay phần thập phân, không đi qua float. Thời điểm dùng ISO 8601 có `Z` hoặc offset; backend chuyển về `Asia/Ho_Chi_Minh` trước lưu DATETIME. Kỳ lọc nhận ngày địa phương `YYYY-MM-DD`, dùng khoảng nửa mở từ đầu ngày bắt đầu tới trước ngày sau ngày kết thúc. Endpoint cụ thể xác định trường bắt buộc, giới hạn và quyền ở bước tương ứng.

## Phân trang và gửi lại

Danh sách dùng `page` (mặc định 1, tối thiểu 1) và `page_size` (mặc định 20, từ 1 đến 100); sai giá trị trả 422. Trả `data` là mảng, `meta.page`, `meta.page_size`, `meta.has_more` cùng request_id. Truy vấn thêm một hàng để xác định has_more. Lịch sử sắp `transactions_occurred_at DESC, transactions_id DESC`; danh sách ví dùng `wallets_priority ASC, wallets_id ASC`. Phân trang offset có thể dịch chuyển khi thêm/xóa giữa hai lần đọc: Flutter gộp theo ID, làm mới trang đầu sau ghi hoặc đổi bộ lọc; không coi các trang là một snapshot nhất quán.

POST tạo thu/chi/chuyển tiền dùng `Idempotency-Key` ASCII không rỗng, tối đa 128 ký tự. Khóa được giữ qua timeout và retry của cùng ý định. Hash nội dung chuẩn hóa, bản ghi nghiệp vụ, số dư, outbox và phản hồi 201 được ghi cùng giao tác. Cùng khóa khác nội dung trả 409. Lỗi mạng/500 sau ghi có thể chưa rõ kết quả; client không tự tạo khóa mới. Quy tắc này được hiện thực trong bước 06–07; bước 03 chỉ chuẩn bị bảng và hợp đồng.
