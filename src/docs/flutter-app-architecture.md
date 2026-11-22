# Kiến trúc và hướng dẫn triển khai ứng dụng Flutter OurBudget

> Chốt ngày 21/11/2026: không thêm thực thể ngoài Word. [Đối chiếu bước 03–04](report-alignment-step03-step04.md) thay thế các đề xuất cũ về bảng kỹ thuật; chỉ bổ sung thuộc tính, dùng queue tệp và một phiên trên mỗi tài khoản.


Đề xuất triển khai một ứng dụng Flutter/Dart dành cho Android, mở và chạy từ Android Studio. Tổ chức giao diện theo tính năng, dùng Provider với ChangeNotifier để quản lý trạng thái và gọi RESTful API PHP qua HTTPS/JSON. API xác nhận các thay đổi tài chính và cung cấp số liệu dùng cho ví, ngân sách và báo cáo. Phạm vi nghiệp vụ là UC1–UC24. Phiên bản đầu ghi chép nguồn tiền thủ công, còn ảnh hóa đơn thuộc hướng phát triển sau. [Kiến trúc hệ thống đã chốt](final-system-architecture.md) · [Đặc tả use-case](use-case-diagram.md)

## 1. Dự án trong Android Studio

Đặt dự án tại `src/mobile/ourbudget/`. Trong Android Studio, mở thư mục có `pubspec.yaml` như dự án Flutter. Thư mục `android/` chứa cấu hình Gradle, manifest và phần tích hợp Android. Mã giao diện và nghiệp vụ phía ứng dụng nằm trong `lib/`. Thiết lập Flutter SDK, plugin Flutter/Dart, Android SDK và thiết bị giả lập hoặc thiết bị thật. Kiểm tra môi trường bằng `flutter doctor` và chọn thiết bị trong cấu hình chạy Flutter. [Hướng dẫn Flutter trong Android Studio](https://docs.flutter.dev/tools/android-studio)

| Đường dẫn trong dự án | Trách nhiệm |
| --- | --- |
| `pubspec.yaml`, `pubspec.lock` | Khai báo phiên bản SDK, phụ thuộc, font và tài nguyên. Lưu lockfile của ứng dụng trong Git. |
| `android/` | Cấu hình ứng dụng Android, quyền mạng, cấu hình mạng lúc phát triển nếu cần. |
| `lib/main.dart`, `lib/app/` | Khởi tạo cấu hình, lắp các Provider, thiết lập theme, điều hướng và cổng xác thực. |
| `lib/core/config/`, `lib/core/network/` | Đọc cấu hình môi trường, dùng chung HTTP client, timeout, xử lý phản hồi và ánh xạ lỗi. |
| `lib/core/format/`, `lib/core/session/` | Chuyển đổi số tiền và thời gian. Đọc, ghi và xóa token trong vùng lưu trữ bảo mật. |
| `lib/design_system/`, `lib/widgets/` | Token và theme tập trung trong `design_system/`. Các widget tái sử dụng theo quy chuẩn repo nằm trong `widgets/`. |
| `lib/features/` | Các thư mục `auth/`, `profile/`, `home/`, `wallets/`, `categories/`, `transactions/`, `budgets/`, `reports/`. Mỗi phân hệ giữ màn hình và ViewModel trong `presentation/`, repository, dịch vụ và DTO trong `data/` khi có nhu cầu. Trang chủ dùng các repository hiện có. Chuyển tiền thuộc phân hệ nguồn tiền. |
| `assets/fonts/`, `assets/icons/`, `lib/l10n/` | Font Inter, biểu tượng dùng chung từ thiết kế và chuỗi giao diện tiếng Việt. |
| `test/`, `integration_test/` | Kiểm thử định dạng, giải mã API, ViewModel, widget và các luồng chạy trên Android. |

Widget đọc trạng thái và gọi hành động trên ViewModel. ViewModel dùng repository để tải dữ liệu hoặc lưu thao tác. Repository chuyển đổi DTO và quản lý dữ liệu dùng chung theo phiên. Dịch vụ API quản lý đường dẫn, tham số và kết nối HTTP. Khởi tạo các phụ thuộc tại `app/` và truyền qua constructor hoặc Provider để thay bằng nguồn dữ liệu giả trong kiểm thử. Một màn hình chỉ cần tách thêm lớp khi nghiệp vụ của màn hình đó có nhu cầu rõ ràng. [Hướng dẫn kiến trúc Flutter](https://docs.flutter.dev/app-architecture/guide) · [Ví dụ Flutter dùng Provider](https://docs.flutter.dev/app-architecture/case-study)

Dùng một cấu hình `API_BASE_URL` theo môi trường qua tham số `--dart-define` của cấu hình chạy Flutter. Quy ước giá trị này là địa chỉ gốc của API và thêm tiền tố `/api/v1` ở một nơi trong client. Android Emulator dùng `10.0.2.2` để truy cập dịch vụ trên loopback của máy phát triển. Thiết bị thật dùng địa chỉ máy chủ mà thiết bị có thể truy cập. Khi cần dùng chứng chỉ thử nghiệm hoặc HTTP cục bộ, giới hạn ngoại lệ vào bản debug và điểm kết nối phát triển. Bản phát hành dùng HTTPS và xác minh chứng chỉ bình thường. Có thể dùng `http` cho kết nối và `flutter_secure_storage` cho token sau khi kiểm tra tương thích SDK. [Mạng Android Emulator](https://developer.android.com/studio/run/emulator-networking-address) · [Cấu hình bảo mật mạng Android](https://developer.android.com/privacy-and-security/security-config) · [Gói http](https://pub.dev/packages/http) · [Gói flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)

## 2. Hiện thực hóa giao diện Figma

Đối chiếu diện mạo trên trang **Detail Themes**, các nhánh tương tác trên **Wireframes** và thành phần dùng lại trên **Component Library**. Dùng quy chuẩn giao diện để triển khai token, còn kiến trúc đã chốt quyết định nguồn dữ liệu, quy tắc tiền và trạng thái nghiệp vụ. Khung 390 × 844 là mốc so sánh bố cục. Dùng kích thước logic, vùng an toàn và bố cục cuộn để chạy được khi mở bàn phím, tăng cỡ chữ hoặc dùng thiết bị hẹp. Dữ liệu minh họa trong prototype chỉ dùng cho thử nghiệm giao diện. Các thông số chính bên dưới có thể dùng khi bản quy chuẩn cục bộ chưa có trong checkout. [Figma Our Budget](https://www.figma.com/design/PYUVQbAKdYyTAcvQGcxzfg/Our-Budget?node-id=2-45) · [Quy chuẩn giao diện Flutter cục bộ](../../agent/rules/DESIGN%20SYSTEM%20RULES%20FOR%20AGENT.md) · [Bản mẫu trong repo](../dgr/wireframes-figma/README.md)

### Token và thành phần dùng chung

- Tập trung `AppColors`, `AppTypography`, `AppSpacing` và `AppRadius` trong theme Material 3. Dùng lề ngang 16, khoảng cách 4, 8, 12, 16, 24, 32. Bo góc 8 cho ô nhập và chip, 16 cho thẻ và 24 cho hai góc trên của cửa sổ nhập nhanh.
- Dùng Inter và chữ số có độ rộng đồng đều cho tiền, phần trăm và số liệu. Theo thứ tự cỡ chữ, độ đậm và chiều cao dòng, dùng **28 / 700 / 36** cho tổng số dư, **20 / 600 / 28** và **16 / 600 / 24** cho tiêu đề, **15 / 600 / 20** cho số tiền trong lịch sử, **14 / 400 hoặc 500 / 20** cho thân bài và nhãn thao tác, **12 / 400 / 16** cho chú thích.
- Ánh xạ `primaryMain` (`#1E6F5C`) cho thao tác chính và thẻ số dư, `primarySoft` (`#E6F4F1`) cho phần chọn. Dùng `background` (`#F8FAFC`), `surface` (`#FFFFFF`), `border` (`#E2E8F0`), `textPrimary` (`#0F172A`) và `textMuted` (`#64748B`) cho bề mặt và văn bản.
- Giữ các màu ngữ nghĩa `income` (`#16A34A`), `expense` (`#DC2626`) và `warning` (`#F59E0B`). Kiểm tra tương phản chữ trên từng nền từ 4,5:1 theo quy chuẩn dự án. Đối chiếu biến `incomeTextAA` khi hiển thị chữ màu thu nhập và dùng nhãn hoặc dấu bên cạnh màu. Biểu đồ có chú giải và số liệu đọc được.
- Dùng `MainNavigationShell` cho bốn tab **Trang chủ**, **Lịch sử**, **Ngân sách**, **Cá nhân** và nút **+**. Tái sử dụng `BalanceHeaderCard`, `TransactionTile`, `BudgetProgressCard` và `QuickTransactionBottomSheet`. Mỗi thành phần nhận dữ liệu hiển thị và hành động từ màn hình gọi nó.
- Trong cửa sổ nhập nhanh, mở mặc định tab **Chi tiêu** và đặt con trỏ vào ô số tiền. Giữ ba trường số tiền, danh mục, nguồn tiền. Danh mục hiển thị lưới bốn cột ở kích thước tham chiếu và lấy từ API theo loại thu/chi. Dùng nhãn ngắn hoặc bố cục thích ứng khi cỡ chữ lớn. Ghi chú và đổi ngày giờ nằm trong vùng mở rộng. Nút Lưu cao tối thiểu 48 và khóa khi đang gửi. Dùng thời điểm hiện tại làm mặc định, kiểm tra số tiền lớn hơn 0 và dẫn đến tạo ví nếu tài khoản chưa có ví hoạt động.

### Màn hình, luồng và trạng thái

| Màn hình hoặc luồng | Hành vi cần triển khai |
| --- | --- |
| Cổng tài khoản và Cá nhân · UC1–UC5 | Đăng ký, đăng nhập, quên mật khẩu, nhận và dùng mã, cập nhật hồ sơ, đăng xuất. Vào Trang chủ khi có phiên hợp lệ. Màn hình báo cáo mở từ Cá nhân phải quay lại Cá nhân. |
| Trang chủ và ghi nhanh · UC7, UC15 | Hiển thị tổng số dư của các ví hoạt động, ngân sách tháng đã thiết lập và giao dịch gần đây. Hiển thị banner đỏ có nhãn khi ngân sách liên quan đạt hoặc vượt 100%. **Xem tất cả** chuyển sang Lịch sử. Nút **+** mở cùng một biểu mẫu từ các tab và trả về đúng màn hình nguồn sau khi lưu hoặc hủy. |
| Lịch sử · UC16–UC19 | Nhóm theo ngày phát sinh. Lọc theo thời gian, ví và danh mục, tìm theo từ khóa khi API hỗ trợ. Mở, sửa và xóa khoản thu/chi theo ID được chọn. Giữ bộ lọc khi quay lại. Dòng chuyển tiền có nhãn riêng và thể hiện ví nguồn, ví đích. |
| Nguồn tiền · UC6–UC10 | Hiển thị tổng, số dư từng ví và nhãn **Mặc định** theo ưu tiên đã chốt. Mở đúng ví để sửa/xóa. Chuyển tiền yêu cầu hai ví hoạt động khác nhau và số tiền dương. Khi còn lịch sử liên quan, mô tả rõ hiệu lực ngừng sử dụng trong hộp xác nhận. |
| Danh mục · UC11–UC14 | Hiển thị hai nhóm Chi tiêu và Thu nhập. Biểu mẫu tạo và sửa có lựa chọn biểu tượng, màu theo mẫu. Danh mục hệ thống ở chế độ chỉ đọc. Danh mục ngừng hoạt động vẫn có nhãn trong lịch sử và được bỏ khỏi bộ chọn giao dịch mới. |
| Ngân sách · UC20–UC21 | Chọn ngân sách tổng hoặc ngân sách theo danh mục chi, kỳ tuần hoặc tháng và hạn mức dương. Mở thẻ theo ID. Dùng trạng thái an toàn, cảnh báo và vượt hạn mức theo ngưỡng máy chủ. Thanh tiến trình dừng ở 100% về chiều dài, còn nhãn giữ tỷ lệ thực, ví dụ 102%. |
| Báo cáo thống kê · UC22 | Mở từ Ngân sách hoặc Cá nhân. Các tổng, cơ cấu chi và xu hướng theo tuần dùng cùng kỳ và phạm vi ví. Dùng biểu đồ vòng và cột nhóm trong hai thẻ riêng theo Figma. Đặc tả UC22 minh họa biến động bằng biểu đồ đường, nên cần đồng bộ mô tả hình thức khi bàn giao. Phân biệt kỳ trống với lỗi đọc dữ liệu. |

UC23 và UC24 xuất hiện dưới dạng kết quả cập nhật số dư và ngân sách trên giao diện. Mỗi danh sách hoặc thẻ dữ liệu có trạng thái tải lần đầu, có dữ liệu, rỗng, lỗi tải và đang làm mới. Khi làm mới thất bại, giữ dữ liệu gần nhất của cùng bộ lọc và báo lỗi cạnh phần liên quan. Biểu mẫu giữ dữ liệu khi lưu lỗi, gắn thông báo kiểm tra vào trường phù hợp và hỗ trợ nút Back của Android. Dùng nhãn trợ năng cho nút chỉ có biểu tượng, đọc được lỗi và trạng thái ngân sách bằng văn bản. [Luồng giao diện UC1–UC24](user-flow-our-budget.md)

## 3. Tích hợp API và quản lý trạng thái

### Ranh giới hợp đồng API

| Phân hệ | Tài nguyên đã chốt | Phần cần đặc tả cùng backend |
| --- | --- | --- |
| Tài khoản và hồ sơ | `/api/v1/auth/…`, `/api/v1/me` | Tên endpoint xác thực, định dạng token và cách gửi token, thời hạn phiên, luồng gửi mã/đặt lại mật khẩu, hợp đồng cập nhật hồ sơ và ảnh đại diện. |
| Nguồn tiền và danh mục | `/api/v1/wallets`, `/api/v1/categories` | ID, trạng thái hoạt động, ví mặc định hoặc trường ưu tiên, loại danh mục, khả năng chỉnh sửa, biểu tượng và màu. |
| Giao dịch và chuyển tiền | `POST /api/v1/transactions`, `POST /api/v1/transfers` | Hai thao tác tạo trả `201 Created`. Cần thống nhất payload, phương thức sửa/xóa, phạm vi thao tác với chuyển tiền trong lịch sử, cách phân trang và lọc, trường số dư trả về, cờ ngân sách và thời hạn chống ghi trùng. |
| Ngân sách và báo cáo | `/api/v1/budgets`, `/api/v1/reports` | Cách biểu diễn phạm vi tổng/danh mục, kỳ và ngày, đối tượng bộ lọc, tỷ lệ và mã trạng thái ngân sách, dữ liệu chuỗi thời gian và cách xử lý kỳ trùng. |

Giải mã giá trị tiền từ chuỗi số nguyên có dấu theo đơn vị đồng. Dùng `BigInt` cho giá trị và phép cộng tiền. Khi truyền dữ liệu, giữ định dạng chuỗi theo hợp đồng. Dấu thu/chi phải nhất quán với loại giao dịch, còn chuyển nội bộ mang số tiền dương nhưng hiển thị theo loại `TRANSFER`. Ô nhập dùng độ lớn dương và chuyển sang biểu diễn API theo quy ước đã thống nhất. Định dạng tiếng Việt ở ranh giới giao diện. Nếu thư viện biểu đồ cần số thực, chỉ chuyển tỷ lệ vẽ, còn nhãn và tổng tiền lấy từ giá trị chính xác.

Trao đổi thời điểm bằng ISO 8601 có độ lệch múi giờ theo hợp đồng. Khi nhóm theo ngày, chọn kỳ hoặc nhập lại ngày giờ, dùng `Asia/Ho_Chi_Minh`, kể cả khi điện thoại đặt múi giờ khác. Ngày bắt đầu và kết thúc của kỳ là ngày lịch. Khi hợp đồng nhận mốc thời điểm, dùng đầu ngày bắt đầu và đầu ngày kế tiếp sau ngày cuối kỳ theo khoảng đầu gồm, cuối loại trừ. Số liệu ngân sách và báo cáo lấy từ API, với các ngưỡng dưới 80%, từ 80% đến dưới 100%, và từ 100% trở lên. [Quy ước dữ liệu đã chốt](final-system-architecture.md)

| Phản hồi | Hành vi ứng dụng |
| --- | --- |
| `401` | Với yêu cầu thuộc phiên đã đăng nhập, xử lý hết phiên tập trung một lần rồi chuyển về cổng đăng nhập. Với đăng nhập thất bại, hiển thị lỗi tại biểu mẫu. |
| `404` | Báo tài nguyên không còn khả dụng, làm mới danh sách liên quan. |
| `409` | Hiển thị xung đột theo mã lỗi. Ví dụ, ngân sách trùng có thể dẫn tới mục đang tồn tại. Xung đột khóa gửi lại cần đối chiếu giao dịch đã lưu trước khi tạo thao tác khác. |
| `422` | Hiển thị lỗi theo trường và giữ giá trị đã nhập. |
| Timeout, lỗi kết nối hoặc `500` | Cho thử lại truy vấn đọc. Với thao tác ghi, xử lý theo mức độ chắc chắn của kết quả. Dữ liệu tài chính, mật khẩu, mã OTP và token phải được lọc khỏi nhật ký. |

### Vòng đời Provider và dữ liệu

Đặt trạng thái phiên ở gốc ứng dụng. Khi khởi động, đọc token từ vùng lưu trữ bảo mật và kiểm tra phiên theo hợp đồng trước khi hiển thị vùng dữ liệu cá nhân. Repository và bộ nhớ đệm dữ liệu tài khoản có vòng đời theo phiên. Khi đăng xuất hoặc nhận `401` từ phiên hiện tại, xóa token, hủy hoặc bỏ qua phản hồi đến muộn và dọn ngăn xếp điều hướng. Lệnh đăng xuất yêu cầu máy chủ thu hồi phiên. Nếu mất kết nối, vẫn kết thúc phiên trên thiết bị và thông báo khi việc thu hồi phía máy chủ chưa được xác nhận.

Mỗi màn hình hoặc biểu mẫu có ViewModel riêng. Giữ trạng thái tab và bộ lọc khi chuyển tab, còn bản nháp trường nhập thuộc vòng đời biểu mẫu. Dùng `Selector` hoặc `context.select` cho phần giao diện chỉ phụ thuộc một trường. Repository dùng chung cung cấp nguồn dữ liệu cho các màn hình cùng đọc ví, giao dịch hoặc ngân sách. Tách dữ liệu theo tài khoản và bộ lọc. Chỉ nhận kết quả tìm kiếm, phân trang và tải lại còn khớp với bộ lọc và phiên hiện tại. Dùng cơ chế phân trang theo hợp đồng, tải lại từ đầu khi đổi bộ lọc và gộp kết quả theo ID.

| Thao tác đã được xác nhận | Dữ liệu cần cập nhật hoặc làm mới |
| --- | --- |
| Thêm, sửa hoặc xóa thu/chi | Số dư ví bị tác động, Trang chủ và lịch sử. Đánh dấu ngân sách và báo cáo liên quan cần đọc lại, gồm kỳ và danh mục cũ lẫn mới khi chỉnh sửa. |
| Chuyển tiền nội bộ | Cập nhật cả hai số dư và lịch sử nếu API trả dòng chuyển. Tổng thu, chi và ngân sách vẫn theo các giao dịch thu/chi đã xác nhận. |
| Tạo, sửa hoặc ngừng sử dụng ví/danh mục | Làm mới danh sách và bộ chọn liên quan. Lịch sử vẫn hiển thị nhãn của tài nguyên đã ngừng sử dụng. |
| Tạo, sửa hoặc xóa ngân sách | Làm mới danh sách của kỳ liên quan và thẻ ngân sách tổng trên Trang chủ. |

### Luồng ghi và gửi lại

1. Xác thực biểu mẫu. Với yêu cầu tạo giao dịch hoặc chuyển tiền, chụp lại nội dung yêu cầu và sinh một `Idempotency-Key` cho lần gửi đầu. Chặn thao tác lặp khi yêu cầu còn đang chạy.
2. Khi nhận `201 Created`, hiển thị dữ liệu xác nhận và làm mới phần liên quan. Nếu API báo lỗi tải ngân sách sau commit, hiển thị giao dịch đã lưu và cho tải lại phần ngân sách riêng. Với phản hồi phát lại, tải lại số dư mới nhất để tránh áp dụng số dư cũ lên dữ liệu mới hơn.
3. Nếu mất kết nối và kết quả ghi chưa rõ, giữ nguyên khóa và nội dung cho lần thử lại trong cùng phiên thao tác. Khi người dùng rời biểu mẫu hoặc ứng dụng bị đóng, chỉ hỗ trợ khôi phục tự động nếu đã lưu bản ghi chờ của đúng tài khoản trong vùng bảo mật và khóa còn hiệu lực theo hợp đồng. Khi thiếu dữ liệu khôi phục, tra cứu lịch sử trước khi tạo lại. Với sửa/xóa chưa có cam kết chống lặp, tải lại bản ghi trước khi cho phép gửi tiếp.

## 4. Thứ tự triển khai và nghiệm thu

### Bổ sung thiết kế ngày 20/11/2026 — chưa triển khai

Trong `auth/`, dự kiến dùng `google_sign_in` để lấy ID token, gửi PHP và nhận phiên OurBudget. ViewModel xử lý chọn/hủy tài khoản, lỗi token và yêu cầu liên kết tài khoản hiện có. Token Google không thay thế token API; khôi phục phiên không tự tạo sự kiện đăng nhập mới. [Setup Google](google-email-setup.md).

Nguồn tiền dùng `wallets_priority` tăng dần, mặc định 0, tiếp theo 1, 2, …; bộ chọn lấy thứ tự được API xác nhận. Danh mục/loại ví dùng mã icon ánh xạ sang Material Icons cục bộ và fallback; logo thương hiệu là asset được duyệt. Flaticon là phương án thay thế, không phải phụ thuộc mặc định. Không thêm gói chỉ để thay bộ icon đã có.

Email do backend gửi sau thao tác thành công; Flutter hiển thị kết quả nghiệp vụ, không chờ SMTP hoặc giữ mật khẩu mail. Nếu hiển thị trạng thái thư, phân biệt gửi lỗi với giao dịch đã lưu; không yêu cầu ghi lại giao dịch để gửi lại thư. Thêm giao diện xác minh email/liên kết Google theo hợp đồng. [Quy tắc và ca nghiệm thu](proposal-google-email-icons.md).

### Thứ tự thực hiện

1. **Nền tảng.** Tạo dự án Flutter cho Android, lắp theme, điều hướng, Provider và nguồn dữ liệu mô phỏng. Chạy trên giả lập và thiết bị thật, kiểm tra tiếng Việt và chế độ bàn phím.
2. **Luồng chính.** Dựng cổng tài khoản, bốn tab, Trang chủ và nhập nhanh. Đối chiếu khung Figma ở 390 × 844, rồi thử cỡ chữ lớn, màn hình hẹp, vùng an toàn, nút Back và các nhánh lỗi.
3. **Tích hợp giao dịch.** Kiểm chứng hợp đồng tài khoản, danh mục và ví với backend, sau đó nối một luồng hoàn chỉnh từ đăng nhập đến tạo giao dịch và làm mới số dư, lịch sử. Kiểm tra thêm sửa, xóa, chuyển tiền và tình huống mất mạng ngay sau khi bấm Lưu.
4. **Hoàn thiện phạm vi.** Tích hợp ngân sách tổng, ngân sách theo danh mục và báo cáo. Kiểm tra UC1–UC24, đặc biệt là lọc theo kỳ, số tiền lớn, mốc đổi ngày ở Việt Nam, ngưỡng 80% và 100%, cảnh báo thất bại sau commit, và hai tài khoản đăng nhập nối tiếp trên cùng thiết bị.

Tiêu chí bàn giao gồm `flutter analyze`, kiểm thử đơn vị và widget, cùng kiểm thử tích hợp trên Android cho đăng nhập, giao dịch, chuyển tiền và đọc báo cáo. Đối chiếu từng màn hình với Figma khi có quyền đọc chi tiết. Đối chiếu yêu cầu và phản hồi thực tế với hợp đồng API trước khi nghiệm thu phần kết nối.
