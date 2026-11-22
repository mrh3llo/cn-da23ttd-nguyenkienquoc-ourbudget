# TEST-005 — Schema 7 thực thể và xác thực bước 04

Ngày kiểm thử: 21/11/2026, Asia/Ho_Chi_Minh. Quyết định của tác giả: được thêm thuộc tính, không thêm thực thể và xóa các thực thể ngoài Báo cáo đề tài. Báo cáo này thay thế kết luận về schema hiện hành trong TEST-003/004; các báo cáo cũ vẫn được giữ như lịch sử.

## Kết luận và phạm vi

Đã hoàn thiện nền bước 03 theo mô hình bảy thực thể và triển khai mã bước 04: đăng ký, đăng nhập mật khẩu/Google, liên kết Google, hồ sơ, xác minh email, quên/đặt lại mật khẩu, phiên bảo mật và đăng xuất. PHP/MySQL và Flutter đã qua các kiểm thử bên dưới. Chưa xác nhận đăng nhập Google bằng tài khoản thật trên thiết bị, HTTPS phát hành hoặc thư thực sự vào Inbox; không coi các mục này là đã nghiệm thu.

Không triển khai API tài chính bước 05–09 trong lần này. Bản ứng dụng thật chỉ mở các phần đã nối API; giao diện dữ liệu mẫu bước 02 được giữ sau cờ DEMO_MODE=true. Chức năng gửi thông báo thu/chi chỉ có bộ xử lý queue, chưa có service thu/chi phát sự kiện.

## CSDL thật và chuyển đổi

Database `our_budget` trên MySQL cục bộ đã chuyển từ 15 về đúng 7 bảng: users, wallet_categories, wallets, income_categories, outcome_categories, transactions, budgets. Bổ sung thuộc tính Google, hash phiên, thời hạn, mã xác minh/reset và trạng thái chào mừng trong users. Không có bảng phụ cho phiên, queue, rate limit hoặc phiên bản migration.

Migrator kiểm tra schema và từ chối nếu các bảng kỹ thuật có dữ liệu cần bảo toàn (ngoại trừ marker phiên bản). Trước khi xóa, đã thử SQL 006 trên bản sao riêng `ourbudget_migration7_test`, sau đó mới áp dụng database thật. Backup ngay trước chuyển đổi: `src/backend/storage/backups/our_budget-20261121-190840-336f22.sql`. Backup và thông tin kết nối được Git bỏ qua.

Sau chuyển đổi, script xác nhận đúng bảy bảng, số hàng và hash giá trị các cột cũ của cả bảy bảng không thay đổi. Hai tài khoản, ba ví và ba giao dịch hiện hữu được giữ nguyên. Chạy migrator lần nữa trả `Schema current: seven report entities.`. DDL MySQL tự commit; nếu thất bại giữa chừng phải phục hồi backup, không giả định ROLLBACK hoàn tác toàn bộ.

## Môi trường

Windows; PHP 8.2.12, MySQL Community 8.0.46; firebase/php-jwt 7.2.2, PHPMailer 7.2.0. Flutter 3.50.1, Dart 3.14, Android Emulator Medium_Phone_API_37.0, thiết bị emulator-5554. SDK Platform 35 và CMake 3.22.1 được bổ sung trong quá trình build plugin.

Kiểm thử phá dữ liệu chỉ dùng các database riêng kết thúc `_test` trên MySQL thử port 13316. API thử port 18080 dùng file transport và runtime riêng; không gửi SMTP thật từ các suite tự động. CSDL cá nhân ở port 3306 chỉ dùng để sao lưu, chuyển schema và kiểm tra bảo toàn/health.

## Kết quả

| Nhóm | Kết quả | Bằng chứng/phạm vi |
| --- | --- | --- |
| Schema và dữ liệu tiền | 32/32 đạt | database/tests/verify.php; import 001–003, FK chủ ví, loại/dấu tiền, BIGINT, rollback, priority không âm và không trùng |
| Cài mới và queue tệp | 12/12 đạt | database/tests/verify-install.php; không có demo mặc định, dedup, khóa worker, mã dùng rồi bị hủy, đổi email, retry, xóa payload |
| Xác thực PHP | 52/52 đạt | backend/tests/auth.php; RSA JWT fixture, email trùng, phiên thay thế, logout đến muộn, mã sai/hết hạn/thay thế/dùng lại, Google collision/link, rate limit |
| Xác thực HTTP thật | 20/20 đạt | backend/tests/auth-http.php; đăng ký/login/me/verify/logout/reset và token Google không hợp lệ |
| HTTP chung và fixture | 32/32 đạt | backend/tests/http.php; health, 404/405, chặn đường config, request ID, no-store, JSON lỗi và chuỗi tiền |
| Flutter unit/widget | 13/13 đạt | flutter test; demo hồi quy, biểu mẫu, định dạng tiền/thời gian, lỗi mạng và phản hồi thuộc phiên cũ |
| Android tích hợp | 2/2 đạt | auth_flow_test.dart và backend_connection_test.dart; HTTP/PDO thật, secure storage trên Android, restore/logout/đổi tài khoản và health |
| Flutter analyze | Đạt | No issues found |
| PHP syntax | Đạt | php -l cho src, bin, public, tests và database/tests |
| APK debug | Build thành công | app-debug.apk, API_BASE_URL=http://10.0.2.2:8080, dành cho Android Emulator |

