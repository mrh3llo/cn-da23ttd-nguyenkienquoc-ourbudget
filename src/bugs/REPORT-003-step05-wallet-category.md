# Bước 05. Tạo nguồn tiền và chọn danh mục

## Luồng đã triển khai

- **Cá nhân → Quản lý ví → Thêm nguồn tiền.** Loại ví lấy từ `wallet_categories`. Backend lấy chủ ví từ phiên xác thực và lưu số dư hiện tại bằng số dư đầu kỳ. Thứ tự ví hoạt động bắt đầu từ 0. Backend cấp thứ tự tiếp theo trong một giao dịch có khóa theo tài khoản.
- **Cá nhân → Danh mục.** Hai tab đọc `income_categories` và `outcome_categories` qua API có phân trang. Mỗi tab có nút thêm danh mục riêng. Sau khi lưu, ứng dụng tải lại danh sách tương ứng.
- **Nút +.** Nếu chưa có ví hoạt động, ứng dụng mở **Quản lý ví**. Nếu đã có ví hoạt động, biểu mẫu dùng danh sách ví thật và mở bộ chọn danh mục theo loại giao dịch. Lưu giao dịch thuộc Bước 06.

## API và dữ liệu

| API | Công dụng |
|---|---|
| `GET /api/v1/wallets` | Liệt kê ví của tài khoản đã xác thực |
| `GET /api/v1/wallet-categories` | Lấy mã và tên loại ví |
| `POST /api/v1/wallets` | Nhận `name`, `category_id` dạng chuỗi và `opening_balance` dạng chuỗi số nguyên VND |
| `GET /api/v1/categories?type=income` hoặc `type=expense` | Đọc danh mục dùng chung và danh mục thuộc phiên hiện tại |
| `POST /api/v1/categories` | Nhận `name` và `type`. Backend gán chủ sở hữu từ phiên xác thực |

Migration [category_ownership](../supabase/migrations/20261123093303_category_ownership.sql) thêm khóa ngoại `users_id` cho hai bảng danh mục. Giá trị để trống xác định danh mục dùng chung. Dữ liệu đã nhập tiếp tục xuất hiện với mọi tài khoản. Danh mục tạo qua ứng dụng được lọc theo chủ sở hữu. Migration đã được áp dụng trên Supabase với phiên bản `20261123093303`.

## Chạy thử bằng USB

APK debug của lượt này gọi backend qua `http://127.0.0.1:8080`. Từ thư mục gốc, chạy backend trong PowerShell sau khi cấu hình `src/backend/.env`.

```powershell
php -d extension=pdo_pgsql -S 127.0.0.1:8080 -t src/backend/public src/backend/router.php
```

Mở PowerShell khác, bật USB debugging và kết nối điện thoại. Dùng `adb` trong thư mục `platform-tools` của Android SDK.

```powershell
adb reverse tcp:8080 tcp:8080
adb install -r src/mobile/ourbudget/build/app/outputs/flutter-apk/app-debug.apk
```

Với API đã triển khai trên máy chủ, build với `--dart-define=API_BASE_URL=<địa chỉ HTTPS của backend PHP>`. Điện thoại gọi API PHP để quản lý ví và danh mục.

## Kiểm tra và phần còn lại

- Flutter analyze đạt, 23 kiểm thử Flutter đều đạt và APK debug build thành công. Kiểm thử widget xác nhận tải danh mục có sẵn, thêm đúng loại thu hoặc chi và mở quản lý ví từ nút + khi chưa có ví.
- PHP lint đạt. Backend chạy với PDO PostgreSQL, `/health` trả 200 và các endpoint đọc mới trả 401 khi thiếu phiên. Kiểm tra đọc qua PDO xác nhận phân trang theo loại và điều kiện lọc chủ ví. Supabase xác nhận còn 12 danh mục thu và 12 danh mục chi dùng chung sau migration.
- Cần nghiệm thu tạo ví và danh mục qua tài khoản thật trên thiết bị, cũng như kiểm tra cách ly dữ liệu bằng hai tài khoản thử.
- Bước 05 còn chỉnh sửa, đổi ví mặc định, ngừng sử dụng và kích hoạt lại ví, cùng các thao tác quản lý danh mục riêng. Các thao tác này nằm ngoài phần tạo và chọn đã triển khai.
