# Kiểm thử bước 01 Khởi tạo Flutter Android

**Ngày kiểm thử** 20/11/2026. **Kết quả** Dự án đã mở trong Android Studio, build được APK debug và khởi động được trên Android Emulator. Lần chạy được xác minh trên máy ảo dùng ADB. Thao tác Run trực tiếp bằng plugin Flutter trong IDE chưa được kiểm tra. [Lộ trình bước 01](../docs/implementation-roadmap.md#bước-01-khởi-tạo-dự-án-flutter-android) · [Dự án Flutter](../mobile/ourbudget/README.md)

## Môi trường

| Thành phần | Phiên bản hoặc cấu hình |
| --- | --- |
| Hệ điều hành | Windows 10 22H2 |
| Flutter và Dart | Flutter 3.50.1 stable, Dart 3.14.0 |
| Công cụ Android | Android Studio với JBR 25, Android SDK Platform 36, Build Tools 36.0.0, NDK 28.2.13676358 |
| Thiết bị kiểm thử | Android Emulator, AVD `Medium_Phone_API_37.0`, x86_64 |
| Điểm vào ứng dụng | `lib/main.dart`, Android application ID `com.ourbudget.ourbudget` |

## Kết quả kiểm thử

| Kiểm tra | Kết quả | Bằng chứng |
| --- | --- | --- |
| Khởi tạo dự án Android | Đạt | Sinh cấu hình Gradle và manifest bằng mẫu Flutter Android. Có `pubspec.yaml` và `pubspec.lock`. Cây phân hệ và tài nguyên đã có vẫn hiện diện. |
| `flutter doctor -v` | Đã chạy, có cảnh báo | Nhận Flutter và Dart đúng phiên bản. SDK Flutter được gọi bằng đường dẫn trực tiếp, nên lệnh chẩn đoán báo Flutter/Dart chưa có trong PATH. |
| `flutter pub get` | Đạt | Phân giải phụ thuộc thành công và tạo lockfile. Lần chạy lại với `--offline` cũng thành công. |
| `flutter analyze --no-pub` | Đạt | `No issues found!` |
| `flutter test --no-pub` | Đạt | 1/1 bài kiểm thử widget xác nhận tiêu đề OurBudget và chuỗi “Quản lý chi tiêu cá nhân”. |
| `dart format --output=none --set-exit-if-changed lib/main.dart test/widget_test.dart` | Đạt | Hai tệp đúng định dạng, không có thay đổi. |
| `flutter build apk --debug --no-pub` | Đạt | Gradle hoàn thành `assembleDebug` và sinh `build/app/outputs/flutter-apk/app-debug.apk`. |
| Mở dự án trong Android Studio | Đã xác minh mở | Nhật ký Android Studio ghi nhận mở dự án tại `src/mobile/ourbudget/`. Chưa xác minh thao tác Run từ plugin Flutter. |
| Cài APK và chạy trên Android Emulator | Đạt | ADB cài thành công. Lệnh khởi động trả `Status: ok` với `MainActivity`. Ảnh chụp sau đó hiển thị đầy đủ tiêu đề và dòng tiếng Việt. |

Trong lần chụp đầu, máy ảo hiển thị hộp thoại “System UI isn't responding” của Android. Sau khi dừng phiên máy ảo thử dư thừa và chờ giao diện hệ thống phục hồi, ảnh chụp lại hiển thị màn hình OurBudget đầy đủ. Ảnh và APK là hiện vật kiểm thử cục bộ.

## Chạy lại

Chạy từ `src/mobile/ourbudget/` với Flutter SDK 3.50.1 đã cấu hình. Mở thư mục này trong Android Studio và chọn một thiết bị Android để chạy `lib/main.dart`. Các lệnh kiểm tra tương ứng là `flutter doctor -v`, `flutter pub get`, `flutter analyze`, `flutter test` và `flutter run -d <device-id>`. [Hướng dẫn Flutter trong Android Studio](https://docs.flutter.dev/tools/android-studio) · [Thiết lập Android cho Flutter](https://docs.flutter.dev/platform-integration/android/setup)

Phạm vi kiểm thử là khởi tạo dự án và màn hình tối thiểu. Thiết bị Android thật, Provider, giao diện Figma và kết nối API thuộc các đợt kiểm thử tiếp theo.
