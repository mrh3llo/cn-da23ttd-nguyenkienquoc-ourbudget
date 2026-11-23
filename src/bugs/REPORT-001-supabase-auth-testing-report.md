# Báo cáo kiểm tra Supabase và xác thực OurBudget

**Ngày:** 23/11/2026

**Phạm vi:** Kiểm tra kết nối Supabase, hoàn thiện luồng xác thực ứng dụng, xác minh bằng các kiểm thử khả thi trong môi trường hiện tại. Step 5 chưa được triển khai do cổng xác minh xác thực thật chưa đạt.

## 1. Kết luận

- **Supabase:** Kết nối dự án hoạt động qua Supabase MCP và Auth REST API. Migration liên kết người dùng Supabase với hồ sơ OurBudget đã được áp dụng.
- **Ứng dụng:** Đã tích hợp Supabase Auth cho email/mật khẩu, đăng ký, khôi phục mật khẩu và đăng nhập Google theo OAuth redirect; trạng thái được quản lý qua Provider, phiên được lưu trong secure storage.
- **Kiểm thử thật:** Chưa xác minh đăng nhập thành công, xác minh email, đặt lại mật khẩu qua email, Google consent/callback hoàn tất, hoặc lưu phiên sau khi khởi động lại trên điện thoại. Không tạo tài khoản thật hay gửi thư trong đợt kiểm tra này.
- **Step 5:** Đã xác định đúng phạm vi từ roadmap nhưng chưa bắt đầu. Chưa thể khẳng định các điều kiện tiên quyết xác thực đã hoàn tất vì chưa có kiểm thử thiết bị và tài khoản thật.

## 2. Cấu hình và kết nối Supabase

Backend đọc `SUPABASE_URL` và `SUPABASE_PUBLISHABLE_KEY` từ `src/backend/.env` hoặc biến môi trường; cấu hình mẫu được bổ sung tại `src/backend/config/example.php`. Flutter nhận URL và publishable key qua `String.fromEnvironment` và không chứa khóa bí mật. Supabase secret key và thông tin xác thực PostgreSQL không được đưa vào ứng dụng di động.

Kết nối tới dự án Supabase được xác nhận bằng Supabase MCP. Cơ sở dữ liệu có bảy bảng ứng dụng: `users`, `wallet_categories`, `income_categories`, `outcome_categories`, `wallets`, `transactions`, `budgets`. RLS đang bật trên các bảng. `users` hiện có 0 hồ sơ ứng dụng, do đó chưa có bản ghi tài khoản thật để kiểm tra quy trình đồng bộ end-to-end.

PHP runtime hiện tại không có `pdo_pgsql`. Vì vậy backend PHP không thể mở kết nối PostgreSQL trực tiếp trong máy này; điều này khác với việc Supabase/MCP hoạt động. Backend cũng cần cURL để gọi Supabase Auth REST API. Không thể xác nhận kết nối trực tiếp từ PHP đến DB cho đến khi môi trường triển khai có driver PostgreSQL phù hợp hoặc backend dùng API thay cho kết nối PDO.

Các thử nghiệm Auth REST không tạo tài khoản:

| Kiểm tra | Kết quả thực tế | Diễn giải |
|---|---|---|
| Đăng nhập bằng địa chỉ `.invalid` và mật khẩu giả | HTTP 400 | Supabase Auth endpoint phản hồi; đây là kết quả dự kiến cho thông tin không hợp lệ, không phải kiểm thử đăng nhập thành công. |
| Yêu cầu khôi phục cho địa chỉ giả chưa đăng ký | HTTP 200 | Phù hợp với phản hồi chống dò tìm tài khoản. Không chứng minh email đã được gửi. |
| Khởi tạo `/authorize?provider=google` với redirect OurBudget | HTTP 302 | Google provider/đường dẫn authorize được nhận và chuyển hướng; chưa hoàn tất OAuth consent hoặc callback. |

Không in giá trị `.env`, token, khóa hoặc nội dung tệp bí mật vào báo cáo. Thư mục `src/mobile/storage/secret/` không bị chỉnh sửa; cần duy trì ignore trong Git.

## 3. Thay đổi schema phục vụ xác thực

Migration `src/supabase/migrations/20261123061525_auth_user_link.sql` bổ sung thuộc tính nullable và unique `users.users_supabase_uid uuid` để liên kết hồ sơ với `auth.users.id`; không tạo bảng mới và không khôi phục `transactions_type`.

