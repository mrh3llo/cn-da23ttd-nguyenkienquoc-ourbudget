# Lộ trình triển khai OurBudget cho Android

Hiện trạng bắt đầu là cây thư mục `src/mobile/ourbudget/`. Mốc đầu tiên là chạy được ứng dụng Flutter trong Android Studio. Mốc chức năng đầu tiên là đăng nhập, tạo hoặc chọn ví, ghi một khoản thu/chi và thấy số dư cùng lịch sử cập nhật từ API. Sau đó mới hoàn thiện sửa/xóa, chuyển tiền, ngân sách và báo cáo. Kế hoạch bao gồm phần PHP/MySQL cần có để nghiệm thu ứng dụng với dữ liệu thật. [Cây thư mục Flutter](../mobile/ourbudget/README.md) · [Kiến trúc hệ thống](final-system-architecture.md) · [Kiến trúc Flutter](flutter-app-architecture.md) · [Use-case UC1–UC24](use-case-diagram.md) · [Luồng Figma](user-flow-our-budget.md)

## Cách thực hiện từng bước

Làm theo thứ tự trong bảng. Trong mỗi bước có tích hợp, xác định hợp đồng cho riêng phân hệ đó, kiểm tra phần PHP/MySQL, nối Flutter rồi chạy ca nghiệm thu. Nếu chưa có API dùng được, có thể dựng ViewModel và giao diện với repository giả cùng kiểu dữ liệu. Ghi kết quả là **đã kiểm tra với dữ liệu giả** và giữ phần nghiệm thu API thật ở trạng thái chờ. Các bước nghiệp vụ sau có thể chuẩn bị giao diện độc lập, còn các ca phụ thuộc dữ liệu thật chạy khi API trước đó đã qua kiểm tra.

| Bước | Công việc | Phụ thuộc chính | Đầu ra để chuyển bước |
| --- | --- | --- | --- |
| 01 | Khởi tạo Flutter Android | Cây thư mục hiện có | Mở và chạy được ứng dụng từ Android Studio |
| 02 | Thiết lập theme, điều hướng, Provider và lớp dữ liệu | 01 | Khung ứng dụng chạy bằng repository giả |
| 03 | Chuẩn bị PHP/MySQL và quy ước HTTP | 01, 02 | Schema MySQL, dữ liệu kiểm thử và môi trường API truy cập được |
| 04 | Tài khoản và phiên | 02, 03 | Phiên hoạt động từ đăng nhập đến đăng xuất |
| 05 | Nguồn tiền và danh mục | 04 | Có ví và danh mục thật để ghi giao dịch |
| 06 | Ghi thu/chi, Trang chủ và Lịch sử | 05 | Luồng ghi tiền đầu tiên qua API thật |
| 07 | Sửa, xóa giao dịch và chuyển tiền | 06 | Số dư, lịch sử và quy tắc bảo toàn dữ liệu khớp |
| 08 | Ngân sách và cảnh báo | 07 | Ngân sách tổng và theo danh mục có trạng thái đúng |
| 09 | Báo cáo thống kê | 08 | Tổng và biểu đồ dùng cùng phạm vi dữ liệu |
| 10 | Nghiệm thu Android | 01–09 | Kết quả UC1–UC24 và bản cài kiểm thử |

## Bước 01. Khởi tạo dự án Flutter Android

1. Kiểm tra cây hiện có, nội dung `android/` và mọi tệp cục bộ trước khi khởi tạo. Dùng mẫu ứng dụng Flutter cho Android tại `src/mobile/ourbudget/`, giữ cấu trúc trong README và đối chiếu các tệp được sinh để tránh ghi đè nội dung đang có.
2. Tạo `pubspec.yaml`, entry point `lib/main.dart` và cấu hình Gradle/manifest từ mẫu. Ghi phiên bản Flutter/Dart thực tế sử dụng và lưu `pubspec.lock`. Khi một thư mục có tệp triển khai, có thể bỏ `.gitkeep` của chính thư mục đó.
3. Chạy `flutter doctor`, `flutter pub get` và `flutter analyze` từ dự án. Mở thư mục chứa `pubspec.yaml` trong Android Studio, chọn thiết bị Android và chạy entry point. Dùng một màn hình tối thiểu có tiêu đề OurBudget để xác nhận build và hiển thị tiếng Việt.

