# Kiểm thử phần CSDL của bước 03

Ngày thực hiện **20/11/2026**. Trạng thái **hoàn thành phần SQL và hướng dẫn cài đặt**, chưa nghiệm thu toàn bộ bước 03 PHP/MySQL và HTTP. Phạm vi theo yêu cầu trước mắt của người dùng. [Bộ SQL và hướng dẫn](../database/README.md) · [Kiến trúc chốt](../docs/final-system-architecture.md) · [Roadmap](../docs/implementation-roadmap.md).

## Môi trường và cách chạy

Windows, MySQL Community Server **8.0.46**, PHP CLI **8.2.12**, PDO MySQL. Dùng MySQL kiểm thử riêng trên `127.0.0.1:13316`, database `ourbudget_test`, không sử dụng dữ liệu của dịch vụ MySQL80 hiện có. Thư mục runtime nằm trong `graphify-out/` bị Git ignore. Phiên kết nối đặt `+07:00`, strict SQL mode và utf8mb4.

Chạy `php src/database/tests/verify.php` với biến `OURBUDGET_DB_PORT=13316`. Script import schema và hai seed trên database trống, kiểm tra lỗi theo mã MySQL cụ thể và rollback các phép ghi kiểm thử. Kết quả **34/34 đạt**. Hướng dẫn chạy lại trên máy người dùng nằm trong README, mặc định cổng 3306.

Đã chạy thêm đúng đường import `cmd /c 'mysql ... < file.sql'` trong hướng dẫn trên database trống thứ hai `ourbudget_cli_test`: cả ba script trả exit code 0, có 10 bảng và số dư 55.000/30.000/250.000 đ. `php -l` đạt và `git diff --check` không phát hiện lỗi whitespace. Chưa thao tác import qua giao diện Workbench.

## Kết quả

| Nhóm | Kết quả thực tế |
| --- | --- |
| Import mới | Cả ba script thành công, tạo 10 bảng InnoDB |
| Encoding, múi giờ, mật khẩu | Đọc lại đúng tiếng Việt, session +07:00, PHP xác minh được hash của mật khẩu demo |
| Dữ liệu thử | Hai tài khoản, danh mục dùng chung, ví mặc định đúng thứ tự; số dư A1/A2 là 55.000/30.000 đ |
| Báo cáo mẫu | Tổng chi A trong tháng 11 là 25.000 đ, không cộng chuyển nội bộ hoặc khoản thu của B |
| Cách ly ví ở mức FK | Từ chối dùng ví B cho giao dịch A và chuyển từ A đến ví B, lỗi 1452 |
| Hình dạng giao dịch | Từ chối chuyển cùng ví, thiếu ví đích, chi dương, thu bằng 0, thiếu danh mục hoặc có cả hai loại danh mục, lỗi 3819 |
| Bảo toàn lịch sử | Từ chối danh mục không tồn tại; xóa ví/danh mục có tham chiếu bị chặn; ngừng hoạt động ví vẫn giữ giao dịch |
| Kiểm tra dữ liệu | Chặn email trùng khác hoa/thường, hạn mức không dương, kỳ đảo và trạng thái hoạt động ngoài 0/1 |
| Tiền lớn | Ghi/đọc chính xác BIGINT tối đa `9223372036854775807` |
| Chống ghi trùng | Cùng người dùng/thao tác/khóa bị từ chối; tài khoản khác được dùng cùng khóa |
| Rollback | Sau lỗi FK giữa giao tác, gọi rollback phục hồi giao dịch, số dư và khóa chống trùng |
| Thời hạn xác thực | Chặn phiên và mã khôi phục có ngày hết hạn trước ngày tạo |

## Giới hạn và phần cần tiếp tục

Chưa có API HTTP thật, kết nối từ Android, kiểm thử ghi đồng thời/deadlock hoặc phát lại phản hồi idempotency qua HTTP. PDO đã kết nối và chạy SQL thật nhưng không đồng nghĩa đã có môi trường API hoàn chỉnh. Chưa kiểm thử đầy đủ biên kỳ và ngưỡng 80%/100%; các ca này thuộc bước ngân sách.

Quyền dùng danh mục riêng/hệ thống, quyền đọc theo người dùng, trạng thái tài nguyên khi tạo giao dịch, cập nhật số dư, thu hồi phiên và tiêu thụ mã khôi phục một lần thuộc dịch vụ PHP. SQL hỗ trợ lưu trạng thái và khóa nhưng không tự thực hiện các nghiệp vụ này. Chưa coi kết quả FK cách ly ví là nghiệm thu cách ly toàn bộ hai tài khoản.

PDM đã được đối chiếu ở mức dữ liệu XML và còn đích SAP SQL Anywhere 17. ERD/PDM, hình trong Word và từ điển dữ liệu chưa được cập nhật sang schema mới hoặc nghiệm thu bằng PowerDesigner. Những khác biệt được liệt kê trong README. Bộ SQL là schema khởi tạo MySQL theo kiến trúc chốt, không phải migration từ dữ liệu SQL Anywhere.

Lần khởi động MySQL thử trong thư mục có tên bắt đầu bằng dấu chấm gặp lỗi mở undo tablespace. Chuyển sang thư mục runtime mới có tên thường thì server khởi động và kiểm thử thành công. Sự cố này không yêu cầu thay đổi SQL hay dịch vụ MySQL80 của người dùng.