Migration tạo schema riêng `ourbudget_private` với quyền truy cập bị thu hồi khỏi `PUBLIC`, `anon`, `authenticated`, cùng trigger function bảo mật với `search_path` rỗng. Trigger sau khi thêm hoặc cập nhật người dùng Auth ghép hồ sơ theo UID/email đã xác minh hoặc tạo hồ sơ OurBudget, đồng bộ email/tên/avatar/trạng thái xác minh. Hai trigger Auth đã được kiểm tra trên dự án sau khi áp dụng migration. Chưa kiểm tra trigger bằng tạo tài khoản thật; bảng hồ sơ vẫn chưa có người dùng.

## 4. Xác thực Flutter và backend

Flutter dùng `supabase_flutter` cho đăng nhập mật khẩu, đăng ký, gửi email khôi phục, cập nhật mật khẩu và OAuth Google qua trình duyệt/hệ điều hành. URI callback cấu hình là `ourbudget://auth-callback`, được khai báo cho Android và iOS. Dữ liệu phiên Supabase dùng `flutter_secure_storage`. `AuthController` tiếp nhận sự kiện Auth, khôi phục trạng thái, điều phối trạng thái đăng nhập/đăng xuất/khôi phục mật khẩu và cung cấp token cho `ApiClient`. `OurBudgetApp` điều hướng theo trạng thái xác thực; biểu mẫu có kiểm tra email và độ dài mật khẩu, phản hồi lỗi/thành công.

Backend tiếp nhận bearer token Supabase và xác minh token bằng endpoint `/auth/v1/user` với publishable key; tiếp đó ánh xạ danh tính vào hồ sơ hiện có qua UID và yêu cầu email đã xác minh. Luồng token cũ 64 ký tự vẫn được giữ để tương thích. URL backend dùng cho xác minh Supabase hiện bắt buộc HTTPS.

Google Sign-In dùng OAuth hosted flow của Supabase; không đưa client secret vào Flutter. Cần cấu hình Google OAuth redirect URI trỏ về callback Supabase trong Google Cloud, đồng thời cho phép `ourbudget://auth-callback` trong Redirect URLs của Supabase. Tệp bí mật đã có trong thư mục secret nhưng chưa được dùng để nhúng secret vào ứng dụng.

## 5. Kết quả kiểm thử

### 5.1 Kiểm tra mã nguồn và kiểm thử tự động

| Kiểm tra | Kết quả |
|---|---|
| PHP syntax lint trên `SupabaseIdentity.php`, `AuthService.php`, `Environment.php`, `public/index.php` | **Đạt** ở lần chạy gần nhất; sau đó thêm điều kiện HTTPS vào `SupabaseIdentity.php` và lint lại **đạt**. |
| Flutter analyze | **Đạt ở lần chạy trước** sau phần triển khai chính. Không chạy lại được trong lượt tổng kết này vì `flutter` không có trong PATH của shell hiện tại. |
| Flutter unit/widget suite | **Đạt ở lần chạy trước** trước khi thêm `test/auth_widget_flow_test.dart`. Không chạy lại được do Flutter SDK không hiện diện trong PATH lượt này. Hai widget test mới vì thế **chưa được xác minh**. |
| Android debug APK | **Build thành công ở lần chạy trước**, APK nằm tại `src/mobile/ourbudget/build/app/outputs/flutter-apk/app-debug.apk`. Không build lại được trong lượt tổng kết này. |
| Integration test trên thiết bị | **Chưa chạy**: môi trường chỉ phát hiện Windows/Edge, không có Android emulator hoặc điện thoại. |
| PHP kết nối PostgreSQL trực tiếp | **Chưa thể kiểm tra**: PHP thiếu extension `pdo_pgsql`. |
| `git diff --check` | **Đạt**, không có lỗi whitespace; Git có cảnh báo chuẩn hóa LF/CRLF. |

### 5.2 Các ca kiểm thử nghiệp vụ

