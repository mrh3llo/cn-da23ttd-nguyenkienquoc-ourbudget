# BÁO CÁO RÀ SOÁT LỖ HỔNG HỆ THỐNG, NỘI DUNG VÀ LẬP TRÌNH (OURBUDGET)

> **Mục đích:** Tổng hợp toàn diện các điểm khuyết, mâu thuẫn thiết kế và rủi ro kỹ thuật được phát hiện qua quá trình đối chiếu chéo giữa **Báo cáo thực tập đồ án chuyên ngành** (`2. Báo cáo đề tài_3.pdf`), **Đề xuất kiến trúc hệ thống** (`system-architecture.md`) và **Quy chuẩn thiết kế giao diện** (`design_system_rules.md`). Tài liệu này làm cơ sở để hoàn thiện hồ sơ thiết kế trước khi tiến hành lập trình.

---

## 1. LỖ HỔNG VỀ KIẾN TRÚC HỆ THỐNG & CƠ SỞ DỮ LIỆU

Nhóm lỗ hổng này xuất phát từ việc các thực thể và thuộc tính trong thiết kế cơ sở dữ liệu (Mục 3.3 của Báo cáo) chưa đáp ứng đủ các luồng nghiệp vụ đã cam kết ở Sơ đồ Use-case (Mục 3.2) và Giao diện nguyên mẫu (Mục 3.4).

### 1.1. Thiếu cấu trúc lưu trữ cho nghiệp vụ Chuyển tiền nội bộ
* **Hiện trạng:** Sơ đồ Use-case (Hình 3.1) và màn hình Quản lý nguồn tiền (Hình 3.8) đều có chức năng *"Chuyển tiền nội bộ"* giữa các ví. Tuy nhiên, bảng `transactions` (Bảng 3.5) hiện chỉ có một khóa ngoại duy nhất là `wallets_id`.
* **Hệ quả:** Không thể lưu vết giao dịch chuyển từ ví nguồn sang ví đích. Nếu lưu thành 2 giao dịch thu/chi thông thường, hệ thống báo cáo sẽ tính nhầm tiền chuyển nội bộ thành thu nhập và chi tiêu thực tế, làm sai lệch biểu đồ thống kê và hạn mức ngân sách.
* **Giải pháp đề xuất:** Bổ sung trường phân loại giao dịch (ví dụ: `transactions_type` gồm `INCOME`, `EXPENSE`, `TRANSFER`) và khóa ngoại ví đích (`destination_wallet_id`) hoặc tạo cặp bản ghi liên kết được loại trừ khỏi các truy vấn báo cáo thu/chi và ngân sách.

### 1.2. Thiếu ràng buộc sở hữu và phân loại Thu/Chi trong bảng Danh mục
* **Hiện trạng:** Mục 3.1.2 cho phép người dùng tự thêm, sửa, xóa danh mục tùy chỉnh; màn hình Danh mục (Hình 3.8) cũng chia rạch ròi 2 nhóm *"Chi tiêu"* và *"Thu nhập"*. Tuy nhiên, bảng `expense_categories` (Bảng 3.4) hiện chỉ có 3 cột (`expensecate_id`, `expensecate_name`, `expensecate_icon`).
* **Hệ quả:**
  * Không phân biệt được danh mục nào hiển thị ở tab **Chi tiêu** và danh mục nào hiển thị ở tab **Thu nhập** trên `QuickTransactionBottomSheet`.
  * Thiếu khóa ngoại `users_id` (cho phép `NULL` đối với danh mục mặc định của hệ thống), dẫn đến việc người dùng A tạo danh mục mới sẽ làm lộ sang tài khoản của người dùng B.

### 1.3. Thiếu cơ chế đánh dấu Ví mặc định và Ngân sách tổng
* **Hiện trạng:**
  * Màn hình Nhập giao dịch nhanh (Hình 3.7) và Nguồn tiền (Hình 3.8) sử dụng khái niệm *"Tiền mặt · Mặc định"*, nhưng bảng `wallets` (Bảng 3.3) không có trường `wallets_is_default` để xác định ví nào được chọn sẵn.
  * Màn hình Trang chủ (Hình 3.8) hiển thị thẻ *"Ngân sách tháng"* (tổng hợp toàn bộ chi tiêu trong tháng), trong khi bảng `budgets` (Bảng 3.6) bắt buộc gắn với một `expensecate_id` cụ thể và không hỗ trợ ngân sách tổng.

