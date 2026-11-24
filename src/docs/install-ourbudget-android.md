# Cài và dùng thử OurBudget trên điện thoại Android

Chọn địa chỉ API theo thiết bị trước khi đóng gói APK. Android Emulator dùng `http://10.0.2.2:8080` để gọi backend PHP trên máy tính. Điện thoại kết nối qua USB dùng `http://127.0.0.1:8080` cùng `adb reverse`. Để dùng trên điện thoại sau khi rút cáp, build với địa chỉ HTTPS của backend đã triển khai.

## Chạy trên Android Emulator

Khởi động backend PHP trên máy tính ở cổng `8080`. Từ `src/mobile/ourbudget/`, chạy lệnh sau với emulator đang mở.

```powershell
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

Để tạo APK riêng cho emulator, dùng `flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:8080`.

## Cách 1. Chép APK vào điện thoại

1. Build APK cho điện thoại với địa chỉ HTTPS của backend như bên dưới, rồi mở tệp `src\mobile\ourbudget\build\app\outputs\flutter-apk\app-release.apk` trong thư mục repo.
2. Nối điện thoại bằng cáp USB có truyền dữ liệu và mở khóa màn hình. Trong thông báo USB của điện thoại, chọn **Truyền tệp**. Dùng File Explorer trên Windows để chép `app-release.apk` vào thư mục **Download** của điện thoại.
3. Trên điện thoại, mở **Tệp** hoặc **Tệp của bạn**, vào **Download**, chạm vào `app-release.apk` rồi chọn **Cài đặt**. Nếu Android yêu cầu quyền cài từ nguồn này, cấp quyền cho chính ứng dụng quản lý tệp đang mở APK. Sau khi cài xong, có thể tắt lại quyền đó. [Trợ giúp cài ứng dụng từ nguồn khác](https://support.google.com/pixelphone/answer/7391672)
4. Chọn **Mở** hoặc tìm **OurBudget** trong danh sách ứng dụng. Cách này dùng chế độ truyền tệp USB, không cần bật gỡ lỗi USB.

Chạy các lệnh sau trong PowerShell từ thư mục gốc repo và thay `https://api.example.com` bằng địa chỉ HTTPS của backend PHP. Máy tính cần có Flutter và công cụ Android đã cấu hình. [Thiết lập Android cho Flutter](https://docs.flutter.dev/platform-integration/android/setup)

```powershell
Set-Location .\src\mobile\ourbudget
flutter pub get
flutter build apk --release --dart-define=API_BASE_URL=https://api.example.com
```

APK được tạo tại `build\app\outputs\flutter-apk\app-release.apk` tính từ thư mục dự án Flutter. Kiểm tra `https://api.example.com/api/v1/health` với tên miền backend thật trước khi cài. `API_BASE_URL` trỏ đến backend PHP đã triển khai. Flutter dùng riêng `SUPABASE_URL` và `SUPABASE_PUBLISHABLE_KEY` cho xác thực, với giá trị công khai mặc định của dự án. Có thể ghi đè chúng khi build bằng `--dart-define`, hoặc dùng `SUPABASE_ANON_KEY` cho khóa anon cũ. Tệp `.env` của backend chỉ được PHP đọc trên máy chủ. Nếu PowerShell không nhận lệnh `flutter`, xem mục **Xử lý lỗi thường gặp** bên dưới.

## Cách 2. Cài APK debug và kết nối qua Wi-Fi

Kết nối điện thoại và máy tính chạy backend vào cùng một mạng Wi-Fi. Lấy IPv4 của máy tính bằng `ipconfig`. Ví dụ dưới đây dùng `192.168.1.101`; thay địa chỉ này trong cả hai lệnh nếu IP của máy khác.

Từ thư mục gốc repo, chạy backend và giữ cửa sổ PowerShell mở trong lúc kiểm thử.

```powershell
php -d extension=pdo_pgsql -S 192.168.1.101:8080 -t src/backend/public src/backend/router.php
```

Từ một cửa sổ PowerShell khác, build và chép `app-debug.apk` sang điện thoại để cài.

```powershell
Set-Location .\src\mobile\ourbudget
flutter build apk --debug --dart-define=API_BASE_URL=http://192.168.1.101:8080
```

Trên điện thoại, mở `http://192.168.1.101:8080/api/v1/health` trong trình duyệt. Khi thấy `"database":"ok"`, mở OurBudget và thử Quản lý ví hoặc Danh mục thu/chi. Nếu trang không mở được, kiểm tra hai thiết bị cùng mạng Wi-Fi và địa chỉ IP. Nếu Windows Firewall chặn cổng 8080, chạy lệnh sau trong PowerShell với quyền quản trị.

```powershell
New-NetFirewallRule -DisplayName 'OurBudget Wi-Fi test' -Direction Inbound -Action Allow -Protocol TCP -LocalAddress 192.168.1.101 -LocalPort 8080 -RemoteAddress LocalSubnet -Profile Private -Program (Get-Command php).Source
```

Dùng Wi-Fi riêng khi thử vì HTTP truyền dữ liệu và token qua mạng dưới dạng không mã hóa.

## Cách 3. Chạy trực tiếp qua USB từ Android Studio

