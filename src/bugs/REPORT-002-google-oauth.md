# Báo cáo điều tra Google Sign-In OurBudget

**Ngày:** 23/11/2026

**Phạm vi:** Luồng Google OAuth, callback di động, đổi PKCE code thành phiên Supabase, Provider và điều hướng.

## Kết luận

Mã ứng dụng đã gửi một `redirectTo` riêng, nhưng URI trước đây dùng scheme chung `ourbudget://auth-callback`. Supabase chuyển về `http://localhost:3000/?code=…` khi redirect ứng dụng không nằm trong allow-list (hoặc không được chấp nhận), và dùng Site URL làm địa chỉ dự phòng. Vì vậy dấu hiệu phù hợp nhất là cấu hình **Authentication → URL Configuration → Redirect URLs** chưa cho phép URI di động đang được ứng dụng yêu cầu. Không thể đọc trực tiếp cấu hình Dashboard trong phiên này để xác nhận danh sách hiện tại.

Đã đổi callback sang scheme duy nhất theo Android applicationId hiện có: `com.ourbudget.ourbudget://auth-callback`; đồng bộ giá trị ở Dart, Android và iOS. Bản app mới vẫn cần URI này được thêm thủ công vào Supabase Redirect URLs trước khi thử lại.

## Luồng sau thay đổi

Ứng dụng gọi `signInWithOAuth` cho Google, truyền callback `com.ourbudget.ourbudget://auth-callback`, dùng PKCE và mở trình duyệt ngoài. Supabase Flutter 2.18.3 tự đăng ký listener `app_links`, nhận callback có tham số `code`, gọi `getSessionFromUrl` để đổi code thành session, rồi phát sự kiện `signedIn`. `AuthController` đang lắng nghe stream Auth; `OurBudgetApp` chọn `MainNavigationShell` khi trạng thái là `signedIn`. Token phiên tiếp tục được lưu bằng `flutter_secure_storage`.