### 1.4. Thiếu cấu trúc quản lý Phiên đăng nhập và Khôi phục mật khẩu
* **Hiện trạng:** Sơ đồ Use-case (Hình 3.1) có các chức năng *"Đăng nhập"*, *"Đăng xuất"* và *"Quên mật khẩu"*, nhưng cơ sở dữ liệu chưa có bảng lưu trữ phiên làm việc (`user_sessions` / `personal_access_tokens`) hoặc mã xác thực khôi phục mật khẩu (`password_resets`).
* **Hệ quả:** Không thể thu hồi quyền truy cập phía máy chủ khi người dùng bấm *"Đăng xuất"* hoặc khi thiết bị bị mất, cũng như không thể thực thi luồng đặt lại mật khẩu an toàn.

### 1.5. Sai lệch hệ quản trị cơ sở dữ liệu đích trong Mô hình vật lý
* **Hiện trạng:** Hình 3.5 (*Sơ đồ dữ liệu vật lý*) được xuất từ công cụ thiết kế với hệ quản trị đích là **SAP SQL Anywhere 17** (sử dụng các kiểu dữ liệu `long varchar`, `smallint`, `char(10)`), mâu thuẫn với cam kết sử dụng **MySQL** (`TEXT`, `BOOLEAN`, `VARCHAR(10)`) trong toàn bộ báo cáo và tài liệu kiến trúc.
* **Hệ quả:** Nếu chạy trực tiếp mã DDL sinh ra từ tệp PDM cũ lên MySQL sẽ phát sinh lỗi cú pháp hoặc sai lệch cơ chế lưu trữ chuỗi/boolean.

### 1.6. Bỏ ngỏ phạm vi tính năng "Ảnh hóa đơn"
* **Hiện trạng:** Mục 3.1.1 (*Bài học kinh nghiệm*) có nhắc đến *"ảnh hóa đơn"* như một trường thông tin bổ trợ nằm ở tầng tương tác mở rộng, nhưng cả Cơ sở dữ liệu (Mục 3.3) lẫn Giao diện Figma (Mục 3.4) đều không có trường lưu trữ hay thành phần UI tải ảnh lên.

---

## 2. LỖ HỔNG VỀ LẬP TRÌNH, BẢO MẬT & TOÀN VẸN DỮ LIỆU

Nhóm lỗ hổng này tập trung vào các rủi ro kỹ thuật trong quá trình viết mã Backend (PHP/MySQL) và Frontend (Flutter/Dart) nếu không được quy định chặt chẽ ngay từ đầu.

### 2.1. Xung đột dữ liệu đồng thời (Race Condition & Deadlock) khi cập nhật số dư
* **Vấn đề:** Khi người dùng thực hiện hai thao tác ghi/sửa/xóa giao dịch liên tiếp trong thời gian ngắn, nếu PHP đọc `wallets_current_balance` rồi mới tính toán và cập nhật lại mà không khóa bản ghi, số dư ví sẽ bị ghi đè sai lệch. Ngoài ra, khi chuyển tiền giữa Ví A và Ví B, nếu hai luồng khóa ví theo thứ tự ngược nhau sẽ gây ra lỗi khóa chết (*Deadlock*) trên MySQL InnoDB.
* **Giải pháp lập trình:** Bắt buộc sử dụng giao tác CSDL kết hợp câu lệnh khóa hàng `SELECT ... FOR UPDATE`. Khi chuyển tiền nội bộ, luôn sắp xếp `wallets_id` theo thứ tự tăng dần trước khi thực hiện khóa.