Kiểm tra tiếp ngày 22/11/2026: migrator xác nhận CSDL vẫn đúng bảy thực thể; API cục bộ trả health 200 với schema report-7-entities; git diff --check không có lỗi whitespace. Không chạy lại migration hoặc gửi thêm email. APK nêu trên dùng địa chỉ dành cho Emulator; muốn dùng điện thoại USB cần build theo [hướng dẫn Android](../docs/install-ourbudget-android.md).

Đã cài APK debug thông thường và quan sát màn hình đăng nhập trên Emulator ngày 22/11: tiếng Việt, trường email/mật khẩu và các nút Google/đăng ký/quên mật khẩu hiển thị đầy đủ, không thấy tràn bố cục ở kích thước này. Emulator ban đầu báo System UI không phản hồi trong lúc khởi động; sau khi hệ thống sẵn sàng, ứng dụng mở được. Ảnh kiểm tra cục bộ: graphify-out/ourbudget-auth-smoke.png. Chưa kiểm tra toàn bộ màn hình trên điện thoại cá nhân.

JWT Google trong suite được ký bằng khóa RSA thử và truyền trực tiếp vào bộ xác minh qua constructor; API công khai không có cơ chế nhận khóa thử. Đây là kiểm thử xác minh và nhánh nghiệp vụ, không phải OAuth thật với Google. Android integration kiểm tra AuthController, HTTP và plugin secure storage, không chứng minh thao tác chọn tài khoản Google hoặc mọi bố cục giao diện thật.

## SMTP và cấu hình

Gmail đã chấp nhận thư kiểm tra gửi tới địa chỉ do tác giả chỉ định sau khi sửa App Password. Không gửi lại thư chỉ để chạy các suite mới. Cần người nhận kiểm tra Inbox/Spam; SMTP accepted không chứng minh đã đọc/đã vào Inbox. API và worker dùng cấu hình local.php ngoài Git. Host MySQL chuyển sang 127.0.0.1 vì kết nối tên máy bị quyền host từ chối.

Worker hiện chạy thủ công bằng `php src/backend/bin/mail-worker.php`, chưa cài Task Scheduler/cron. Vì vậy đăng ký/gửi lại mã cần chạy worker để gửi. Queue tệp chỉ hỗ trợ một máy chủ có storage bền vững; chưa có tác vụ dọn lịch sử tự động.

## Giới hạn cần phản ánh trong báo cáo

Mỗi tài khoản chỉ có một phiên hiện hành, tối đa 30 ngày; đăng nhập mới thay phiên cũ. Queue được ghi sau commit, có thể mất thư nếu tiến trình dừng trong khoảng trống này; mất phản hồi SMTP có thể gây gửi trùng. Không còn transactional outbox MySQL. Mã xác minh/reset chỉ lưu hash trong CSDL nhưng payload chờ gửi chứa mã, cần bảo vệ quyền đọc runtime và backup.

Avatar nhận URL HTTPS, chưa upload từ thư viện ảnh. Backend/Flutter chưa có server HTTPS công khai. Word và các tệp PowerDesigner do tác giả đang chỉnh sửa không bị ghi đè; nội dung đồng bộ nằm trong [report-alignment-step03-step04.md](../docs/report-alignment-step03-step04.md). Native PDM cần cập nhật thuộc tính và đích DBMS trước khi sinh DDL, không thêm thực thể.

## Chạy lại

Mỗi suite cài schema cần database `_test` trống và runtime riêng. Đặt các biến OURBUDGET_DB_* tới MySQL thử, OURBUDGET_MAIL_TRANSPORT=file, OURBUDGET_RUNTIME_DIRECTORY tới thư mục riêng; Windows đặt OPENSSL_CONF nếu OpenSSL chưa tìm được cấu hình. Không dùng database cá nhân.

```powershell
php src/database/tests/verify.php
# Đổi sang DB thử trống và runtime trống khác cho từng suite sau:
php src/database/tests/verify-install.php
php src/backend/tests/auth.php
# API và hai suite HTTP phải dùng cùng DB/runtime thử:
php -S 127.0.0.1:18080 -t src/backend/public src/backend/public/index.php
# Chạy trong terminal khác với cùng biến môi trường:
php src/backend/tests/auth-http.php
php src/backend/tests/http.php
```

Trong src/mobile/ourbudget:

```powershell
flutter analyze
flutter test
flutter test integration_test/auth_flow_test.dart integration_test/backend_connection_test.dart -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:18080
```

Test không tự xóa database; nếu chạy lại phải tạo database thử mới. Các giới hạn truy cập có thể ảnh hưởng suite lặp nhanh trên cùng runtime, vì vậy dùng môi trường thử mới thay vì tắt bảo vệ ở API thật.
