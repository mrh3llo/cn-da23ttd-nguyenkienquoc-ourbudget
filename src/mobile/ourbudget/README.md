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

## Trạng thái bước 04

App mặc định dùng AuthController/Provider, ApiClient và SecureTokenStore để đăng nhập, khôi phục phiên, hồ sơ, Google và xác minh/reset mật khẩu. Dữ liệu demo chỉ bật bằng `--dart-define=DEMO_MODE=true`; các chức năng tài chính API thuộc bước 05–09. Chạy backend trước, cấu hình API_BASE_URL; hướng dẫn tại [cài Android](../../docs/install-ourbudget-android.md).

Kiểm thử máy chủ thử riêng bằng `flutter test integration_test/auth_flow_test.dart integration_test/backend_connection_test.dart -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:18080`. Server này phải dùng DB thử và mail_transport=file. Auth test kiểm tra HTTP thật cùng secure storage Android; không thay thế việc bấm Google Sign-In với tài khoản thật. [Báo cáo kiểm thử](../../bugs/TEST-005-step04-report-entities.md).