### 2.2. Thiếu cơ chế chống ghi trùng giao dịch (Idempotency)
* **Vấn đề:** Ứng dụng di động thường xuyên gặp tình trạng rớt mạng hoặc độ trễ cao ngay lúc người dùng bấm nút *"Lưu giao dịch"*. Nếu Flutter tự động gửi lại (*retry*) yêu cầu `POST /api/v1/transactions` mà không có mã định danh duy nhất cho yêu cầu đó, máy chủ sẽ ghi nhận giao dịch 2 lần và trừ tiền ví 2 lần.
* **Giải pháp lập trình:** Client sinh một chuỗi `UUID v4` gửi kèm trong Header (ví dụ: `Idempotency-Key`) cho mọi yêu cầu tạo giao dịch/chuyển tiền. Backend lưu khóa này để trả về kết quả cũ nếu nhận được yêu cầu trùng lặp.

### 2.3. Lỗ hổng phân quyền truy cập chéo dữ liệu (IDOR)
* **Vấn đề:** Khi nhận yêu cầu tạo giao dịch chứa `wallets_id` và `expensecate_id`, hoặc yêu cầu sửa/xóa `transactions_id`, nếu API PHP chỉ kiểm tra sự tồn tại của ID mà không đối chiếu với `users_id` lấy từ token phiên đăng nhập, kẻ tấn công có thể thao tác trái phép lên ví hoặc giao dịch của người dùng khác.
* **Giải pháp lập trình:** Mọi câu truy vấn `SELECT`, `UPDATE`, `DELETE` ở tầng Repository/DAO bắt buộc phải kèm điều kiện `WHERE users_id = :authenticated_user_id`.

### 2.4. Sai số dấu phẩy động (Floating-Point Precision) trong JSON
* **Vấn đề:** MySQL lưu tiền tệ bằng kiểu `DECIMAL(15,2)` để đảm bảo độ chính xác tuyệt đối, nhưng khi PHP chuyển đổi sang số thực (`float`) trong JSON và Dart đọc thành `double`, các phép tính cộng trừ nhiều giao dịch có thể phát sinh sai số lẻ thập phân (ví dụ: `25000.000000000004`).
* **Giải pháp lập trình:** Truyền giá trị tiền tệ qua JSON dưới dạng chuỗi thập phân chuẩn (ví dụ: `"25000.00"`) hoặc số nguyên đồng, xử lý tính toán chính xác bằng `BCMath` ở PHP và làm tròn/định dạng chuẩn ở Dart.

### 2.5. Lỗi logic dấu đại số khi tính tỷ lệ vượt ngân sách
* **Vấn đề:** Theo quy ước ở Mục 3.3.1, các khoản chi tiêu được lưu với giá trị **âm** ($\text{transactions\_amount} < 0$). Trong khi đó, công thức kiểm tra ngân sách ở Mục 3.2.2 viết là $R = \frac{\sum \text{Amount}}{B}$. Nếu lập trình viên cộng trực tiếp cột `transactions_amount` trong SQL mà không lấy trị tuyệt đối (`ABS()`), tổng chi $\sum \text{Amount}$ sẽ mang dấu âm, dẫn đến tỷ lệ $R < 0\%$ và hệ thống cảnh báo vượt ngân sách ($R \ge 80\%$) **không bao giờ kích hoạt**.
* **Giải pháp lập trình:** Sử dụng hàm `SUM(ABS(transactions_amount))` (kèm điều kiện `transactions_amount < 0` và loại trừ giao dịch chuyển nội bộ) khi tính tổng chi thực tế.

### 2.6. Thiếu quy tắc hoàn tác số dư khi Sửa/Xóa giao dịch và Ràng buộc xóa tài nguyên
* **Vấn đề:**
  * Khi người dùng **sửa** một giao dịch (ví dụ: đổi số tiền từ `-50.000` thành `-80.000`, hoặc đổi từ Ví Tiền mặt sang Ví Ngân hàng), logic cập nhật không chỉ đơn thuần là ghi đè bản ghi mà phải hoàn tác ảnh hưởng số dư cũ trên ví cũ và áp dụng ảnh hưởng mới trên ví mới trong cùng một giao tác.
  * Khi người dùng **xóa** một ví tiền hoặc danh mục đã từng phát sinh giao dịch, nếu dùng xóa cứng (`DELETE`), khóa ngoại sẽ gây lỗi hoặc làm mất lịch sử tài chính.