Việc xử lý callback đã có sẵn trong SDK và được bật tường minh bằng `detectSessionInUri: true`; không thêm cơ chế đổi code riêng hoặc bỏ kiểm tra PKCE. Tài liệu SDK xác nhận native callback cần khai báo trong Additional Redirect URLs và manifest theo scheme/host. [Supabase: Native Mobile Deep Linking](https://supabase.com/docs/guides/auth/native-mobile-deep-linking), [Supabase: Redirect URLs](https://supabase.com/docs/guides/auth/redirect-urls).

## Thay đổi mã nguồn

- `src/mobile/ourbudget/lib/features/auth/data/auth_repository.dart`: thay callback bằng `com.ourbudget.ourbudget://auth-callback`; mở Google sign-in và liên kết Google bằng trình duyệt ngoài.
- `src/mobile/ourbudget/lib/main.dart`: bật rõ `detectSessionInUri` trong khi giữ PKCE và secure storage.
- `src/mobile/ourbudget/android/app/src/main/AndroidManifest.xml`: intent filter nhận scheme mới và host `auth-callback`; applicationId vẫn là `com.ourbudget.ourbudget`.
- `src/mobile/ourbudget/ios/Runner/Info.plist`: URL scheme đồng bộ với Android và Dart.
- `src/mobile/ourbudget/test/auth_controller_test.dart`: kiểm tra callback chuẩn; các ca controller hiện hữu kiểm tra callback đăng nhập, hủy Google, đăng xuất, khôi phục phiên và đăng nhập email/mật khẩu bằng gateway giả.
- `src/mobile/ourbudget/test/auth_widget_flow_test.dart`: kiểm tra màn hình đăng nhập khi chưa xác thực, màn hình chính sau callback sign-in và quay lại đăng nhập sau logout.

## Cấu hình Dashboard bắt buộc

### Supabase → Authentication → URL Configuration

| Trường | Giá trị |
|---|---|
| **Additional Redirect URLs** | `com.ourbudget.ourbudget://auth-callback` |
| **Site URL** | Nếu ứng dụng chỉ có mobile client, đặt `com.ourbudget.ourbudget://auth-callback` để URL dự phòng không còn là localhost. Nếu có website OurBudget đang hoạt động, dùng URL HTTPS của website làm Site URL và vẫn giữ URI di động ở Additional Redirect URLs. |

Xóa hoặc giữ `http://localhost:3000` chỉ khi còn dùng web development. Với bản mobile, không dùng nó làm Site URL production. Redirect URLs hỗ trợ deep link và phải khớp URI mà client gửi. Site URL là redirect mặc định khi không có `redirectTo` hợp lệ.

### Supabase → Authentication → Providers → Google

Giữ Google bật và điền **OAuth Web Client ID** cùng **Client Secret** được tạo cho Google provider trong Supabase. Không đưa Client Secret vào Flutter.

### Google Cloud Console → OAuth 2.0 Client → Authorized redirect URIs

Thêm chính xác:

```text
https://ohztwpsabwfhovrcvxnq.supabase.co/auth/v1/callback
```

Đây là **Google → Supabase OAuth callback**. Nó khác với `com.ourbudget.ourbudget://auth-callback`, là **Supabase → OurBudget mobile callback**. Không nhập deep link mobile vào Google Authorized redirect URIs. [Supabase: Google Auth](https://supabase.com/docs/guides/auth/social-login/auth-google).

## Kết quả kiểm tra

| Kiểm tra | Kết quả |
|---|---|
| So khớp scheme trong Dart, Android và iOS với package Android `com.ourbudget.ourbudget` | Đạt qua rà soát mã nguồn |
| `flutter analyze --no-pub` | Đạt, không có lỗi phân tích |
| `flutter test test/auth_controller_test.dart` | Đạt; gồm các ca fake cho Google callback/cancel, phiên, logout và email/mật khẩu |
| `flutter test test/auth_branding_test.dart` | Đạt |
| `flutter test` toàn bộ | Đạt. Hai widget test cũng chạy qua; assertion ban đầu đếm cả tiêu đề và nút cùng nhãn đã được đổi sang kiểm tra widget màn hình. |
| `flutter analyze --no-pub` | Đạt, không có lỗi phân tích |
| `flutter build apk --debug` | Đạt; APK được tạo tại `src/mobile/ourbudget/build/app/outputs/flutter-apk/app-debug.apk` |
| OAuth thật, đổi code và khôi phục phiên trên điện thoại | Chưa kiểm chứng; không có thiết bị Android/iOS khả dụng trong phiên này |
| Supabase Dashboard Google/URL settings | Chưa đọc được từ phiên này; phải cập nhật và xác minh thủ công theo bảng trên |

Do không chạy trên thiết bị và chưa xác nhận Dashboard, **chưa kết luận Google Sign-In đã hoạt động end-to-end**. Chưa chuyển sang Step 5.

## Hướng dẫn xác minh trên điện thoại

1. Trong Supabase URL Configuration, thêm `com.ourbudget.ourbudget://auth-callback` vào Additional Redirect URLs; đặt Site URL theo hướng dẫn trên để bỏ fallback localhost.
2. Kiểm tra Google provider bật và Client ID/Secret thuộc OAuth Web client. Trong Google Cloud, thêm URI Supabase `/auth/v1/callback` vào Authorized redirect URIs.
3. Cài bản APK mới, vì bản đã cài trước đó đăng ký scheme cũ:

   ```powershell
   adb install -r src/mobile/ourbudget/build/app/outputs/flutter-apk/app-debug.apk
   ```

4. Nhấn **Tiếp tục với Google**, chọn tài khoản và chấp thuận. Trình duyệt phải đóng/chuyển về OurBudget, ứng dụng hiện màn hình chính đã xác thực; không còn mở localhost.
5. Đóng hẳn và mở lại app để kiểm tra khôi phục phiên. Đăng xuất rồi thử Google lần nữa; đồng thời thử hủy màn hình chọn tài khoản.
6. Nếu vẫn về localhost, kiểm tra Redirect URLs có đúng từng ký tự và không bị khoảng trắng; xác minh Google Authorized redirect URI vẫn là URL Supabase (không phải deep link). Không chia sẻ URL chứa `code`, access token hoặc refresh token khi báo lỗi.

**Giới hạn còn lại:** chưa xác minh được cấu hình Dashboard hay trải nghiệm Google OAuth thật trên thiết bị. Test tự động chỉ dùng fake gateway cho callback/trạng thái, không thay thế OAuth consent thật.
