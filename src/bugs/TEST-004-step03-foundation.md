# TEST-004 — Nền PHP/MySQL, HTTP và Android, bước 03

**Ngày kiểm thử:** 20–21/11/2026 (Asia/Ho_Chi_Minh). **Kết luận:** mã nền PHP/MySQL, migration, outbox và kết nối Android đạt các ca dưới đây. **Chưa chốt nghiệm thu toàn bộ bước 03:** ERD/PDM native chưa đồng bộ và mở kiểm tra trong PowerDesigner. Đây không phải báo cáo hoàn thành đăng nhập Google hay nghiệp vụ thu/chi thật.

## Phạm vi và môi trường

PHP CLI 8.2.12 64 bit, PDO MySQL; MySQL Community 8.0.46 InnoDB chạy instance thử độc lập tại 127.0.0.1:13316. Không thay đổi service MySQL80 đang có trên máy. Database thử `ourbudget_step03_test` và `ourbudget_clean_test`. API PHP built-in ở cổng 18080; server lỗi cấu hình riêng ở 18081. PHPMailer 7.2.0 được khóa trong composer.lock; transport kiểm thử là file hoặc callback gây lỗi, không gửi email Internet.

Flutter 3.50.1, Dart 3.14.0, Android Emulator `Medium_Phone_API_37.0`/`emulator-5554`, Android SDK tại `E:/app/android-studio-sdk`. Kiểm thử Android build debug APK, cài lên emulator và gọi API qua `http://10.0.2.2:18080`. Dùng Gradle cache cục bộ của lần triển khai trước để hoàn tất build; lần chạy đầu chưa khai báo SDK/cached Gradle đúng nên không được tính là kết quả đạt.

## Kết quả

| Nhóm | Kết quả | Bằng chứng và phạm vi |
| --- | --- | --- |
| Baseline + nâng cấp/outbox | **59/59 đạt** | `php src/database/tests/verify-foundation.php`; 34 kiểm tra cũ + 25 kiểm tra mới |
| Cài mới không demo + xác minh email | **7/7 đạt** | `php src/database/tests/verify-install.php` trên database trống khác |
| HTTP và fixtures dùng chung | **34/34 đạt** | `php src/backend/tests/http.php`, có `OURBUDGET_TEST_UNAVAILABLE_URL` để chạy thêm hai kiểm tra 503 |
| Flutter unit/widget | **8/8 đạt** | `flutter test --no-pub`; gồm fixture dùng chung PHP/Flutter và các ca bước 02 |
| Android → PHP → MySQL | **1/1 đạt** | `flutter test integration_test/backend_connection_test.dart -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:18080` |
| APK debug ứng dụng | **Đạt** | Sau integration test, build lại entry point thông thường bằng `flutter build apk --debug --no-pub`, tránh để APK test runner làm bản cài cuối |
| Phân tích Dart | **Đạt** | `flutter analyze --no-pub` |
| Cú pháp PHP | **Đạt** | `php -l` trên mã backend và các script kiểm thử CSDL, không bao gồm vendor |
| Composer | **Cài được, cấu hình hợp lệ** | `composer install`, `composer validate --no-check-publish`; có cảnh báo chưa khai báo license, không tự gán giấy phép cho dự án |
| Worker CLI | **Đạt** | `php src/backend/bin/mail-worker.php --once` trả `Processed: 0` sau khi queue đã xử lý hết |
| Git/secret exclusion | **Đạt** | `git diff --check` không có lỗi whitespace; `git check-ignore` xác nhận OAuth download, config/local.php, vendor và storage không vào Git |

100 kiểm tra PHP và 9 kiểm thử Flutter/Android đã đạt; các nhóm lint/Composer/CLI không cộng vào số ca này. HTTP 401/409/422/500 được kiểm tra ở mức envelope/fixture, **chưa có endpoint nghiệp vụ thật để gây các trạng thái đó**. Các trạng thái HTTP thật đã gọi là 200, 404, 405 và 503.

## Những trường hợp quan trọng đã xác nhận

Migration chuyển seed cũ 10/0/10 thành 0/1/0, giữ ví mặc định, ID và số dư 55.000/30.000/250.000 đồng. Email cũ không tự được xác minh; mật khẩu có thể NULL cho Google-only. Unique identity ngăn cùng Google subject thuộc hai tài khoản và ngăn một tài khoản gắn hai Google subject. Unique ví hoạt động chặn hai ví cùng thứ tự; CHECK chặn thứ tự âm. Cài mới 001 → 002 → 004 không tạo tài khoản demo.