* **Giải pháp lập trình:** Áp dụng xóa mềm (`is_active = false`) cho ví và danh mục đã có dữ liệu liên kết; chặn xóa cứng ở tầng CSDL bằng ràng buộc `ON DELETE RESTRICT`.

### 2.7. Rủi ro hủy nhầm giao dịch nếu bước kiểm tra ngân sách gặp lỗi
* **Vấn đề:** Trong Mục 3.2.2, luồng ghi giao dịch và kiểm tra ngân sách được mô tả nối tiếp nhau. Nếu gộp chung cả hai vào một khối xử lý lỗi, sự cố truy vấn ở bảng `budgets` có thể làm `Rollback` luôn khoản chi tiêu vừa nhập của người dùng.
* **Giải pháp lập trình:** Thực hiện `COMMIT` việc lưu giao dịch và cập nhật số dư ví trước. Sau đó mới gọi hàm kiểm tra trạng thái ngân sách; nếu bước này gặp lỗi, hệ thống vẫn trả về mã thành công cho giao dịch kèm cờ báo hiệu Client tải lại trạng thái ngân sách sau.

### 2.8. Chưa chuẩn hóa múi giờ (Timezone) và biên thời gian kỳ báo cáo
* **Vấn đề:** Bảng `budgets` lưu `budgets_start` và `budgets_end` theo kiểu `DATE`, trong khi bảng `transactions` lưu `transactions_occured_at` theo kiểu `DATETIME`. Nếu máy chủ đặt múi giờ UTC còn ứng dụng chạy ở múi giờ Việt Nam ($\text{UTC}+7$), các giao dịch phát sinh từ `00:00` đến `06:59` sáng ngày đầu tháng sẽ bị tính nhầm sang tháng trước.
* **Giải pháp lập trình:** Thống nhất múi giờ chuẩn `Asia/Ho_Chi_Minh` ($\text{UTC}+7$) trên toàn bộ cấu hình PHP và MySQL; quy định rõ biên thời gian truy vấn từ `00:00:00` ngày bắt đầu đến `23:59:59` ngày kết thúc.

### 2.9. Lỗ hổng bảo mật xác thực và ghi nhật ký (Logging)
* **Vấn đề:** Báo cáo chưa quy định thuật toán băm mật khẩu, cơ chế chống dò mật khẩu (*Brute-force*) và quy tắc lọc dữ liệu nhạy cảm khi ghi log lỗi.
* **Giải pháp lập trình:** Bắt buộc sử dụng `password_hash()` (Bcrypt/Argon2id) của PHP; áp dụng giới hạn tần suất (*Rate Limiting*) cho các endpoint đăng nhập và quên mật khẩu; tuyệt đối không ghi mật khẩu, token hoặc nội dung giao dịch cá nhân vào tệp log kỹ thuật.

---

## 3. LỖ HỔNG VỀ NỘI DUNG & TÍNH NHẤT QUÁN TÀI LIỆU BÁO CÁO

Nhóm lỗ hổng này liên quan đến sự đồng bộ câu chữ, sơ đồ, công thức và cấu trúc các chương còn trống trong quyển báo cáo đồ án.

### 3.1. Xung đột quy ước RESTful API và mã trạng thái HTTP
* **Hiện trạng:** Mục 3.2.2 và Hình 3.2 trong Báo cáo đang minh họa endpoint là `POST /api/transactions/create` và trả về mã `200` khi tạo mới, cùng mã lỗi chung `500`. Trong khi đó, kiến trúc chuẩn hóa ở `system-architecture.md` sử dụng `POST /api/v1/transactions`, trả về `201 Created` và phân tách rõ các mã lỗi `401` (chưa xác thực), `404` (không tìm thấy), `409` (xung đột nghiệp vụ) và `422` (dữ liệu đầu vào không hợp lệ).
* **Cần khắc phục:** Cập nhật lại Hình 3.2 và văn bản Mục 3.2.2 trong báo cáo để khớp với hợp đồng API phiên bản `v1`.

