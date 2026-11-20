# Cài và dùng thử OurBudget trên điện thoại Android

**Cách nhanh nhất là chép APK vào điện thoại và mở tệp để cài.** Bản thử nghiệm hiện có chạy trên Android 7.0 trở lên và đã được kiểm tra trên Android Emulator. Bạn có thể mở ứng dụng sau khi rút cáp. [APK debug đã build](../mobile/ourbudget/build/app/outputs/flutter-apk/app-debug.apk) · [Báo cáo kiểm thử bản thử nghiệm](../bugs/TEST-002-flutter-foundation-prototype.md)

## Cách 1. Chép APK vào điện thoại

1. Trên máy tính, mở tệp `src\mobile\ourbudget\build\app\outputs\flutter-apk\app-debug.apk` trong thư mục repo. Tệp hiện tại khoảng 183 MB.
2. Nối điện thoại bằng cáp USB có truyền dữ liệu và mở khóa màn hình. Trong thông báo USB của điện thoại, chọn **Truyền tệp**. Dùng File Explorer trên Windows để chép `app-debug.apk` vào thư mục **Download** của điện thoại.
3. Trên điện thoại, mở **Tệp** hoặc **Tệp của bạn**, vào **Download**, chạm vào `app-debug.apk` rồi chọn **Cài đặt**. Nếu Android yêu cầu quyền cài từ nguồn này, cấp quyền cho chính ứng dụng quản lý tệp đang mở APK. Sau khi cài xong, có thể tắt lại quyền đó. [Trợ giúp cài ứng dụng từ nguồn khác](https://support.google.com/pixelphone/answer/7391672)
4. Chọn **Mở** hoặc tìm **OurBudget** trong danh sách ứng dụng. Cách này dùng chế độ truyền tệp USB, không cần bật gỡ lỗi USB.

Nếu tệp APK đã bị xóa hoặc bạn muốn đóng gói lại mã hiện tại, chạy các lệnh sau trong PowerShell từ thư mục gốc repo. Máy tính cần có Flutter và công cụ Android đã cấu hình. [Thiết lập Android cho Flutter](https://docs.flutter.dev/platform-integration/android/setup)

```powershell
Set-Location .\src\mobile\ourbudget
flutter pub get
flutter build apk --debug
```

APK được tạo lại tại `build\app\outputs\flutter-apk\app-debug.apk` tính từ thư mục dự án Flutter. Nếu PowerShell không nhận lệnh `flutter`, xem mục **Xử lý lỗi thường gặp** bên dưới.

## Cách 2. Chạy trực tiếp qua USB từ Android Studio

1. Trên điện thoại, vào **Cài đặt → Giới thiệu điện thoại** và chạm **Số bản dựng** 7 lần để bật **Tùy chọn nhà phát triển**. Vị trí mục này tùy hãng. Trong **Tùy chọn nhà phát triển**, bật **Gỡ lỗi USB**. [Cách bật tùy chọn nhà phát triển](https://developer.android.com/studio/debug/dev-options)
2. Cắm cáp dữ liệu, mở khóa máy và xác nhận hộp thoại **Cho phép gỡ lỗi USB** cho máy tính của bạn. Trên Windows, một số thiết bị cần trình điều khiển USB của hãng. [Kết nối thiết bị Android thật](https://developer.android.com/studio/run/device)
3. Trong Android Studio đã có plugin Flutter và Dart, chọn **File → Open** rồi mở `src/mobile/ourbudget/`, thư mục chứa `pubspec.yaml`. Chọn **điện thoại thật** trong danh sách thiết bị, chọn cấu hình Flutter chạy `lib/main.dart`, rồi bấm **Run ▶**. [Chạy Flutter trong Android Studio](https://docs.flutter.dev/tools/android-studio)

Bạn cũng có thể chạy bằng PowerShell từ thư mục gốc repo. Thay `ID_THIET_BI` bằng mã điện thoại hiện trong kết quả `flutter devices`.

```powershell
Set-Location .\src\mobile\ourbudget
flutter devices
flutter run -d ID_THIET_BI
```

Nếu đã có APK và chỉ muốn cài qua cáp, dùng ADB sau khi bật gỡ lỗi USB. Hai lệnh dưới đây chạy từ thư mục gốc repo với đường dẫn Android SDK trên máy phát triển hiện tại. [Tài liệu lệnh ADB](https://developer.android.com/tools/adb)

```powershell
$adb = 'E:\app\android-studio-sdk\platform-tools\adb.exe'
& $adb devices -l
& $adb -s ID_THIET_BI install -r .\src\mobile\ourbudget\build\app\outputs\flutter-apk\app-debug.apk
```

Khi ADB báo `Success`, mở OurBudget trên điện thoại. Có thể tắt **Gỡ lỗi USB** sau khi dùng xong.

## Thử một giao dịch

1. Mở **OurBudget**. **Trang chủ** hiển thị số dư, ngân sách tháng và giao dịch mẫu.
2. Nhấn **+**, chọn **Chi tiêu**, nhập `25000`, chọn **Ăn uống**, giữ nguồn tiền **Tiền mặt · Mặc định** và nhấn **Lưu giao dịch**.
3. Mở **Lịch sử** để thấy khoản chi mới. Nếu bắt đầu với số dư mẫu 5.420.000 đ, số dư sau khi lưu là 5.395.000 đ.

Bản hiện tại dùng dữ liệu mẫu trong bộ nhớ và có thể dùng thử mà không cần máy chủ hoặc tài khoản thật. Giao dịch thử sẽ mất khi tiến trình ứng dụng kết thúc hoặc khi bạn chọn **Cá nhân → Thoát phiên thử nghiệm**.

## Xử lý lỗi thường gặp

| Hiện tượng | Cách xử lý |
| --- | --- |
| Điện thoại chỉ sạc hoặc Windows không thấy bộ nhớ | Mở khóa điện thoại, chọn **Truyền tệp**, thử cáp dữ liệu hoặc cổng USB khác. |
| ADB hiện `unauthorized` | Mở khóa điện thoại và xác nhận yêu cầu gỡ lỗi USB. Rút cáp rồi cắm lại nếu hộp thoại chưa xuất hiện. |
| Có cả máy ảo và điện thoại | Chọn điện thoại trong Android Studio hoặc truyền đúng ID cho `flutter run -d` hay `adb -s`. |
| Không nhận lệnh `flutter` | Dùng đường dẫn đến `flutter.bat` trong SDK trên máy hoặc thêm thư mục `bin` của SDK vào PATH. Bản SDK dùng lúc kiểm thử nằm trong `graphify-out\.ourbudget-sdk\flutter\bin\flutter.bat` tính từ thư mục gốc repo và là bộ cài cục bộ. [Thêm Flutter vào PATH](https://docs.flutter.dev/install/add-to-path) |
| Android báo không cài được hoặc ADB báo `INSTALL_FAILED_UPDATE_INCOMPATIBLE` | Kiểm tra phiên bản Android, dung lượng và APK đã chép đủ. Lỗi chữ ký xảy ra nếu máy đã có bản OurBudget ký bằng khóa khác. Hãy dùng APK ký cùng khóa để cập nhật. Nếu chọn gỡ bản cũ trước khi cài, dữ liệu của bản cũ trên máy sẽ bị xóa. |
