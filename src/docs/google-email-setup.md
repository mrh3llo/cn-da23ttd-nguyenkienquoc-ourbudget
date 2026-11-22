# Hướng dẫn chuẩn bị Google Sign-In và email cho OurBudget

**Cập nhật 21/11/2026:** bạn đã xác nhận hoàn tất OAuth Client và cung cấp Web client ID; ID đã được đưa vào `src/backend/config/example.php` dưới khóa `google_server_client_id`. Backend nền và worker đã có, nhưng endpoint xác minh Google ID token và đăng nhập trên Flutter thuộc bước 04, chưa nghiệm thu OAuth thực tế. Hướng dẫn này dành cho Android Flutter + PHP/PostgreSQL, theo [đề xuất mở rộng](proposal-google-email-icons.md). Tên mục trong Console có thể thay đổi; đối chiếu các nguồn chính thức cuối mỗi phần.

## 1. Thông tin cần chuẩn bị

| Thông tin | Giá trị hoặc cách lấy |
| --- | --- |
| Android package/application ID | Hiện là `com.ourbudget.ourbudget` trong `src/mobile/ourbudget/android/app/build.gradle.kts`; kiểm tra lại nếu đổi trước khi đăng ký OAuth |
| Chứng chỉ ký | SHA-1 của debug, release và Google Play App Signing nếu phân phối qua Play |
| Google Cloud project | Một project phát triển riêng cho OurBudget, do bạn quản lý |
| Email hỗ trợ và developer contact | Email bạn kiểm soát |
| Tài khoản thử | Các tài khoản Google sẽ thử ứng dụng khi consent đang Testing |
| Địa chỉ API | HTTPS của PHP để nhận ID token; không nhập địa chỉ máy chủ cơ sở dữ liệu vào OAuth |

## 2. Tạo project và cấu hình Google Auth Platform

