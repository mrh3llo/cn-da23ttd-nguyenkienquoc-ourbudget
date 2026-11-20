# Kiểm thử bước 02 Nền Flutter và bản mẫu tương tác

**Môi trường** Flutter 3.50.1 stable, Dart 3.14.0, Android Emulator API 37. Các luồng ghi và đọc sử dụng repository giả trong bộ nhớ theo phiên thử nghiệm. [Lộ trình bước 02](../docs/implementation-roadmap.md#bước-02-thiết-lập-nền-flutter-và-bản-mẫu-có-tương-tác) · [Kiến trúc Flutter](../docs/flutter-app-architecture.md)

## Phạm vi triển khai

Ứng dụng sử dụng theme Material 3 và Inter cục bộ, Provider với ChangeNotifier, cổng phiên thử nghiệm và bốn tab. Nút **+** mở biểu mẫu ghi thu/chi với ví mặc định, danh mục theo loại, ghi chú và thời điểm tùy chọn. Trang chủ, Lịch sử và Ngân sách đọc cùng một trạng thái. Sau khi repository xác nhận lưu, giao dịch và số dư thay đổi đồng thời trên các tab liên quan.

Lớp dùng chung đọc `API_BASE_URL`, tạo đường dẫn với tiền tố `/api/v1` và ánh xạ lỗi HTTP. Dữ liệu mẫu đi qua quy tắc chuỗi số nguyên VND và thời điểm ISO 8601 có múi giờ. [Provider](https://pub.dev/packages/provider) · [Timezone](https://pub.dev/packages/timezone) · [Giấy phép Inter](../mobile/ourbudget/assets/fonts/OFL.txt)

## Kết quả

| Kiểm tra | Kết quả |
| --- | --- |
| `flutter pub get --offline`, `flutter analyze --no-pub` | Đạt. Phụ thuộc được phân giải và phân tích tĩnh không có lỗi hoặc cảnh báo. |
| Quy ước tiền và thời gian | Đạt. Giữ nguyên `9223372036854775807` khi giải mã. Hai biểu diễn cùng thời điểm với `Z` và `-08:00` đều hiển thị 01:00 ngày 01/12 tại Việt Nam. Từ chối số thập phân, số JSON và thời điểm thiếu độ lệch. |
| Địa chỉ API và lỗi HTTP | Đạt. Đường dẫn chứa một tiền tố `/api/v1`, địa chỉ gốc có tiền tố bị từ chối và các mã 401, 404, 409, 422, 500 được ánh xạ. |
| Lọc, nút Back và ghi khoản chi ở 390 × 844 | Đạt. Bộ lọc ví giữ nguyên khi đổi tab. Back đóng biểu mẫu và quay lại Lịch sử. Sau khi ghi chi 25.000 đ, số dư mẫu từ 5.420.000 đ còn 5.395.000 đ. |
| Ghi khoản thu và thử lại khi lưu lỗi | Đạt. Danh mục đổi theo loại Thu nhập, số tiền và danh mục giữ nguyên sau lỗi mô phỏng. Thử lại thành công và số dư tăng đúng 50.000 đ. |
| Tải, lỗi, tải lại và danh sách rỗng | Đạt. Dùng lỗi mô phỏng để xác nhận tải lại thành công và thông báo rỗng hiển thị. |
| Vòng đời phiên thử nghiệm | Đạt. Thoát phiên và mở lại tạo repository mới và đưa ứng dụng về Trang chủ. |
| Màn hình hẹp và bàn phím | Đạt. Biểu mẫu cuộn được với khung 320 × 640, cỡ chữ 1,6 lần và khoảng bàn phím mô phỏng 260 px. Nút lưu vẫn hiển thị lỗi nhập liệu. |
| `flutter build apk --debug --no-pub` và chạy Android Emulator | Đạt. Cài APK debug, xác nhận Trang chủ và mở biểu mẫu ghi nhanh với bàn phím số trên máy ảo. |

Tổng cộng **7/7 bài kiểm thử tự động đạt**. Kiểm tra bố cục dựa trên mã tạo bản mẫu và tài liệu thiết kế trong repo, vì Figma MCP báo đã hết lượt truy vấn chi tiết. Biểu tượng dùng bộ Material cho bản thử nghiệm. API thật, xác thực thật và thiết bị vật lý chưa nằm trong kết quả này. [Bản mẫu và hướng dẫn Figma](../dgr/wireframes-figma/README.md)
