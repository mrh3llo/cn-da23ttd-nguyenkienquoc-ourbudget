# Nền PHP/MySQL OurBudget — bước 03

API chạy PHP 8.2+ 64 bit, PDO MySQL và MySQL 8.0.16+ InnoDB. Hiện có `GET /api/v1/health`; màn hình Flutter vẫn dùng repository giả của bước 02. Đăng nhập thường/Google và phiên thật được nối trong bước 04. Web client ID đã được đặt trong `config/example.php`; đây là định danh công khai, không phải client secret.

## Cài và chạy trên Windows

1. Import CSDL theo [hướng dẫn MySQL](../database/README.md), bao gồm migration `004_step03_foundation.sql`.
2. Trong thư mục này chạy `composer install`. Cần PHP CLI đã bật `pdo_mysql`, `openssl` và `mbstring` (PHPMailer có fallback nếu thiếu mbstring).
3. Sao chép `config/example.php` thành `config/local.php`. Sửa host, port, database, user và password MySQL. Tài khoản chạy API chỉ cần SELECT/INSERT/UPDATE/DELETE; tài khoản import dùng riêng. Tệp local và thư mục vendor/storage không đưa vào Git. Biến môi trường `OURBUDGET_DB_HOST`, `OURBUDGET_DB_PORT`, `OURBUDGET_DB_NAME`, `OURBUDGET_DB_USER`, `OURBUDGET_DB_PASSWORD` ghi đè cấu hình tương ứng.
4. Chạy từ `src/backend/`:

```powershell
php -S 127.0.0.1:8080 -t public router.php
curl.exe -i http://127.0.0.1:8080/api/v1/health
```

Kết quả 200 chứa `data.status=ok`, `data.database=ok`, `data.schema=004_step03_foundation`. Nếu sai thông tin DB hoặc chưa chạy migration, trả 503 không lộ thông tin kết nối. Router phát triển chỉ đưa request vào front controller. Khi triển khai Apache/Nginx, document root phải là `public/`, cấu hình rewrite về `index.php`; cấu hình, vendor và storage nằm ngoài webroot. Dùng HTTPS và tắt `display_errors`; không dùng PHP built-in server làm máy chủ production.

## Android Emulator và điện thoại USB

Emulator tiêu chuẩn truy cập máy tính qua `10.0.2.2`. Từ thư mục Flutter:

```powershell
flutter test integration_test/backend_connection_test.dart -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Điện thoại bật USB debugging, xác nhận khóa máy tính và kiểm tra `adb devices`. Chuyển cổng qua USB rồi chạy với serial điện thoại:

```powershell
adb -s SERIAL reverse tcp:8080 tcp:8080
flutter test integration_test/backend_connection_test.dart -d SERIAL --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

`API_BASE_URL` chỉ là địa chỉ gốc; `ApiConfig` tự thêm `/api/v1`. Debug cho HTTP ở `localhost`, `127.0.0.1` và `10.0.2.2`; release không có ngoại lệ này và phải dùng HTTPS. Test thực hiện request từ Android, không chỉ từ máy tính. `flutter run --dart-define=...` chưa chuyển repository giả sang API nghiệp vụ; việc này tiến hành theo bước 04–09.

## Email outbox

`Outbox::enqueue()` chỉ được gọi trong giao tác đang mở. Service nghiệp vụ ghi thay đổi và outbox cùng commit; khóa sự kiện duy nhất ngăn lặp. Service phải tự giải quyết idempotency trước khi enqueue, không bắt mọi lỗi unique rồi coi là thành công. Tài khoản chưa xác minh email không nhận thông báo tài chính/đăng nhập/đăng ký; bước 04 gửi email xác minh trước và quyết định phát sự kiện chào mừng khi xác minh thành công.

Worker claim từng hàng bằng `FOR UPDATE SKIP LOCKED`, commit rồi mới gửi. Lease 120 giây, tối đa 5 lần claim; lỗi chuyển phát retry sau 30, 60, 120, 240 giây. Hết lượt chuyển `failed`; địa chỉ thay đổi, chưa xác minh hoặc tài khoản ngừng hoạt động chuyển `cancelled`. Khóa claim tránh worker cũ ghi đè kết quả worker mới. Dừng tiến trình sau SMTP accept nhưng trước cập nhật DB có thể gây thư trùng; Message-ID ổn định hỗ trợ truy vết, không bảo đảm exactly-once. Việc đổi địa chỉ đồng thời sau lần kiểm tra cuối ngay trước gửi vẫn là giới hạn của tác vụ SMTP ngoài giao tác.

Mặc định `mail_transport=file`: tạo thư `.eml` trong `storage/mail/`, chỉ dùng cho phát triển. Trạng thái `sent` trong chế độ này nghĩa là đã ghi tệp, không phải giao tới hộp thư Internet. Chạy một lần hoặc lô tối đa 50 thư:

```powershell
php bin/mail-worker.php --once
php bin/mail-worker.php
```

Task Scheduler/cron có thể gọi lệnh thứ hai mỗi phút. Với SMTP thật, đặt `mail_transport=smtp`, địa chỉ `mail_from`, host/port/username/password và `smtp_encryption=tls` (587) hoặc `ssl` (465) trong local.php. Không tắt xác minh TLS. Xem [setup Google/email](../docs/google-email-setup.md); OAuth client ID không phải thông tin đăng nhập SMTP. Không ghi credential, payload hoặc token vào log.

Sự kiện `email.verify` cần payload `verification_id` trỏ đến token chưa dùng, chưa hết hạn của email hiện tại và `verification_url` HTTPS do backend tạo. Bước 04 phải tự dựng URL từ cấu hình tin cậy, không nhận URL tùy ý từ client; lưu token dạng hash trong bảng xác minh, chỉ payload outbox bảo vệ quyền truy cập chứa link để gửi. Các event thu/chi chỉ đưa `amount` dạng chuỗi và `occurred_at` vào nội dung thư; snapshot phải lấy trong giao tác trước khi xóa. Không dùng queue cho chuyển tiền nội bộ nếu chưa có đặc tả thông báo riêng.

## Kiểm thử

Tạo database trống kết thúc `_test`, cung cấp các biến `OURBUDGET_DB_*`, chạy từ gốc repo:

```powershell
php src/database/tests/verify-foundation.php
php src/backend/tests/http.php
```

Test CSDL import 001–004, cố ý thay đổi dữ liệu thử để kiểm tra migration, identity và outbox; không dùng làm seed cho tài khoản demo lâu dài. Test HTTP mặc định gọi `http://127.0.0.1:18080`; đặt `OURBUDGET_TEST_API_URL` nếu dùng cổng 8080. Server PHP phải dùng cùng DB đã migrate. Fixture dùng chung nằm tại [http-fixtures.json](../contracts/http-fixtures.json). Kết quả thực tế và phần chưa nghiệm thu được ghi trong báo cáo bước 03.

Để kiểm tra cài mới không có demo, tạo **database thử trống khác**, đổi `OURBUDGET_DB_NAME` rồi chạy `php src/database/tests/verify-install.php`. Để kiểm tra 503 qua HTTP, chạy server thứ hai với tên DB không tồn tại và đặt `OURBUDGET_TEST_UNAVAILABLE_URL` trỏ tới server đó trước khi chạy `tests/http.php`. Hai bài kiểm thử không xóa database. Các thư `.eml` chứa dữ liệu giả được tạo trong storage/mail; không commit thư thật hoặc token xác minh.
