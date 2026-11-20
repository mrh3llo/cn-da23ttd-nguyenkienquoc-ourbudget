# 3.5. Xây dựng hệ thống Backend và RESTful API

*Bản thảo mô tả kiến trúc thiết kế. Bước 03 đã hiện thực nền SQL/PHP và worker email; luồng Google, icon và thông báo theo nghiệp vụ chưa được nghiệm thu hoàn chỉnh. Không sử dụng mô tả thiết kế này thay cho [báo cáo kiểm thử](../bugs/TEST-004-step03-foundation.md). [Đặc tả chi tiết](proposal-google-email-icons.md).*

## 3.5.1. Kiến trúc tổng thể

OurBudget được thiết kế theo kiến trúc ba tầng gồm ứng dụng di động, dịch vụ nghiệp vụ và cơ sở dữ liệu. Tầng ứng dụng sử dụng Flutter và ngôn ngữ Dart trên nền tảng Android, đảm nhiệm hiển thị, kiểm tra dữ liệu biểu mẫu và quản lý trạng thái giao diện bằng Provider. Ứng dụng trao đổi dữ liệu dưới dạng JSON qua HTTPS với RESTful API viết bằng PHP. Dịch vụ PHP là thành phần trực tiếp kết nối cơ sở dữ liệu MySQL, thực hiện xác thực, kiểm tra quyền truy cập và xử lý các quy tắc nghiệp vụ. Cách phân chia này tập trung các phép cập nhật dữ liệu tài chính tại máy chủ và cho phép giao diện hiển thị thông tin dựa trên trạng thái đã được xác nhận.

API được tổ chức trong cùng một ứng dụng máy chủ theo các phân hệ tài khoản, nguồn tiền, danh mục thu chi, giao dịch, ngân sách và báo cáo. Bộ định tuyến và lớp điều khiển tiếp nhận yêu cầu HTTP, còn lớp dịch vụ thực thi quy tắc nghiệp vụ và xác định phạm vi giao tác. Lớp truy cập dữ liệu sử dụng PDO với câu lệnh tham số hóa. Cơ sở dữ liệu sử dụng MySQL InnoDB để hỗ trợ giao tác, khóa hàng và ràng buộc toàn vẹn tham chiếu. Trong phạm vi phiên bản đầu, người dùng tự ghi nhận số dư và các khoản thu chi của ví tiền mặt, ví điện tử hoặc tài khoản ngân hàng. Ảnh hóa đơn thuộc hướng phát triển sau phiên bản đầu.

## 3.5.2. Giao tiếp API và kiểm soát truy cập

Các tài nguyên được định danh dưới tiền tố `/api/v1`. Đối với nghiệp vụ thêm khoản thu hoặc chi, ứng dụng gửi yêu cầu `POST /api/v1/transactions`. Sau khi máy chủ hoàn thành thao tác ghi, phản hồi `201 Created` cung cấp bản ghi giao dịch và số dư ví đã cập nhật để Provider làm mới giao diện. API sử dụng mã `401` khi phiên xác thực không hợp lệ, `404` khi tài nguyên nằm ngoài phạm vi truy cập hoặc không tồn tại, `409` khi có xung đột nghiệp vụ và `422` khi dữ liệu đầu vào không hợp lệ. Giao dịch chuyển tiền nội bộ được khởi tạo qua tài nguyên `/api/v1/transfers` và sử dụng cùng cơ chế xác nhận kết quả.

Máy chủ xác định tài khoản từ token phiên và kiểm tra quyền đối với từng ví, giao dịch, ngân sách hoặc danh mục liên quan. Danh mục được phân thành danh mục thu nhập và danh mục chi tiêu. Trong mỗi nhóm, danh mục mặc định do hệ thống cung cấp để dùng chung, còn danh mục tùy chỉnh thuộc về tài khoản đã tạo. Token có thời hạn và được thu hồi khi đăng xuất. Quy trình khôi phục mật khẩu sử dụng mã gửi qua email có thời hạn và chỉ dùng một lần. Mật khẩu được lưu dưới dạng giá trị băm bằng hàm `password_hash()` của PHP. Máy chủ giới hạn tần suất yêu cầu đăng nhập và khôi phục mật khẩu, đồng thời loại bỏ thông tin xác thực và nội dung giao dịch cá nhân khỏi nhật ký kỹ thuật.

## 3.5.3. Ghi nhận giao dịch và bảo toàn số dư

Máy chủ ghi bản ghi giao dịch và cập nhật số dư ví trong cùng một giao tác cơ sở dữ liệu. Các hàng ví liên quan được khóa theo thứ tự định danh nhất quán để duy trì số dư khi nhiều yêu cầu đến đồng thời. Khi sửa một giao dịch, máy chủ hoàn tác biến động cũ trước khi áp dụng biến động mới. Khi xóa giao dịch, máy chủ hoàn tác biến động đã ghi nhận. Với chuyển tiền nội bộ, hệ thống lưu một bản ghi liên kết ví nguồn và ví đích, đồng thời trừ tiền ở ví nguồn và cộng tiền ở ví đích trong cùng giao tác. Nếu một bước ghi thất bại, toàn bộ giao tác được hoàn tác. Ví hoặc danh mục đã có dữ liệu liên quan được chuyển sang trạng thái ngừng hoạt động để duy trì khả năng tra cứu lịch sử.

