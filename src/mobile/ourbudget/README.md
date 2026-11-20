# OurBudget cho Android

Đây là dự án Flutter Android của OurBudget. Các tệp `.gitkeep` giữ những thư mục đang chờ mã nguồn, tài nguyên hoặc kiểm thử. [Kiến trúc ứng dụng Flutter](../../docs/flutter-app-architecture.md) · [Kiến trúc hệ thống](../../docs/final-system-architecture.md) · [Lộ trình triển khai](../../docs/implementation-roadmap.md)

| Thư mục | Trách nhiệm |
| --- | --- |
| `android/` | Cấu hình Gradle, manifest và điểm vào ứng dụng Android. |
| `lib/app/` | Khởi tạo ứng dụng, điều hướng và lắp các Provider. |
| `lib/core/` | Cấu hình môi trường, HTTP client, định dạng tiền và ngày giờ, lưu trữ phiên. |
| `lib/design_system/`, `lib/widgets/`, `lib/l10n/` | Token và theme, thành phần giao diện dùng chung, chuỗi tiếng Việt. |
| `lib/features/` | Các phân hệ `auth`, `profile`, `home`, `wallets`, `categories`, `transactions`, `budgets` và `reports`. Mỗi phân hệ có `presentation/` cho màn hình và ViewModel, cùng `data/` khi cần nguồn dữ liệu riêng. Trang chủ dùng các repository hiện có. |
| `assets/fonts/`, `assets/icons/` | Phông chữ và biểu tượng của hệ thống thiết kế. |
| `test/`, `integration_test/` | Kiểm thử Dart/Flutter và luồng tích hợp trên Android. |

Mở thư mục chứa `pubspec.yaml` trong Android Studio với plugin Flutter và Dart. Dự án được khởi tạo bằng Flutter 3.50.1 stable và Dart 3.14.0. Chọn thiết bị Android rồi chạy `lib/main.dart`.