### 3.2. Thiếu hụt các mục hiện thực hóa và kiểm thử trong Báo cáo
* **Hiện trạng:**
  * **Mục 3.4.3** (trang 43) đang để trống tiêu đề mà chưa có nội dung (cần bổ sung *Luồng điều hướng người dùng - User Flow*).
  * **Mục 3.5** (*Xây dựng hệ thống Backend và RESTful API*, trang 45) mới chỉ có tên tiêu đề.
  * Báo cáo hoàn toàn thiếu **Mục 3.6** (*Phát triển ứng dụng di động Frontend với Flutter/Dart*) và **Mục 3.7** (*Kế hoạch và kịch bản kiểm thử*).
  * **Chương 4** (*Kết quả nghiên cứu*) và **Chương 5** (*Kết luận và hướng phát triển*) hiện mới chỉ có đoạn văn bản hướng dẫn mẫu.

### 3.3. Sai sót nhỏ về công thức toán học và thuật ngữ/chính tả
* **Công thức tỷ lệ ngân sách:** Tại trang 31 (Mục 3.2.1), công thức được viết là $R = (S/B) \times 100\%$, nhưng sang trang 33 (Mục 3.2.2) lại viết thiếu nhân phần trăm là $R = \left(\frac{\sum \text{Amount}}{B}\right)$ và chưa có dấu giá trị tuyệt đối cho khoản chi âm. Cần thống nhất thành:
  $$R = \frac{|\sum \text{Amount}|}{B} \times 100\%$$
* **Lỗi chính tả và thuật ngữ trong đề mục:**
  * Mục 2.2 và Mục 3.4 viết sai chính tả từ *"trải nghiệm"* thành *"trãi nghiệm"*.
  * Mục 3.2 viết sai từ *"chức năng"* thành *"chứng năng"*.
  * Mục 3.2.1 và 3.2.2 dùng từ *"cảnh cáo"* (*"Cảnh cáo vượt mức ngân sách"*), nên sửa thành *"cảnh báo"* để đúng ngữ cảnh phần mềm tài chính và đồng bộ với Bảng 3.7 (*Màu cảnh báo*).

---

## 4. LỘ TRÌNH KHẮC PHỤC ĐỀ XUẤT (ACTION CHECKLIST)

Để giải quyết triệt để các lỗ hổng trên trước khi viết mã nguồn, cần thực hiện tuần tự 4 bước sau:

| Thứ tự | Hạng mục xử lý | Sản phẩm đầu ra cần chốt | Trách nhiệm |
| :---: | :--- | :--- | :--- |
| **1** | **Chốt phạm vi & Dữ liệu** | Chốt bỏ hoặc giữ tính năng *Ảnh hóa đơn*; bổ sung các cột/bảng còn thiếu (`is_default`, `type`, `transfers`, `sessions`, ngân sách tổng) và xuất mã SQL chuẩn **MySQL InnoDB**. | Kiến trúc sư / Sinh viên |
| **2** | **Chốt Hợp đồng API (`v1`)** | Viết tài liệu đặc tả chi tiết toàn bộ Endpoint (`/api/v1/...`), định dạng JSON chuỗi cho tiền tệ, mã lỗi HTTP (`401`, `404`, `409`, `422`) và cơ chế `Idempotency-Key`. | Backend & Frontend |
| **3** | **Lập trình theo quy chuẩn** | Triển khai PHP API (áp dụng khóa `FOR UPDATE`, `ABS()` khi tính ngân sách, kiểm tra quyền sở hữu `users_id`) và ứng dụng Flutter (tuân thủ `design_system_rules.md`). | AI Coding Agent / Dev |
| **4** | **Đồng bộ Tài liệu Báo cáo** | Sửa lỗi chính tả/công thức ở Chương 2–3, cập nhật Hình 3.2 và Hình 3.5 theo MySQL, viết hoàn thiện Mục 3.4.3, 3.5, 3.6, 3.7 cùng Chương 4 và Chương 5. | Sinh viên thực hiện |