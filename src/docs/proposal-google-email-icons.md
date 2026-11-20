# Đề xuất bổ sung: thứ tự ví, icon, Google và email

**Trạng thái bước 03:** đã triển khai nền CSDL (migration 004), API health, HTTP contract và worker outbox. Quy ước thứ tự ví là 0, 1, 2, …; Google Sign-In, bộ chọn icon và các luồng phát email nghiệp vụ vẫn chờ bước 04–07. Xem [backend](../backend/README.md) và [báo cáo bước 03](../bugs/TEST-004-step03-foundation.md). Tài liệu này là đầu mối chi tiết cho [kiến trúc hệ thống](final-system-architecture.md), [Flutter](flutter-app-architecture.md), [roadmap](implementation-roadmap.md) và [hướng dẫn cấu hình Google/email](google-email-setup.md).

## 1. Thứ tự ưu tiên ví

`wallets_priority` là **vị trí trong danh sách ví**, số nhỏ được chọn trước. Trong nhóm ví hoạt động của mỗi tài khoản, duy trì thứ tự liên tiếp từ 0; ví ở vị trí 0 là ví mặc định. Truy vấn chọn mặc định theo `wallets_priority ASC, wallets_id ASC`. ID chỉ là tiêu chí phụ để đọc dữ liệu cũ còn trùng thứ tự một cách ổn định, không thay thế việc chuẩn hóa dữ liệu.

Ví đầu tiên nhận vị trí 0; ví mới tiếp theo được thêm cuối danh sách. Khi chọn một ví làm mặc định, đưa ví đó về 0 và dịch các ví còn lại. Khi đổi thứ tự, ngừng sử dụng hoặc kích hoạt lại ví, API cập nhật lại thứ tự trong một giao tác theo tài khoản, có khóa để tránh hai lần cập nhật đồng thời sinh nhiều ví mặc định. Ví kích hoạt lại được thêm cuối danh sách trừ khi người dùng chọn làm mặc định. Ví ngừng hoạt động không tham gia chọn mặc định. Không có ví hoạt động thì yêu cầu tạo/kích hoạt ví trước khi ghi giao dịch.

Ví dụ, A có thứ tự Tiền mặt = 0, Ngân hàng = 1, Ví điện tử = 2. Chọn Ngân hàng làm mặc định cho kết quả Ngân hàng = 0, Tiền mặt = 1, Ví điện tử = 2. Sắp xếp này không thay đổi số dư hay lịch sử.

**Việc cần làm khi lập trình:** đổi chỉ mục/quy tắc đọc DESC cũ, chuẩn hóa seed và dữ liệu hiện có về 0..N−1, thêm kiểm tra không âm, sửa repository và kiểm thử lựa chọn ví. Không đảo chiều đọc trực tiếp rồi coi seed cũ là đã đúng: seed hiện đặt ví A1 ở 10 và A2 ở 0. SQL và kiểm thử hiện tại vẫn mô tả phiên bản trước, chưa được thay đổi trong đợt cập nhật tài liệu này.

## 2. Icon danh mục và loại ví