**Nghiệm thu** Android Studio nhận dự án Flutter, ứng dụng mở trên thiết bị kiểm thử, và kết quả phân tích không có lỗi. Ghi môi trường đã dùng để người khác chạy lại.

## Bước 02. Thiết lập nền Flutter và bản mẫu có tương tác

1. Trong `lib/design_system/`, đặt theme Material 3, màu, Inter, lưới và bo góc theo Figma. Khai báo các tài nguyên đã có trong `pubspec.yaml`. Trong `lib/widgets/`, dựng khung điều hướng bốn tab và nút **+**, cùng các thành phần dùng chung cần cho Trang chủ và biểu mẫu. Đối chiếu bố cục 390 × 844, bàn phím, cỡ chữ lớn và nút Back.
2. Trong `lib/app/`, thiết lập cổng phiên và chỗ lắp Provider. Phân hệ sở hữu màn hình, ViewModel và repository tương ứng. Giữ bản nháp ở biểu mẫu, dữ liệu ví và giao dịch ở repository theo phiên. Dùng repository giả để tập thử luồng mở Trang chủ, lịch sử và biểu mẫu, với trạng thái tải, rỗng, lỗi và làm mới.
3. Trong `lib/core/`, đặt cấu hình `API_BASE_URL`, ánh xạ lỗi HTTP và định dạng dùng chung khi được sử dụng lần đầu. Lắp tiền tố `/api/v1` ở một nơi. Tiền trên API là chuỗi số nguyên VND, client xử lý bằng số nguyên chính xác. Thời điểm giao dịch trao đổi theo ISO 8601 có độ lệch múi giờ và hiển thị theo `Asia/Ho_Chi_Minh`.

**Nghiệm thu** Tab giữ trạng thái khi chuyển qua lại, nút **+** trả về đúng màn hình nguồn, lớp giao diện chạy với dữ liệu giả và kiểm thử giải mã bảo toàn tiền lớn lẫn ngày phát sinh khi máy đặt múi giờ khác.

## Bước 03. Chuẩn bị PHP/MySQL và hợp đồng dùng chung

1. Kiểm tra nơi đặt mã PHP, môi trường chạy, MySQL và cách cung cấp cấu hình phát triển. Kiểm tra đích PowerDesigner trước khi sinh SQL vì PDM hiện đặt SAP SQL Anywhere 17. Đối chiếu ERD và PDM với kiến trúc đích MySQL InnoDB, sau đó dùng migration hoặc DDL đã kiểm tra trên cơ sở dữ liệu phát triển. Cơ sở dữ liệu này cần dựng lại được từ schema và dữ liệu mẫu.
2. Chuẩn bị bảng người dùng, phiên và khôi phục mật khẩu, ví, danh mục thu/chi, giao dịch, khóa chống ghi trùng và ngân sách. Đối chiếu khóa ngoại, trạng thái hoạt động, chỉ mục theo tài khoản và ngày phát sinh, cùng `BIGINT` cho tiền. Chuẩn bị hai tài khoản thử độc lập và danh mục hệ thống dùng chung.
3. Chốt quy ước xác thực, cấu trúc lỗi có mã nghiệp vụ và lỗi theo trường, quy tắc phân trang và mẫu yêu cầu/phản hồi. Ghi rõ `401`, `404`, `409`, `422` và `500` để Flutter xử lý khác nhau. Chi tiết endpoint được chốt theo từng bước chức năng. Trong môi trường phát triển, kiểm tra đường kết nối từ Android Emulator hoặc thiết bị thật tới PHP và cấu hình HTTPS cho bản phát hành.

**Nghiệm thu** Dựng được cơ sở dữ liệu thử từ đầu. Kiểm thử được PHP kết nối MySQL và thiết bị gọi được API thử nghiệm. Có mẫu phản hồi thành công và lỗi để làm fixture cho Flutter.