| Ca kiểm thử | Kết quả hiện tại |
|---|---|
| Email/mật khẩu hợp lệ | **Chưa hoàn thành** — chưa có thông tin tài khoản thật để đăng nhập. |
| Sai mật khẩu | Endpoint REST với tài khoản giả trả HTTP 400; kiểm tra giao diện/provider dùng fake gateway có ca lỗi thông tin đăng nhập. Chưa chạy với tài khoản thật. |
| Đăng ký hợp lệ và email xác minh | **Chưa hoàn thành** — không tạo tài khoản hoặc gửi email thật trong lần này. Unit test fake kiểm tra trạng thái chờ xác minh. |
| Đăng ký trùng/không hợp lệ | Có ca fake gateway cho email trùng và kiểm tra validate biểu mẫu; chưa gửi yêu cầu đăng ký tới tài khoản Supabase thật. |
| Quên mật khẩu / đặt lại qua deep link | Endpoint yêu cầu khôi phục cho email giả phản hồi HTTP 200; ca fake kiểm tra sự kiện recovery/reset. **Chưa xác minh email hoặc deep link thật.** |
| Google Sign-In thành công | **Chưa hoàn thành** — chỉ xác nhận authorize endpoint chuyển hướng HTTP 302; chưa cấp consent/callback thật. |
| Google hủy hoặc lỗi | Ca fake gateway kiểm tra hủy và giữ màn hình xác thực; chưa kiểm tra hủy ở trình duyệt thiết bị. |
| Đăng xuất | Ca fake gateway kiểm tra xóa trạng thái và quay về màn hình đăng nhập; chưa kiểm tra phiên Supabase thật. |
| Khôi phục phiên sau khởi động lại | Ca controller fake kiểm tra khôi phục và token bearer; **chưa xác minh secure storage trên thiết bị**. |
| Bảo vệ điều hướng | Widget test mới được thêm cho route đăng xuất/đăng nhập; chưa chạy lại do thiếu Flutter trong PATH. |

## 6. Tệp thay đổi

**Backend:** `src/backend/config/example.php`, `src/backend/public/index.php`, `src/backend/src/AuthService.php`, `src/backend/src/Environment.php`, `src/backend/src/bootstrap.php`, mới `src/backend/src/SupabaseIdentity.php`.

**Flutter:** `src/mobile/ourbudget/pubspec.yaml`, `pubspec.lock`, `lib/main.dart`, `lib/app/ourbudget_app.dart`, `lib/features/auth/data/auth_repository.dart`, `lib/features/auth/presentation/auth_controller.dart`, `lib/features/auth/presentation/auth_page.dart`, `lib/features/profile/presentation/profile_page.dart`, Android `AndroidManifest.xml` và `gradle.properties`, iOS `Info.plist`, `test/auth_controller_test.dart`, `test/auth_branding_test.dart`, mới `test/auth_widget_flow_test.dart`, `integration_test/auth_flow_test.dart`.

**Supabase:** mới `src/supabase/migrations/20261123061525_auth_user_link.sql` (đã áp dụng lên dự án được kết nối).

Các tài liệu Word đang có thay đổi/xóa và một tệp lock trong `thesis/doc/` là thay đổi tồn tại riêng trong working tree; không thuộc triển khai xác thực này và không được chỉnh sửa trong công việc này.

## 7. Step 5 theo roadmap

Roadmap tại `src/docs/implementation-roadmap.md` xác định **Bước 05: Nguồn tiền và danh mục · UC6–UC9, UC11–UC14**. Mục tiêu là hoàn thiện CRUD/list ví, số dư đầu kỳ và điều chỉnh số dư trong cùng giao dịch; đảm bảo ví mặc định có ưu tiên 0 và chuẩn hóa thứ tự; quản lý danh mục thu/chi hệ thống chỉ đọc và danh mục riêng; dùng chung repository cho danh sách/chọn nhanh; giữ nhãn lịch sử khi ngừng sử dụng mục đang được tham chiếu; kiểm tra cách ly dữ liệu giữa tài khoản.

**Tiến độ Step 5: Chưa bắt đầu (0%).** Đây là chủ ý theo điều kiện người dùng đặt ra: chưa chuyển bước cho đến khi các chức năng xác thực quan trọng được triển khai và xác minh. Chưa có đăng nhập thành công, đăng ký/email verification, khôi phục mật khẩu thật, Google consent/callback, hoặc phục hồi phiên trên điện thoại được thực thi. Ngoài ra PHP backend chưa có `pdo_pgsql` để xác nhận truy cập DB.

## 8. Việc cần làm tiếp theo

1. Cài/đưa Flutter SDK vào PATH, chạy lại `flutter analyze`, `flutter test`, build APK và kiểm tra hai widget test mới.
2. Bật extension `pdo_pgsql` trong PHP deployment/local runtime hoặc xác định backend kết nối PostgreSQL qua cơ chế phù hợp; sau đó kiểm tra endpoint backend với token Supabase thực.
3. Trên thiết bị Android, xác minh email đăng ký, đăng nhập/đăng xuất, khôi phục phiên sau khởi động lại và password recovery deep link.
4. Hoàn tất kiểm tra OAuth Google trên thiết bị với redirect URI/callback đã cấu hình; kiểm tra cả consent thành công và hủy.
5. Sau khi các ca bắt buộc trên đạt, rà soát các lỗi còn lại rồi mới bắt đầu Step 5 theo đúng roadmap.