1. Trên điện thoại, vào **Cài đặt → Giới thiệu điện thoại** và chạm **Số bản dựng** 7 lần để bật **Tùy chọn nhà phát triển**. Vị trí mục này tùy hãng. Trong **Tùy chọn nhà phát triển**, bật **Gỡ lỗi USB**. [Cách bật tùy chọn nhà phát triển](https://developer.android.com/studio/debug/dev-options)
2. Cắm cáp dữ liệu, mở khóa máy và xác nhận hộp thoại **Cho phép gỡ lỗi USB** cho máy tính của bạn. Trên Windows, một số thiết bị cần trình điều khiển USB của hãng. [Kết nối thiết bị Android thật](https://developer.android.com/studio/run/device)
3. Khởi động backend PHP ở cổng `8080` và chạy `adb -s ID_THIET_BI reverse tcp:8080 tcp:8080`. Trong Android Studio, mở `src/mobile/ourbudget/`, chọn điện thoại và thêm `--dart-define=API_BASE_URL=http://127.0.0.1:8080` vào đối số của cấu hình Flutter chạy `lib/main.dart`. [Chạy Flutter trong Android Studio](https://docs.flutter.dev/tools/android-studio)

Bạn cũng có thể chạy bằng PowerShell từ thư mục gốc repo. Thay `ID_THIET_BI` bằng mã điện thoại hiện trong kết quả `flutter devices`.

```powershell
Set-Location .\src\mobile\ourbudget
flutter devices
adb -s ID_THIET_BI reverse tcp:8080 tcp:8080
flutter run -d ID_THIET_BI --dart-define=API_BASE_URL=http://127.0.0.1:8080
```

Nếu muốn cài APK để gọi backend qua cáp, build với `flutter build apk --debug --dart-define=API_BASE_URL=http://127.0.0.1:8080` từ thư mục Flutter. Sau đó chạy các lệnh sau từ thư mục gốc repo. [Tài liệu lệnh ADB](https://developer.android.com/tools/adb)

```powershell
$adb = 'E:\app\android-studio-sdk\platform-tools\adb.exe'
& $adb devices -l
& $adb -s ID_THIET_BI reverse tcp:8080 tcp:8080
& $adb -s ID_THIET_BI install -r .\src\mobile\ourbudget\build\app\outputs\flutter-apk\app-debug.apk
```

Khi ADB báo `Success`, mở OurBudget trên điện thoại. Giữ kết nối USB và backend đang chạy trong lúc kiểm thử.

## Thử một giao dịch với dữ liệu mẫu

Chạy ứng dụng với `--dart-define=DEMO_MODE=true` để mở chế độ dùng dữ liệu mẫu.

1. Mở **OurBudget**. **Trang chủ** hiển thị số dư, ngân sách tháng và giao dịch mẫu.
2. Nhấn **+**, chọn **Chi tiêu**, nhập `25000`, chọn **Ăn uống**, giữ nguồn tiền **Tiền mặt · Mặc định** và nhấn **Lưu giao dịch**.
3. Mở **Lịch sử** để thấy khoản chi mới. Nếu bắt đầu với số dư mẫu 5.420.000 đ, số dư sau khi lưu là 5.395.000 đ.

Dữ liệu mẫu nằm trong bộ nhớ. Giao dịch thử sẽ mất khi tiến trình ứng dụng kết thúc hoặc khi bạn chọn **Cá nhân → Thoát phiên thử nghiệm**.

## Xử lý lỗi thường gặp

| Hiện tượng | Cách xử lý |
| --- | --- |
| Điện thoại chỉ sạc hoặc Windows không thấy bộ nhớ | Mở khóa điện thoại, chọn **Truyền tệp**, thử cáp dữ liệu hoặc cổng USB khác. |
| ADB hiện `unauthorized` | Mở khóa điện thoại và xác nhận yêu cầu gỡ lỗi USB. Rút cáp rồi cắm lại nếu hộp thoại chưa xuất hiện. |
| Có cả máy ảo và điện thoại | Chọn điện thoại trong Android Studio hoặc truyền đúng ID cho `flutter run -d` hay `adb -s`. |
| Không nhận lệnh `flutter` | Dùng đường dẫn đến `flutter.bat` trong SDK trên máy hoặc thêm thư mục `bin` của SDK vào PATH. Bản SDK dùng lúc kiểm thử nằm trong `graphify-out\.ourbudget-sdk\flutter\bin\flutter.bat` tính từ thư mục gốc repo và là bộ cài cục bộ. [Thêm Flutter vào PATH](https://docs.flutter.dev/install/add-to-path) |
| Android báo không cài được hoặc ADB báo `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Kiểm tra phiên bản Android, dung lượng và APK đã chép đủ. Lỗi chữ ký xảy ra nếu máy đã có bản OurBudget ký bằng khóa khác. Hãy dùng APK ký cùng khóa để cập nhật. Nếu chọn gỡ bản cũ trước khi cài, dữ liệu của bản cũ trên máy sẽ bị xóa. |

## Khởi động backend PHP

Cấu hình thông tin kết nối PostgreSQL trong `src/backend/.env` theo [hướng dẫn backend](../backend/README.md). Từ thư mục gốc repo, chạy lệnh sau.

```powershell
php -d extension=pdo_pgsql -S 127.0.0.1:8080 -t src/backend/public src/backend/router.php
```

Kiểm tra `http://127.0.0.1:8080/api/v1/health` trên máy tính. Khi API trả HTTP 200, mở **Quản lý ví** và **Danh mục** trên ứng dụng đã đăng nhập để kiểm tra kết nối từ thiết bị.