## Bước 04. Tài khoản, hồ sơ và vòng đời phiên · UC1–UC5

1. Thống nhất endpoint và dữ liệu cho đăng ký, đăng nhập, đọc phiên/hồ sơ, đăng xuất, quên mật khẩu và cập nhật hồ sơ. Làm rõ hợp đồng ảnh đại diện trước khi nối trường này. Trên PHP, băm mật khẩu, xác thực token có hạn, thu hồi khi đăng xuất, dùng mã khôi phục có hạn và chỉ dùng một lần, giới hạn tần suất đăng nhập và gửi mã.
2. Trong Flutter, nối `auth/` và `profile/`. Lưu token trong vùng bảo mật, kiểm tra phiên trước khi mở dữ liệu cá nhân, tránh ghi token hoặc mã khôi phục vào log. Xử lý `401` ở một nơi đối với phiên đang dùng. Khi thoát phiên, xóa trạng thái và bỏ phản hồi trả muộn của phiên cũ, kể cả khi tài khoản khác đã đăng nhập.
3. Kiểm tra lỗi đăng ký, sai mật khẩu, phiên hết hạn, mã hết hạn hoặc đã dùng, và cập nhật hồ sơ thất bại. Phân biệt phiên hết hạn với mất mạng khi khôi phục phiên. Khi đăng xuất mất mạng, kết thúc phiên trên thiết bị và thể hiện việc thu hồi phía máy chủ còn chưa được xác nhận.

**Nghiệm thu** Tài khoản A đăng nhập, mở hồ sơ, đăng xuất và không thể dùng nút Back để xem dữ liệu cũ. Tài khoản B đăng nhập trên cùng thiết bị và không nhận trạng thái hay phản hồi của A.

## Bước 05. Nguồn tiền và danh mục · UC6–UC9, UC11–UC14

1. Nối `wallets/` với danh sách, tạo, sửa và xóa/ngừng sử dụng ví. API khởi tạo số dư hiện tại bằng số dư đầu kỳ. Khi sửa số dư đầu kỳ, áp dụng phần chênh lệch trong cùng giao tác. Chọn ví mặc định trong nhóm đang hoạt động theo độ ưu tiên giảm dần, rồi theo ID tăng dần khi bằng nhau.
2. Nối `categories/` với hai loại danh mục thu và chi. Cho xem danh mục hệ thống ở chế độ chỉ đọc và chỉ sửa danh mục tùy chỉnh của tài khoản hiện tại. Dùng định danh kèm loại danh mục ở nơi hợp đồng yêu cầu. Với ví và danh mục còn tham chiếu, dùng trạng thái ngừng hoạt động và giữ nhãn cho lịch sử. Kiểm tra hành vi này lại ở bước 07 sau khi đã có giao dịch.
3. Dùng chung dữ liệu từ repository cho màn hình danh sách và bộ chọn trong biểu mẫu ghi nhanh. Khi chưa có ví hoạt động, dẫn người dùng đến tạo ví. Sau khi sửa hoặc xóa, làm mới bộ chọn và danh sách liên quan.

**Nghiệm thu** Tạo được hai ví và danh mục thử, xác định đúng ví mặc định, tài khoản B không đọc hoặc sửa được dữ liệu riêng của A, và danh mục hệ thống vẫn hiển thị theo đúng loại.

## Bước 06. Ghi thu chi và đọc lịch sử · UC15–UC17, UC23

