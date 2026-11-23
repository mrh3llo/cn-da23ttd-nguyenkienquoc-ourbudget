# Hệ thống thiết kế OurBudget

Tài liệu mô tả hệ thống thiết kế đang được triển khai trong ứng dụng Flutter, dựa trên mã nguồn hiện có. Nguồn cấu hình giao diện tập trung là [app_theme.dart](../mobile/ourbudget/lib/design_system/app_theme.dart); các thành phần giao diện sử dụng cấu hình này và bổ sung định dạng tại từng widget.

## 1. Công nghệ và tổ chức

Ứng dụng sử dụng `ThemeData` với Material 3 (`useMaterial3: true`), thông qua thư viện `material_ui`. Bộ theme chung được áp dụng bằng `theme: appTheme` trong ứng dụng. Font chữ và tài nguyên ảnh được khai báo trong [pubspec.yaml](../mobile/ourbudget/pubspec.yaml).

| Nội dung | Vị trí mã nguồn |
|---|---|
| Màu sắc, khoảng cách, bo góc và theme | `lib/design_system/app_theme.dart` |
| Áp dụng theme, ngôn ngữ và màn hình theo phiên | `lib/app/ourbudget_app.dart` |
| Logo và biểu mẫu xác thực | `lib/features/auth/presentation/auth_page.dart` |
| Thẻ số dư, ngân sách và danh sách giao dịch | `lib/widgets/ledger_cards.dart` |
| Thanh điều hướng chính và nút ghi giao dịch | `lib/widgets/main_navigation_shell.dart` |
| Biểu mẫu ghi nhanh | `lib/features/transactions/presentation/quick_transaction_bottom_sheet.dart` |

Các đường dẫn bắt đầu bằng `lib/` trong tài liệu được tính từ thư mục `src/mobile/ourbudget/`.

## 2. Bảng màu

| Token | Mã màu | Vai trò |
|---|---|---|
| `primary` | `#1E6F5C` | Màu thương hiệu; thành phần chính và trạng thái điều hướng được chọn |
| `primarySoft` | `#E6F4F1` | Nền xanh nhạt; ánh xạ vào `secondaryContainer` |
| `background` | `#F8FAFC` | Nền màn hình và AppBar |
| `outline` | `#E2E8F0` | Viền thẻ và nền thanh tiến trình |
| `ink` | `#0F172A` | Nội dung chữ chính |
| `muted` | `#475569` | Nội dung chữ phụ và trạng thái điều hướng chưa chọn |
| `income` | `#15803D` | Khoản thu và trạng thái ngân sách an toàn |
| `expense` | `#DC2626` | Khoản chi, lỗi biểu mẫu và trạng thái ngân sách vượt ngưỡng |
| `warning` | `#F59E0B` | Cảnh báo ngân sách |
| `Colors.white` | `#FFFFFF` | Bề mặt thẻ; chữ và icon trên một số nền xanh |

`ColorScheme` được tạo từ `primary` bằng `ColorScheme.fromSeed`, sau đó ghi đè `primary`, `secondaryContainer`, `surface`, `onSurface`, `onSurfaceVariant` và `error`. Các màu khác trong color scheme được framework sinh tự động; không có bảng mã màu riêng được khai báo cho chúng trong `app_theme.dart`.

## 3. Kiểu chữ và số liệu

Font chung là **Inter**, được nạp từ `assets/fonts/Inter.ttf`. Các kiểu chữ không được ghi đè riêng kế thừa từ theme Material 3.

| Vị trí | Cấu hình hiện có |
|---|---|
| Tiêu đề AppBar | Inter, cỡ 20, độ đậm `w600`, hệ số chiều cao dòng 1,4, màu `ink` |
| Số dư tổng trên thẻ | Cỡ 28, độ đậm `w700`, hệ số chiều cao dòng `36/28`, màu trắng |
| Tên và tỷ lệ trong thẻ ngân sách | Độ đậm `w600` |
| Nhãn trạng thái ngân sách | Cỡ 12, màu `muted` |
| Nhãn thanh điều hướng | Cỡ 11, đổi màu theo trạng thái chọn |

Token `numeric` chứa `FontFeature.tabularFigures()`, giúp chữ số có độ rộng đồng đều khi hiển thị tiền và tỷ lệ. Thành phần tài chính sử dụng hàm định dạng từ `lib/core/format/finance_format.dart`; không tự ghép định dạng tiền ở từng màn hình.

## 4. Khoảng cách và hình dạng

Các kích thước dưới đây dùng đơn vị logical pixel của Flutter.

| Token hoặc thành phần | Giá trị |
|---|---:|
| Khoảng cách chung `spacing` | 16 |
| Bo góc thẻ `cardRadius` | 16 |
| Bo góc bottom sheet `sheetRadius` | 24 |
| Bo góc viền ô nhập liệu | 8 |
| Khoảng đệm biểu mẫu xác thực | 24 |
| Chiều rộng tối đa biểu mẫu xác thực | 480 |

Thẻ dùng nền trắng, không đổ bóng (`elevation: 0`), không có margin mặc định và có viền màu `outline`. Ô nhập liệu dùng `OutlineInputBorder` với bo góc 8. Các widget có thể bổ sung khoảng cách nhỏ hơn như 4 hoặc 8 để phân nhóm nội dung; hiện chưa có một thang khoảng cách đầy đủ được khai báo thành token.

## 5. Nhận diện thương hiệu