1. Vào [Google Cloud Console](https://console.cloud.google.com/), chọn hoặc tạo project cho OurBudget.
2. Mở **Google Auth Platform**; ở giao diện cũ có thể là **APIs & Services → OAuth consent screen**. Cấu hình tên ứng dụng, email hỗ trợ và contact trong phần Branding.
3. Chọn Audience phù hợp. Ứng dụng dùng tài khoản Gmail cá nhân thường dùng External; Internal chỉ phù hợp phạm vi tổ chức Google Workspace. Trong giai đoạn thử nghiệm, giữ Testing và thêm tài khoản thử khi Console yêu cầu.
4. Chỉ yêu cầu danh tính cơ bản OpenID Connect/email/profile cho đăng nhập. Không thêm scope Gmail hoặc Drive để gửi thông báo hệ thống.
5. Khi phát hành, hoàn thiện thông tin thương hiệu, domain/chính sách quyền riêng tư và các yêu cầu xác minh mà Console áp dụng cho cấu hình thực tế. Không giả định cấu hình Testing là cấu hình phát hành.

Tham khảo [Google OAuth setup](https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid) và [codelab Android chính thức](https://codelabs.developers.google.com/sign-in-with-google-android).

## 3. Đăng ký Android OAuth client

Từ **Clients → Create client**, chọn loại **Android**, nhập package chính xác và SHA-1 của chứng chỉ ký bản ứng dụng sẽ chạy. Tạo client tương ứng cho mỗi cặp package/chứng chỉ cần hỗ trợ trong cùng project.

Khi môi trường Gradle đã sẵn sàng, lấy fingerprint từ terminal trong Android Studio tại thư mục Android của dự án:

```powershell
cd src/mobile/ourbudget/android
.\gradlew.bat signingReport
```

Nếu Gradle wrapper chưa được tạo trên checkout mới, khởi tạo môi trường Flutter theo hướng dẫn dự án trước, hoặc dùng `keytool -list -v` với đúng keystore để xem SHA-1. Không gửi keystore hay mật khẩu ký ứng dụng vào chat/Git. Bản hiện tại đang ký cấu hình release bằng debug key; khi cấu hình release key thật, phải đăng ký fingerprint mới. Bản cài từ Google Play dùng chứng chỉ App Signing, có thể khác upload key.

## 4. Tạo Web OAuth client cho backend

Trong cùng project, tạo OAuth client loại **Web application** và đặt tên dễ nhận biết, ví dụ `OurBudget PHP Backend`. Lưu **Web client ID** để sau này truyền làm `serverClientId` khi khởi tạo Google Sign-In trên Android, đồng thời cấu hình danh sách audience được PHP chấp nhận.

Web client ở đây đại diện cho backend nhận ID token. Luồng native Android gửi ID token trực tiếp đến PHP không sử dụng browser callback của OurBudget; không tự thêm URL `/auth/google` làm redirect URI. Nếu sau này bổ sung web hoặc authorization-code flow, cấu hình redirect riêng theo đúng flow đó. Android client ID và Web client ID không thay thế cho nhau.

Phương án dự kiến không cần Firebase: dùng `google_sign_in` và truyền Web client ID theo hướng dẫn plugin. Nếu chọn cấu hình bằng `google-services.json` ở giai đoạn triển khai, phải bảo đảm có Web OAuth client đúng project. Không sao chép tutorial SDK Google Sign-In Android cũ vào phiên bản plugin mới. [Hướng dẫn Flutter Android](https://pub.dev/packages/google_sign_in_android)

Client ID là định danh cấu hình, không phải mật khẩu. Nếu Console tạo client secret, giữ ở backend khi flow thực sự cần; không đưa secret vào APK. Luồng chỉ xác minh ID token không cần client secret để kiểm tra chữ ký.

## 5. Cấu hình ứng dụng và PHP khi bắt đầu lập trình

Chưa thêm dependency hoặc biến môi trường vào mã ở đợt tài liệu này. Agent triển khai sau cần ghi rõ phiên bản `google_sign_in` tương thích SDK, truyền Web client ID ở Flutter, và cấu hình backend theo bảng:

| Cấu hình đề xuất | Nơi sử dụng |
| --- | --- |
| `GOOGLE_SERVER_CLIENT_ID` | Flutter và cấu hình audience PHP; giá trị Web client ID ở bước 4 |
| `API_BASE_URL` | Flutter gọi backend HTTPS như kiến trúc hiện tại |
| Google identity và phiên OurBudget | Backend xác minh token, tra `sub`, liên kết/tạo tài khoản rồi cấp phiên nội bộ |

PHP phải kiểm tra chữ ký, `iss`, `aud`, `exp`, dùng `sub` để định danh, không tin email/ID do client tự gửi. Trùng email với tài khoản có sẵn phải đi qua xác minh và liên kết tài khoản, không tự gộp. Dùng thư viện xác minh thay vì tự giải mã payload rồi coi token là hợp lệ. [Google backend authentication](https://developers.google.com/identity/sign-in/web/backend-auth)

## 6. Cấu hình gửi email thử bằng Gmail

Chuẩn bị một hộp thư hệ thống do bạn quản lý, ví dụ tài khoản chuyên dùng cho đồ án. Người dùng ứng dụng chỉ nhận thư tại email đăng ký; họ không phải cấp quyền Gmail cho ứng dụng.

1. Trong tài khoản gửi thư, bật **2-Step Verification**.
2. Mở mục [App passwords](https://myaccount.google.com/apppasswords), tạo mật khẩu ứng dụng cho backend OurBudget nếu tài khoản có tính năng này. Đây là mật khẩu riêng cho SMTP, không phải mật khẩu Google thông thường.
3. Nếu không thấy App passwords, kiểm tra chính sách tổ chức, Advanced Protection hoặc cách cấu hình xác minh hai bước. Không tắt bảo vệ tài khoản để tìm “less secure apps”; chọn SMTP/API khác hoặc OAuth2 cho tài khoản gửi thư nếu cần.
4. Sau khi backend được triển khai, đặt cấu hình sau trong môi trường máy chủ; không lưu mật khẩu thật trong repository.

| Cấu hình đề xuất | Giá trị |
| --- | --- |
| `MAIL_HOST` | `smtp.gmail.com` |
| `MAIL_PORT` | `587` |
| `MAIL_ENCRYPTION` | `STARTTLS` |
| `MAIL_USERNAME` | Địa chỉ Gmail của hệ thống |
| `MAIL_PASSWORD` | App Password vừa tạo |
| `MAIL_FROM_ADDRESS` | Cùng địa chỉ gửi, hoặc alias đã được xác minh và cho phép |
| `MAIL_FROM_NAME` | `OurBudget` |

Phương án khác là SMTP cổng 465 với TLS ngay khi kết nối; không ghép cổng 465 với cấu hình STARTTLS của cổng 587. App Password có thể bị thu hồi khi thay đổi mật khẩu tài khoản Google, khi đó cập nhật bí mật máy chủ. [App Passwords của Google](https://support.google.com/mail/answer/185833?hl=en) · [Gmail SMTP](https://developers.google.com/workspace/gmail/imap/imap-smtp)

Không cần bật Gmail API cho phương án SMTP + App Password. Đăng nhập Google và gửi email là hai cấu hình độc lập. Nếu tài khoản không hỗ trợ App Password và chọn Gmail API/OAuth2 thay thế, cần một thiết kế cấp quyền riêng cho tài khoản gửi hệ thống; không xin scope Gmail trên luồng đăng nhập của mọi người dùng.

## 7. Checklist xác nhận sau khi có mã triển khai

- Đăng ký/đăng nhập Google thành công trên bản debug và bản ký release; hủy chọn tài khoản không bị coi là lỗi mật khẩu.
- Token sai audience, hết hạn hoặc sửa nội dung bị từ chối; email trùng không tự chiếm tài khoản cũ.
- Tài khoản Google mới nhận thư đăng ký; đăng nhập chủ động nhận thư thông báo; mở lại ứng dụng với phiên cũ không gửi thêm.
- Email nhận thông báo tài chính đã xác minh; tạo/sửa/xóa khoản thu chi chỉ tạo sự kiện sau commit; rollback không có thư.
- Retry cùng thao tác không tạo thêm queue tệp; khi SMTP tạm lỗi, giao dịch vẫn tồn tại và worker thử lại.
- Kiểm tra Spam, địa chỉ From, cấu hình người gửi và trạng thái queue tệp. Giới hạn gửi và khả năng chuyển phát phụ thuộc tài khoản/nhà cung cấp; không hứa thư tới tức thì hoặc vô hạn.

Lỗi Google thường cần kiểm tra package/SHA-1, đúng Web client ID, project và tài khoản thử. Lỗi SMTP cần kiểm tra App Password, TLS/cổng và chính sách tài khoản. Đây là checklist tương lai, chưa phải kết quả kiểm thử đã đạt.

## Cấu hình hiện hành trên máy

Android package: com.ourbudget.ourbudget. Web client ID: 171608086306-eov7trctrio9s8jpof6g8bu2k8qemg4n.apps.googleusercontent.com. Android OAuth client phải khớp package và SHA-1 của chứng chỉ ký APK (release có thể khác debug). Không đặt client secret hoặc khóa service account trong Flutter.

Người gửi và nhận thử được tác giả chọn là quocmrh3llo@gmail.com. Service account không có hộp thư Gmail cá nhân. Dùng smtp.gmail.com:587, TLS, username là Gmail và App Password trong backend/config/local.php. Không đưa mật khẩu vào chat/Git. Gmail đã chấp nhận thư kiểm tra trong phiên này; việc thư vào Inbox cần người nhận xác nhận.

App dùng mã 64 ký tự trong email để xác minh/reset, không cần URL HTTPS công khai ở bước thử cục bộ. Chạy php src/backend/bin/mail-worker.php; cần Task Scheduler/cron để xử lý tự động lâu dài. Hash mã và danh tính Google nằm trong users, không có bảng bổ sung. [Backend](../backend/README.md) mô tả giới hạn queue.