Số dư hiện tại của ví được khởi tạo bằng số dư đầu kỳ. Khi thay đổi số dư đầu kỳ, hệ thống điều chỉnh số dư hiện tại theo chênh lệch trong cùng giao tác để bảo toàn ảnh hưởng của các giao dịch trước đó. Thuộc tính `wallets_priority` biểu diễn thứ tự ví hoạt động của tài khoản, trong đó ví mặc định có giá trị 0 và các ví tiếp theo có giá trị tăng dần. Biểu mẫu nhập nhanh chọn theo thứ tự này; định danh tăng dần là tiêu chí phụ khi dữ liệu cũ còn trùng. Thao tác đổi mặc định hoặc thay đổi tập ví hoạt động chuẩn hóa thứ tự trong cùng giao tác.

Các giá trị tiền tệ, bao gồm số tiền giao dịch, số dư và hạn mức ngân sách, được lưu dưới dạng số nguyên `BIGINT` theo đơn vị đồng Việt Nam và trao đổi dưới dạng chuỗi số nguyên trong JSON. Khoản thu được lưu với dấu dương, khoản chi với dấu âm và chuyển nội bộ với số tiền dương kèm loại giao dịch riêng. Để tránh ghi trùng khi mất kết nối, ứng dụng gửi kèm mã định danh của thao tác tạo và dùng lại mã này khi gửi lại cùng yêu cầu. Máy chủ lưu kết quả ghi và trả lại kết quả đó khi nhận yêu cầu lặp có cùng nội dung.

## 3.5.4. Xác định trạng thái ngân sách và số liệu báo cáo

Ngân sách được thiết lập theo một danh mục chi hoặc cho tổng chi tiêu của tài khoản. Cả ngân sách và báo cáo sử dụng thời điểm phát sinh giao dịch theo múi giờ `Asia/Ho_Chi_Minh`. Kỳ thống kê bắt đầu từ đầu ngày thứ nhất và kết thúc ngay trước đầu ngày kế tiếp sau ngày cuối kỳ. Chi tiêu thực tế là tổng độ lớn của các khoản chi trong khoảng thời gian tương ứng. Giao dịch chuyển tiền nội bộ chỉ thay đổi phân bổ số dư giữa các ví nên được loại khỏi tổng thu, tổng chi và số liệu dùng để đánh giá ngân sách.

Tỷ lệ sử dụng ngân sách được xác định bằng tổng chi tiêu thực tế chia cho hạn mức dương rồi nhân với 100%. Mức sử dụng dưới 80% được xem là bình thường, từ 80% đến dưới 100% được xem là cảnh báo và từ 100% trở lên được xem là vượt mức. Việc kiểm tra trạng thái ngân sách được thực hiện sau khi khoản chi và số dư đã được ghi thành công. Nếu truy vấn ngân sách thất bại, máy chủ vẫn xác nhận đã lưu giao dịch và thông báo để ứng dụng tải lại trạng thái ngân sách. Các lần truy vấn tiếp theo sử dụng dữ liệu giao dịch đã cập nhật nhằm phản ánh chính xác ảnh hưởng của việc sửa, xóa hoặc chuyển kỳ phát sinh giao dịch.

## 3.5.5. Đề xuất mở rộng xác thực và thông báo

Hệ thống dự kiến bổ sung phương thức đăng ký và đăng nhập bằng Google. Ứng dụng chuyển ID token đến API qua HTTPS; máy chủ xác minh token và ánh xạ định danh Google với tài khoản nội bộ trước khi cấp phiên OurBudget. Quan hệ này được lưu riêng để tài khoản có thể sử dụng phương thức xác thực phù hợp. Trường hợp trùng email yêu cầu xác minh tài khoản hiện hữu trước khi liên kết nhằm bảo đảm quyền sở hữu dữ liệu.

Các thông báo đăng ký, đăng nhập và thay đổi khoản thu chi dự kiến được gửi đến email đăng ký của người dùng. Email chứa thông tin tài chính chỉ được gửi sau khi địa chỉ đã được xác minh. Máy chủ ghi sự kiện gửi thư trong cùng giao tác với thay đổi nghiệp vụ và thực hiện chuyển phát sau commit thông qua tiến trình nền. Cách tổ chức này cho phép thử gửi lại khi dịch vụ thư gặp lỗi mà vẫn giữ nguyên kết quả tài chính đã lưu. Khóa sự kiện hạn chế việc tạo trùng tác vụ khi ứng dụng gửi lại yêu cầu; khả năng chuyển phát còn phụ thuộc hệ thống email.

Biểu tượng danh mục và loại ví dự kiến sử dụng bộ Material Icons cục bộ với mã định danh ổn định. Logo thương hiệu được bổ sung từ tài nguyên có quyền sử dụng phù hợp. Phương án Flaticon API được xem xét khi cần mở rộng kho biểu tượng, với kết nối qua máy chủ và biểu tượng dự phòng để duy trì giao diện khi dịch vụ ngoài không khả dụng.