Các màn hình đăng nhập, đăng ký, quên mật khẩu và đặt lại mật khẩu được dựng trong `AuthPage`, dùng chung một vùng logo trên AppBar. Logo hiển thị là `assets/icons/our-budget-wordmark.png`, với kích thước khung 204 × 48, `BoxFit.contain`, căn giữa và nhãn ngữ nghĩa “OurBudget”. AppBar có chiều cao 72. Cách bố trí này giữ tỷ lệ ảnh và vị trí logo nhất quán giữa các chế độ xác thực.

Tài nguyên SVG gốc nằm tại `assets/icons/our-budget-wordmark.svg`; tài nguyên được khai báo và nạp trực tiếp trong giao diện xác thực hiện tại là bản PNG. Khi thay tài nguyên thương hiệu, cần đối chiếu cả khai báo asset trong `pubspec.yaml` và nơi sử dụng trong `AuthPage`.

## 6. Thành phần giao diện hiện có

### 6.1. Biểu mẫu xác thực

Biểu mẫu được đặt trong `ConstrainedBox` có chiều rộng tối đa 480 và sử dụng `ListView` để cuộn. Các trường nhập, nút thao tác, thông báo và lỗi lấy trạng thái từ `AuthController` qua Provider. Lỗi được hiển thị bằng màu `expense`; các điều khiển tương ứng được vô hiệu hóa khi thao tác xác thực đang xử lý. Tiêu đề biểu mẫu kế thừa `headlineMedium` từ theme.

### 6.2. Thẻ tài chính

`BalanceHeaderCard` dùng nền `primary`, chữ trắng, bo góc `cardRadius` và khoảng đệm `spacing`. Số tiền được nhấn mạnh bằng cỡ chữ 28 cùng chữ số có độ rộng đồng đều.

`BudgetProgressCard` hiển thị tên ngân sách, tỷ lệ, số tiền đã chi, hạn mức và nhãn trạng thái. Theo logic hiện có, tỷ lệ nguyên từ 80% đến dưới 100% dùng màu `warning`; từ 100% trở lên dùng màu `expense` với nhãn “Vượt hạn mức”; dưới 80% dùng màu `income` với nhãn “An toàn”. Thanh tiến trình cao 8 và dừng ở độ dài 100%, trong khi nhãn tỷ lệ vẫn thể hiện giá trị tính được. Đây là mô tả hành vi giao diện hiện tại, không phải kết luận rằng nghiệp vụ ngân sách đã được nghiệm thu với API thật.

### 6.3. Điều hướng và biểu mẫu ghi nhanh

`MainNavigationShell` chứa bốn đích điều hướng: Trang chủ, Lịch sử, Ngân sách và Cá nhân. Đích được chọn dùng màu `primary`; các đích còn lại dùng màu `muted`. Mỗi đích có icon, nhãn và thông tin `Semantics` về trạng thái chọn.

Khi bật chức năng giao dịch, nút nổi “Ghi giao dịch” có nền `primary`, icon trắng và dạng tròn. Biểu mẫu ghi nhanh mở bằng modal bottom sheet với nền trắng, bo góc trên theo `sheetRadius`, hỗ trợ chiều cao theo nội dung và vùng an toàn. Việc bật chức năng giao dịch tùy thuộc cấu hình màn hình; tài liệu này không xác nhận các chức năng tài chính đã tích hợp hoàn chỉnh.

## 7. Quy tắc áp dụng khi phát triển

1. Tái sử dụng token và `appTheme` trong `app_theme.dart` khi thêm màn hình hoặc thành phần.
2. Dùng `Theme.of(context).textTheme` cho nội dung thông thường; chỉ ghi đè kiểu chữ khi có yêu cầu cụ thể của thành phần.
3. Dùng `numeric` cho số liệu tài chính cần căn chỉnh và hàm định dạng tiền dùng chung để giữ cách trình bày nhất quán.
4. Kết hợp màu với nhãn hoặc icon để người dùng hiểu trạng thái; giữ tooltip và thông tin ngữ nghĩa cho điều khiển.
5. Giữ tỷ lệ logo, bảo đảm biểu mẫu cuộn được và kiểm tra bố cục khi bàn phím xuất hiện hoặc người dùng tăng cỡ chữ.

## 8. Phạm vi đã có và phần chưa hoàn thành

Đã có theme sáng Material 3, bảng màu dùng chung, font Inter, một số token kích thước, cấu hình thẻ và ô nhập liệu, logo xác thực cùng các widget tái sử dụng. Theme hiện tại chưa định nghĩa bộ token đầy đủ cho tất cả kích thước chữ, nút và trạng thái tương tác.

| Hạng mục | Trạng thái theo mã nguồn đã rà soát |
|---|---|
| Theme tối và chuyển chế độ sáng/tối | Chưa hoàn thành |
| Danh mục component độc lập với toàn bộ biến thể và trạng thái | Chưa hoàn thành |
| Bảng đối chiếu đầy đủ token Flutter với hệ thống thiết kế Figma | Chưa hoàn thành |
| Đánh giá toàn bộ màn hình theo tiêu chí accessibility | Chưa hoàn thành |

Tài liệu được lập từ mã nguồn; không xác nhận mức độ khớp từng chi tiết với Figma hoặc kết quả hiển thị trên thiết bị. Lần soạn tài liệu này không thay đổi mã ứng dụng và không chạy lại kiểm thử/build.