**Phương án đề xuất chính:** dùng Material Icons đóng gói cùng Flutter. Dự án đã có `uses-material-design: true`, nên không cần thêm gói chỉ để có biểu tượng ăn uống, học tập, lương, ngân hàng hoặc ví. Danh mục chọn icon từ một danh sách do ứng dụng hỗ trợ; API lưu/trả mã ổn định như `restaurant`, `school`, `work`, `account_balance`, `account_balance_wallet`. Flutter ánh xạ mã sang biểu tượng qua danh sách cho phép, có icon thay thế khi mã chưa được hỗ trợ. Không lưu code point phụ thuộc font vào CSDL. [Flutter Icons](https://api.flutter.dev/flutter/material/Icons-class.html)

Với thương hiệu ví điện tử cụ thể, dùng bộ logo SVG/PNG cục bộ được phép sử dụng, lưu trong `assets/icons/` và ghi nguồn/giấy phép. Icon ví chung không được trình bày như logo chính thức của một thương hiệu. Mã như `brand:<ten>` được ánh xạ tới asset đã duyệt; thiếu logo thì hiển thị icon ví chung kèm tên. Giữ nguyên ý nghĩa theo dõi thủ công, không suy diễn thành tích hợp thanh toán.

**Flaticon là phương án thay thế** nếu cần kho icon rộng hơn và có quyền API phù hợp. Khi chọn hướng này, PHP giữ thông tin xác thực, gọi Flaticon, chuẩn hóa metadata và cung cấp danh sách cho Flutter; không nhúng khóa API vào APK. Cần chốt quyền sử dụng, attribution, lưu trữ/cache và hạn mức theo gói trước khi đưa tài nguyên vào sản phẩm. Khi dịch vụ lỗi, bộ chọn vẫn dùng icon cục bộ. Chưa khẳng định API miễn phí hay mọi icon đều được phép phân phối lại. [Tài liệu Flaticon API](https://api.flaticon.com/v3/docs/index.html)

Không cài gói, tải logo hoặc gọi Flaticon ở giai đoạn đề xuất. Khi triển khai, đối chiếu kích thước, màu, nét, nhãn trợ năng và giấy phép với hệ thống thiết kế.

## 3. Đăng ký/đăng nhập bằng Google

Bổ sung phương thức Google cho UC1/UC2 bên cạnh email–mật khẩu. Flutter dùng `google_sign_in`, nhận Google ID token và gửi qua HTTPS đến endpoint đề xuất `POST /api/v1/auth/google`. PHP xác minh token bằng thư viện phù hợp, kiểm tra chữ ký, issuer, audience, hạn dùng; sử dụng `sub` làm định danh Google. Client không được tự quyết định `users_id`, email xác minh hoặc quyền truy cập. Backend cấp token phiên OurBudget và lưu vào `auth_sessions` theo cùng cơ chế đăng nhập thông thường. [Xác minh Google ID token](https://developers.google.com/identity/sign-in/web/backend-auth)

Đề xuất thêm `user_identities` với `identity_id`, `users_id`, `provider`, `provider_subject`, `created_at`; unique `(provider, provider_subject)` ngăn một danh tính Google thuộc nhiều tài khoản. Có thể đặt unique `(users_id, provider)` nếu giới hạn mỗi tài khoản một Google identity trong phiên bản đầu. Trường `provider_subject` chứa `sub`, so sánh chính xác. `users_password` cần cho phép NULL với tài khoản chỉ dùng Google; đường đăng nhập bằng mật khẩu phải từ chối trường hợp không có hash hợp lệ. Không tạo mật khẩu giả cho tài khoản Google.

Nếu identity đã tồn tại, xác nhận tài khoản đang hoạt động rồi tạo phiên. Nếu identity chưa tồn tại và email chưa có trong hệ thống, tạo tài khoản cùng identity trong một giao tác. Nếu email trùng tài khoản hiện có, yêu cầu đăng nhập/xác minh tài khoản hiện hữu rồi mới liên kết Google bằng thao tác có chủ đích; không tự gộp chỉ vì email giống nhau. `sub` là khóa nhận diện lâu dài, email chỉ là thuộc tính liên hệ có thể thay đổi.

Địa chỉ nhận thông báo là email đã đăng ký và xác minh của tài khoản OurBudget. Đề xuất thêm `email_verified_at` và quy trình xác minh email cho tài khoản mật khẩu. Với Google, đánh giá các claim email theo hướng dẫn của Google; email bên thứ ba không thuộc Gmail và không có `hd` cần bước xác minh riêng. Đổi email trong hồ sơ phải xác minh địa chỉ mới trước khi chuyển email tài chính sang đó. Token xác minh email có mục đích riêng, hash, hạn dùng và đánh dấu dùng một lần; không tái sử dụng token khôi phục mật khẩu để xác minh email.

Đăng xuất vẫn thu hồi phiên OurBudget và dọn trạng thái Google phía client theo SDK. Tài khoản chỉ dùng Google được hướng dẫn khôi phục tài khoản Google; việc thêm mật khẩu nội bộ sau này cần luồng xác minh riêng. Phiên tự khôi phục khi mở ứng dụng không được coi là một lần đăng nhập mới để gửi mail.

## 4. Email thông báo

Đề xuất hiểu “cập nhật thu/chi” bao gồm **tạo, sửa và xóa** khoản thu/chi đã commit. Chuyển nội bộ chưa nằm trong nhóm email này; có thể mở rộng sau khi chốt yêu cầu. Các sự kiện và thư dự kiến:

| Sự kiện | Email và điều kiện |
| --- | --- |
| Đăng ký thành công bằng mật khẩu | Thư xác minh đến email đăng ký; thư hoàn tất đăng ký sau khi xác minh thành công |
| Đăng ký thành công bằng Google | Thư chào mừng khi email liên hệ đã xác minh; nếu chưa thì thực hiện luồng xác minh |
| Đăng nhập thành công bằng mật khẩu hoặc Google | Thông báo một lần cho lần cấp phiên chủ động; không gửi khi khôi phục phiên, refresh hoặc đăng nhập thất bại |
| Tạo khoản thu/chi | Thông báo sau commit, cùng một thao tác gửi lại không tạo thêm sự kiện mail |
| Sửa hoặc xóa khoản thu/chi | Thông báo thay đổi đã commit; lưu thông tin cần thiết trước khi xóa dòng giao dịch |

Đăng ký tự cấp phiên chỉ phát sự kiện đăng ký để tránh hai thư cho cùng một hành động. Email xác minh vẫn gửi được tới địa chỉ chưa xác minh; email chứa thông tin tài chính chỉ gửi tới địa chỉ đã xác minh. Các thư bảo mật/đăng nhập trong giai đoạn chưa xác minh chỉ chứa nội dung tối thiểu và lời nhắc xác minh. Không đưa mật khẩu, token phiên, ghi chú riêng hoặc toàn bộ số dư vào mail; thư tài chính đề xuất ghi loại thao tác, số tiền, thời điểm và hướng dẫn mở ứng dụng.

PHP ghi một hàng `email_outbox` trong cùng giao tác với thay đổi nghiệp vụ hoặc cấp phiên. Worker PHP chạy theo lịch lấy hàng chờ và gửi qua SMTP/API của tài khoản hệ thống. Đề xuất các trường tối thiểu gồm `event_id` duy nhất, `users_id`, loại sự kiện, người nhận đã xác minh tại lúc tạo sự kiện, snapshot dữ liệu mẫu thư, `status`, `attempts`, `next_attempt_at`, `sent_at`, lỗi đã lọc thông tin nhạy cảm; việc nhận xử lý cần khóa hoặc thời hạn giữ tác vụ để phục hồi khi worker dừng. Khi gửi, đối chiếu người nhận còn là email đã xác minh hiện hành; hủy tác vụ cũ nếu email đã đổi, không tự chuyển nội dung tài chính sang địa chỉ mới.

Ghi outbox thất bại thì rollback toàn bộ thao tác để không mất sự kiện cần gửi. Lỗi SMTP sau commit giữ nghiệp vụ thành công, lên lịch thử lại có giới hạn và có trạng thái lỗi cuối để quản trị kiểm tra. Không gọi SMTP trong khi giữ khóa ví. API/UI xác nhận giao dịch đã lưu độc lập với việc thư đã tới hộp thư.

Unique sự kiện ngăn tạo trùng outbox khi phát lại yêu cầu; với sửa/xóa, sự kiện gắn với lần thay đổi được commit, không dùng chỉ ID giao dịch làm unique cho mọi lần sửa. SMTP thông thường không bảo đảm gửi đúng một lần khi worker mất phản hồi sau lúc máy chủ mail đã nhận: dùng Message-ID ổn định và dedup phía nhà cung cấp nếu có, ghi rõ khả năng trùng thư hiếm gặp. Kiểm thử mất phản hồi và retry trước khi hứa “không bao giờ trùng email”.

Google Sign-In không cấp quyền gửi email tự động. Tài khoản gửi thư của hệ thống được cấu hình riêng; không xin quyền đọc/gửi Gmail của mọi người dùng. Cho môi trường đồ án, đề xuất Gmail SMTP với App Password nếu tài khoản cho phép. Khi phát hành, đánh giá dịch vụ email giao dịch hoặc SMTP tổ chức và cấu hình domain người gửi theo nhà cung cấp. [Hướng dẫn setup](google-email-setup.md)

## 5. Ảnh hưởng tới dữ liệu và nghiệm thu

Migration `004_step03_foundation.sql` đã bổ sung `user_identities`, `email_outbox`, xác minh email và thứ tự ví mới, đưa schema lên 14 bảng. Bản baseline 001–003 được giữ nguyên để thử nâng cấp; không import lại baseline lên dữ liệu thật. Migration giữ ID, số dư, lịch sử và ánh xạ thứ tự ví. ERD/PDM native vẫn cần đồng bộ theo [metadata MySQL](../database/model-reference.md). Icon tiếp tục sử dụng các cột icon hiện có với quy ước mã đã duyệt.

Các ca nghiệm thu bổ sung gồm vị trí ví 0/1/2 và đổi mặc định đồng thời; icon offline/mã lạ/logo thiếu; hủy Google, token sai audience/hết hạn, trùng email và liên kết trái phép; thư đăng ký/đăng nhập; tạo/sửa/xóa thu chi, rollback không sinh thư, idempotent replay không thêm outbox, lỗi SMTP và worker dừng giữa chừng. Các kiểm thử SQL đã có là kết quả của phiên bản cũ, chưa chứng minh các đề xuất này hoạt động.