1. Chốt payload của `POST /api/v1/transactions`, kết quả `201 Created`, cấu trúc số dư trả về và hợp đồng danh sách. API kiểm tra loại giao dịch, quyền sở hữu và trạng thái tài nguyên, khóa ví rồi ghi giao dịch và số dư trong một giao tác. Lưu kết quả cùng `Idempotency-Key` để yêu cầu lặp cùng nội dung chỉ ghi một lần.
2. Nối `QuickTransactionBottomSheet` với danh mục, ví và giao dịch thật. Mặc định tab Chi tiêu, lấy ngày giờ hiện tại và mở ghi chú/ngày giờ tùy chọn. Chặn gửi hai lần khi đang lưu, giữ nội dung khi gặp lỗi. Với ghi chưa rõ kết quả, giữ nguyên nội dung và khóa cho lần thử lại. Với kết quả phát lại, tải số dư mới nhất.
3. Dùng phản hồi đã xác nhận để cập nhật Trang chủ, lịch sử và ví. Lịch sử nhóm theo ngày phát sinh và giữ bộ lọc khi quay lại. Nối bộ lọc ngày, ví, danh mục, tìm kiếm và phân trang theo hợp đồng. Khi đổi bộ lọc, tải lại trang đầu, bỏ phản hồi đến muộn của bộ lọc trước và gộp trang theo ID.

**Nghiệm thu** Ghi được cả thu lẫn chi. Ví có 100.000 đ, ghi chi 25.000 đ thì sau xác nhận còn 75.000 đ. Mất phản hồi sau khi máy chủ đã lưu rồi gửi lại cùng khóa vẫn chỉ có một bản ghi và số dư 75.000 đ. Khóa cũ với nội dung khác trả `409`.

## Bước 07. Sửa, xóa giao dịch và chuyển tiền · UC10, UC18–UC19, UC23

1. Nối thao tác sửa/xóa theo ID đã chọn. API khóa bản ghi và các ví bị ảnh hưởng, hoàn tác biến động cũ và áp dụng biến động mới trong cùng giao tác. Xử lý đổi số tiền, ví, danh mục hoặc kỳ. Khi kết quả sửa/xóa chưa rõ và hợp đồng không có chống lặp, đọc lại bản ghi trước khi cho phép thực hiện lại.
2. Chốt payload `POST /api/v1/transfers` và phạm vi thao tác với dòng chuyển trong lịch sử. Kiểm tra hai ví khác nhau, hoạt động, cùng tài khoản và số tiền dương. Khóa ví theo thứ tự ID thống nhất, ghi một bản ghi `TRANSFER` và cập nhật hai số dư trong cùng giao tác. Dùng khóa chống ghi trùng như bước 06.
3. Sau xác nhận, làm mới các ví, lịch sử và Trang chủ. Khi đổi kỳ hoặc danh mục, đánh dấu cả phạm vi cũ lẫn mới cần đọc lại. Kiểm tra xóa hoặc ngừng sử dụng ví/danh mục đã có dữ liệu và vẫn đọc được nhãn trong lịch sử.

**Nghiệm thu** Chuyển 20.000 đ khi A có 75.000 đ và B có 10.000 đ cho kết quả A còn 55.000 đ, B có 30.000 đ và tổng vẫn là 85.000 đ. Ca ghi đồng thời giữ đúng số dư. Ca lỗi sau một bước ghi hoàn tác toàn bộ giao tác.

## Bước 08. Ngân sách và cảnh báo · UC20–UC21, UC24

1. Chốt hợp đồng kỳ, phạm vi tổng/danh mục, quy tắc ngân sách trùng và dữ liệu ưu tiên hiển thị trên Trang chủ nếu có nhiều kỳ. API tính tổng độ lớn các khoản chi theo thời điểm phát sinh và loại trừ chuyển nội bộ. Dùng khoảng từ đầu ngày bắt đầu đến trước đầu ngày sau ngày kết thúc theo `Asia/Ho_Chi_Minh`.
2. Nối `budgets/` cho tạo, đọc, sửa và xóa ngân sách tổng hoặc theo danh mục chi. Hiển thị số đã chi, hạn mức, tỷ lệ và nhãn trạng thái. Thanh tiến trình có thể dừng ở 100% về chiều dài, còn nhãn giữ tỷ lệ thực.
3. Nối cập nhật ngân sách sau khi giao dịch đã commit. Khi bước đọc ngân sách lỗi, vẫn báo giao dịch đã lưu và cung cấp thao tác tải lại ngân sách riêng. Khi sửa/xóa khoản chi hoặc chuyển kỳ, đọc lại phạm vi liên quan và cập nhật thẻ/bản cảnh báo trên Trang chủ.