Outbox yêu cầu giao tác đang mở; rollback hoàn tác cả số dư và sự kiện email. Event trùng không tạo thêm hàng. Hai kết nối PDO xác nhận worker thứ hai bỏ qua hàng đang khóa, lease hết hạn có thể được nhận lại, và worker cũ không ghi đè claim mới. Mô phỏng lỗi chuyển phát đặt lịch retry, không ghi thông tin lỗi có credential và không đổi số dư; hết năm lượt chuyển failed. Đổi email hoặc bỏ xác minh làm hủy thư cũ. Thư xác minh chỉ được enqueue cho token hợp lệ của email hiện tại; token đã dùng khiến thư đang chờ bị hủy. Transport file tạo MIME có số tiền chính xác và Message-ID ổn định.

API health chỉ đạt khi truy cập được schema đã migrate. Đường ngoài API hoặc tìm cấu hình qua URL trả 404; sai phương thức health trả 405/Allow. Lỗi database trả 503, không trả SQLSTATE hoặc DSN. Phản hồi có request_id do server sinh và no-store. Fixture 201 bảo toàn chuỗi tiền BIGINT lớn nhất và thời điểm qua ranh giới ngày Việt Nam khi giải mã trong Flutter. Android thật trong emulator gọi health thành công và ánh xạ 404 qua ApiFailure.

## Chưa nghiệm thu và giới hạn

1. **ERD/PDM native:** các tệp người dùng đang sửa vẫn giữ nguyên đích cũ SAP SQL Anywhere 17. Khởi tạo PowerDesigner qua COM chưa thành công trong phiên này; chưa có bằng chứng mở/kiểm tra mô hình native. Đã xuất [model-reference.md](../database/model-reference.md) từ metadata 14 bảng thật để đối chiếu. SQL là nguồn triển khai; không sinh lại DDL từ PDM cũ. Đây là hạng mục còn lại của bước 03.
2. **Google:** đã nhận Web client ID và đặt cấu hình mẫu. Chưa xác minh ID token, chữ ký/audience/issuer/expiry, SHA-1 debug/release hoặc luồng đăng nhập Google thật. Những ca này thuộc bước 04; chưa kết nối với Google để kiểm chứng OAuth Client do người dùng tạo.
3. **Email:** chưa thử SMTP thật, xác minh tên miền gửi, deliverability hoặc Gmail. File `sent` chỉ nghĩa là ghi MIME thành công. SMTP là at-least-once, vẫn có thể trùng thư khi mất kết quả sau accept; có khoảng đua đổi địa chỉ sau bước kiểm tra cuối. Không tự gửi thư thật trong phiên này.
4. **Nghiệp vụ:** Flutter vẫn dùng repository giả. API đăng ký/phiên, danh mục/ví, idempotency tạo giao dịch, số dư, ngân sách và báo cáo chưa được nối thực tế; hoàn thiện theo bước 04–09. Tính liên tục thứ tự ví 0..N−1 do service bước 05 bảo đảm; SQL mới chỉ chặn âm và trùng thứ tự hoạt động.
5. **Thiết bị/phát hành:** đã chạy emulator, chưa chạy trên điện thoại cá nhân qua USB và chưa kiểm thử endpoint HTTPS production/release. Ngoại lệ HTTP chỉ nằm ở manifest/resource debug; không sửa release để cho cleartext toàn cục.
6. **Nâng cấp:** thử trên dữ liệu baseline có sẵn trong database dùng một lần; chưa chạy trên CSDL thật của người dùng. MySQL DDL tự commit; cần sao lưu và dừng ứng dụng khi migrate. Không chạy 004 lặp lại hoặc trên dữ liệu đã tự đổi quy tắc ưu tiên.

## Tái lập và bước tiếp theo

Theo [README backend](../backend/README.md), [README CSDL](../database/README.md) và [HTTP contract](../docs/http-api-contract.md). Mỗi lần chạy bộ kiểm thử CSDL dùng database `_test` mới, trống; không dùng hai database đã chứa kết quả thử để chạy lại. Các tiến trình MySQL/PHP phục vụ kiểm thử được dừng sau nghiệm thu, nên cần chạy server theo README khi thử tiếp.

Đồng bộ và mở kiểm tra ERD/PDM theo metadata trước khi đánh dấu toàn bộ bước 03 hoàn thành. Sau đó triển khai bước 04: session nội bộ, đăng ký/đăng nhập, Google token verification, xác minh email và các sự kiện auth. Tệp Word, thiết kế Figma và mô hình native không được chỉnh trong phần triển khai này. Không commit hoặc push trong phiên này.