**Nghiệm thu** Với hạn mức 100.000 đ, kiểm tra dưới 80.000 đ, đúng 80.000 đ, đúng 100.000 đ và trên 100.000 đ. Kiểm tra giao dịch ngay trước và đúng mốc đầu kỳ, chuyển nội bộ, sửa khoản chi sang kỳ khác, và lưu thành công khi đọc ngân sách thất bại.

## Bước 09. Báo cáo thống kê · UC22

1. Chốt cấu trúc phản hồi cho tổng thu, tổng chi, phân bổ danh mục và chuỗi thời gian. Thống nhất cách lọc theo kỳ và ví, cách chia nhóm tuần và cách hiển thị kỳ trống. API dùng cùng tập điều kiện cho tổng và biểu đồ, loại chuyển nội bộ khỏi thu/chi.
2. Nối `reports/` từ Ngân sách và Cá nhân, giữ đường quay lại đúng nơi mở. Dựng biểu đồ vòng và cột nhóm theo phương án Flutter đối chiếu Figma. Trình bày chú giải và số liệu bằng văn bản để đọc được cả khi biểu đồ khó phân biệt.
3. Làm mới báo cáo khi thay đổi kỳ, ví hoặc khi dữ liệu giao dịch liên quan thay đổi. Dùng dữ liệu xác nhận từ API cho nhãn tiền và tổng. Kiểm tra phản hồi đến muộn khi người dùng đổi bộ lọc liên tục.

**Nghiệm thu** Cùng kỳ và ví, tổng thu/chi và chuỗi biểu đồ khớp với tập giao dịch thử. Giao dịch chuyển nội bộ giữ nguyên các tổng. Kỳ trống và lỗi tải có thể phân biệt.

## Bước 10. Hồi quy, nghiệm thu và bàn giao

1. Chạy `flutter analyze`, `flutter test` và kiểm thử tích hợp trên Android. Chạy kiểm thử PHP/MySQL cho hợp đồng HTTP, cách ly tài khoản, rollback, cạnh tranh cập nhật số dư, chống gửi lặp và biên kỳ ngân sách. Lưu kết quả theo nhóm use-case và ghi rõ ca dùng giả lập dữ liệu hay API thật.
2. So sánh giao diện với Figma ở khung tham chiếu và chạy trên điện thoại hoặc Android Emulator ở kích thước khác. Kiểm tra nhập liệu tiếng Việt, bàn phím, văn bản lớn, nút Back, thao tác xác nhận, lỗi mạng và trạng thái rỗng.
3. Tạo bản cài Android kiểm thử và kiểm tra khởi động, cấu hình API, đăng nhập, ghi giao dịch, chuyển tiền và báo cáo từ bản cài. Ghi môi trường, phiên bản SDK, cách chạy, cách tạo dữ liệu thử và các quyết định còn mở.

**Bàn giao** Mỗi bước ghi lại phạm vi đã hoàn thành, tệp hoặc chức năng liên quan, kết quả kiểm tra và vướng mắc còn lại. Dùng bảng sau để rà đủ phạm vi trước khi nghiệm thu toàn ứng dụng.

| Use-case | Bước xác nhận chính |
| --- | --- |
| UC1–UC5 | 04 · tài khoản và hồ sơ |
| UC6–UC9, UC11–UC14 | 05 · ví và danh mục, kiểm chứng bảo toàn lịch sử ở 07 |
| UC10 | 07 · chuyển nội bộ |
| UC15–UC17 | 06 · ghi thu/chi, lịch sử và bộ lọc |
| UC18–UC19 | 07 · sửa/xóa và hoàn tác số dư |
| UC20–UC21 | 08 · cấu hình và quản lý ngân sách |
| UC22 | 09 · báo cáo |
| UC23 | 06 và 07 · tạo, sửa, xóa, chuyển tiền và cập nhật số dư |
| UC24 | 08 · cảnh báo sau khi commit và tải lại ngân sách |
