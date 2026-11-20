# Cài đặt CSDL MySQL cho OurBudget

**Bản hiện hành bước 03:** bắt buộc chạy `004_step03_foundation.sql` sau baseline/seed. Kết quả là 14 bảng, thứ tự ví tăng dần với mặc định 0, identity Google, xác minh email và outbox. SQL 001–003 được giữ nguyên để kiểm thử đường nâng cấp. Không dùng riêng 001–003 cho backend hiện tại. [Hướng dẫn nâng cấp](#nâng-cấp-lên-bước-03) · [Backend PHP](../backend/README.md).

Đây là phần CSDL của bước 03, dựa trên [kiến trúc đã chốt](../docs/final-system-architecture.md) và [roadmap](../docs/implementation-roadmap.md). Bộ SQL hỗ trợ dựng mới và nâng cấp từ baseline 001. Flutter kết nối API PHP, còn PHP kết nối MySQL bằng PDO. Không đưa thông tin đăng nhập MySQL vào ứng dụng Android.

## Nâng cấp lên bước 03

**Dựng mới:** chạy 001 → 002 → 003 (chỉ nếu cần demo) → 004. Khi không dùng demo, chạy 001 → 002 → 004. Chỉ sau 004 mới chạy backend. Không import 003 sau 004 vì seed lịch sử còn sử dụng quy tắc ưu tiên cũ.

**Nâng cấp database đã có 001:** dừng API/worker, sao lưu database bằng MySQL Workbench hoặc mysqldump; chạy 004 đúng một lần. Không chạy lại 001–003 và không dùng `--force`. Trước khi chạy, kiểm tra database đúng baseline: có 10 bảng, chưa có `users.email_verified_at`, chưa có `schema_migrations`. Migration này dành riêng cho phiên bản trước sử dụng ưu tiên giảm dần. Nếu bạn tự sửa dữ liệu thành thứ tự tăng dần trước đó, không chạy chuyển đổi thứ tự này trực tiếp; cần đối chiếu ví mặc định của từng tài khoản trước.

Trong MySQL client đã `USE ourbudget`, chạy (sửa đường dẫn theo checkout):

```sql
SOURCE D:/.system/documents/School/DACN/git/src/database/004_step03_foundation.sql;
SELECT * FROM schema_migrations;
SELECT users_id, wallets_id, wallets_priority FROM wallets
WHERE wallets_is_active = 1 ORDER BY users_id, wallets_priority, wallets_id;
```

Migration bảo toàn ID, lịch sử và số dư; xếp lại thứ tự cũ bằng ROW_NUMBER để ví mặc định cũ trở thành 0. Ví hoạt động và không hoạt động được chuẩn hóa riêng. Email cũ không tự được xác minh; mật khẩu nullable để chuẩn bị Google-only. `active_priority` là cột sinh phục vụ unique `(users_id, active_priority)`, không phải thuộc tính người dùng nhập. Unique chặn hai ví hoạt động cùng thứ tự; tính liên tục 0..N−1 khi thêm/đổi mặc định/ngừng ví vẫn do service bước 05 bảo đảm. Khi đổi thứ tự, khóa các ví của tài khoản và dùng vùng thứ tự tạm không trùng trước khi gán lại 0..N−1 trong cùng giao tác.

MySQL DDL tự commit: migration không thể rollback toàn bộ bằng ROLLBACK. Nếu bất kỳ lệnh DDL lỗi, dừng và phục hồi backup vào database khác để thử lại; không tiếp tục phục vụ trên schema dở dang. `schema_migrations` chỉ được ghi ở cuối khi mọi lệnh trước đó thành công. Backend trả 503 nếu thiếu marker. Kiểm tra file đầy đủ và quyền DDL trước khi chạy. Không dùng migration 004 cho PDM SAP SQL Anywhere hoặc một database khác tự thiết kế.

## Tệp và thứ tự chạy

Xem [giải thích schema và ba bảng bổ sung so với ERD](schema-explained.md) để hiểu vai trò, các trường và quan hệ của `auth_sessions`, `password_resets`, `idempotency_keys`.

| Tệp | Mục đích |
| --- | --- |
| `001_schema.sql` | Tạo 10 bảng InnoDB, khóa ngoại, chỉ mục và CHECK |
| `002_seed_system.sql` | Ba loại ví, ba danh mục thu và bốn danh mục chi dùng chung |
| `003_seed_demo.sql` | Dữ liệu phát triển cho hai tài khoản độc lập, ba ví, giao dịch và ngân sách |
| `004_step03_foundation.sql` | Nâng baseline lên 14 bảng, ưu tiên tăng dần, Google identity, xác minh email và outbox |
| `tests/verify.php` | Dựng schema từ ba tệp SQL trong database thử trống và kiểm tra ràng buộc bằng PDO |
| `tests/verify-foundation.php` | Chạy các kiểm tra baseline, nâng cấp 004 rồi kiểm tra outbox/identity/thứ tự ví |
| `model-reference.md` | Cột, chỉ mục và khóa ngoại hiện hành xuất từ metadata MySQL |

Chạy `001`, rồi `002`, tùy chọn `003` trong môi trường phát triển và cuối cùng bắt buộc `004`. Các script không xóa database/bảng và không dùng `IF NOT EXISTS` hoặc upsert để che lỗi nhập lại. Mỗi seed chạy trong một giao tác. Nếu seed lỗi, dừng import và `ROLLBACK` hoặc ngắt kết nối; không tiếp tục chạy những câu lệnh còn lại. DDL MySQL có implicit commit, nên import schema thất bại có thể để lại một số bảng. Khi đó sửa nguyên nhân và dùng một database trống mới để thử lại.

## Yêu cầu môi trường

- MySQL Server **8.0.16 trở lên**, InnoDB, `utf8mb4`. Đã kiểm thử bằng MySQL Community Server **8.0.46** trên Windows. Không coi MariaDB đi kèm XAMPP là cùng đích kiểm thử.
- MySQL Workbench hoặc chương trình `mysql.exe`. Khi cài MySQL Server trên Windows, ghi lại cổng dịch vụ, tên tài khoản quản trị và mật khẩu của bạn.
- PHP CLI và `pdo_mysql` nếu chạy bộ kiểm thử. Đã kiểm thử với PHP **8.2.12**.

Kiểm tra bằng PowerShell:

```powershell
mysql --version
php --version
php -m | Select-String 'PDO|pdo_mysql'
Get-Service -Name '*MySQL*'
```

Nếu `mysql` chưa nằm trong PATH, thêm thư mục `bin` của bản cài MySQL, ví dụ `C:\Program Files\MySQL\MySQL Server 8.0\bin`, rồi mở terminal mới. Dùng MySQL Server thật để chạy kiểm thử; parser SQL hoặc SQLite không thay thế kiểm tra InnoDB/CHECK.

## Cách 1 — MySQL Workbench

1. Mở kết nối đến MySQL Server, thường là `127.0.0.1:3306`, bằng tài khoản có quyền tạo database và bảng.
2. Mở SQL tab và thực hiện:

   ```sql
   CREATE DATABASE ourbudget CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
   USE ourbudget;
   SELECT VERSION(), DATABASE();
   ```

3. Trong SCHEMAS, nhấp đúp `ourbudget` để chọn schema mặc định. Mở `src/database/001_schema.sql` bằng **File → Open SQL Script**, kiểm tra schema đang chọn rồi thực thi toàn bộ tệp.
4. Kiểm tra Action Output không có lỗi, rồi lần lượt mở/chạy `002_seed_system.sql`, tùy chọn `003_seed_demo.sql` nếu cần dữ liệu thử, và cuối cùng `004_step03_foundation.sql`. Dừng ngay nếu có lỗi. Không chạy lại script đã thành công trên cùng database.
5. Refresh SCHEMAS và chạy các truy vấn xác nhận bên dưới.

Script không chứa `USE` cố định để có thể dùng cùng bộ SQL cho `ourbudget` và một database thử riêng. Luôn kiểm tra `SELECT DATABASE()` trước khi chạy.

## Cách 2 — Dòng lệnh Windows

Mở PowerShell tại thư mục gốc repository. Thay tên tài khoản, cổng và database cho đúng máy của bạn. `-p` yêu cầu nhập mật khẩu trực tiếp, không ghi mật khẩu vào câu lệnh.

```powershell
mysql -h 127.0.0.1 -P 3306 -u root -p --execute="CREATE DATABASE ourbudget CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
```

Chạy từng lệnh sau và chỉ chuyển sang lệnh kế tiếp khi `$LASTEXITCODE` bằng `0`. `cmd /c` ở đây cung cấp phép chuyển hướng `<` mà Windows PowerShell không hỗ trợ; nó không thao tác xóa hay di chuyển tệp.

```powershell
cmd /c 'mysql -h 127.0.0.1 -P 3306 -u root -p --default-character-set=utf8mb4 ourbudget < src/database/001_schema.sql'
$LASTEXITCODE
cmd /c 'mysql -h 127.0.0.1 -P 3306 -u root -p --default-character-set=utf8mb4 ourbudget < src/database/002_seed_system.sql'
$LASTEXITCODE
cmd /c 'mysql -h 127.0.0.1 -P 3306 -u root -p --default-character-set=utf8mb4 ourbudget < src/database/003_seed_demo.sql'
$LASTEXITCODE
cmd /c 'mysql -h 127.0.0.1 -P 3306 -u root -p --default-character-set=utf8mb4 ourbudget < src/database/004_step03_foundation.sql'
$LASTEXITCODE
```

Không thêm `--force`. Trong chế độ batch, client dừng khi gặp lỗi và kết nối đóng sẽ rollback seed chưa commit. Không dùng PowerShell `Get-Content | mysql` vì có thể đổi encoding tiếng Việt. Nếu database tên `ourbudget` đã tồn tại, chọn tên database mới và thay tên trong các lệnh, không xóa dữ liệu cũ để tiếp tục.

## Xác nhận sau import

```sql
USE ourbudget;
SET SESSION time_zone = '+07:00';
SHOW TABLES;
SELECT TABLE_NAME, ENGINE, TABLE_COLLATION
FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE();
SELECT users_id, users_name, users_email FROM users;
SELECT wallets_id, users_id, wallets_name, wallets_current_balance FROM wallets;
SELECT transactions_type, SUM(transactions_amount) AS total_vnd
FROM transactions WHERE users_id = 1 GROUP BY transactions_type;
```

Có 14 bảng sau 004, đều InnoDB (10 bảng nếu chỉ mới chạy baseline). Sau seed demo và migration, ví A1 là **55.000 đ**, A2 là **30.000 đ**, B1 là **250.000 đ**, thứ tự tương ứng 0, 1, 0. Tài khoản A có khoản chi `-25000` và khoản chuyển `20000`; khoản chuyển không tính vào tổng thu/chi. Dữ liệu demo nằm ở tháng 11/2026, nên cần chọn kỳ này khi kiểm thử báo cáo.

Hai tài khoản ứng dụng là `demo.a@ourbudget.test` và `demo.b@ourbudget.test`, cùng mật khẩu công khai dành riêng cho thử nghiệm `OurBudgetTest!2026`. SQL lưu hash bcrypt đã kiểm tra bằng PHP `password_verify()`. Đây không phải tài khoản đăng nhập MySQL. Chưa có API đăng nhập ở phần việc này. Không import seed demo vào môi trường thật.

## Cấu trúc và quyết định dữ liệu

| Bảng | Nội dung và ràng buộc chính |
| --- | --- |
| `users` | Tên, email duy nhất không phân biệt hoa/thường, hash mật khẩu, điện thoại, URL avatar tùy chọn, trạng thái và thời gian |
| `auth_sessions` | Token băm `BINARY(32)`, chủ sở hữu, thời hạn, thời điểm thu hồi |
| `password_resets` | Token khôi phục băm, thời hạn và `used_at` cho việc tiêu thụ một lần tại API |
| `wallet_categories` | Loại nguồn tiền hệ thống; ngân hàng/ví điện tử được nhập thủ công |
| `wallets` | Chủ sở hữu, số dư đầu kỳ/hiện tại, độ ưu tiên và trạng thái |
| `income_categories`, `outcome_categories` | Danh mục riêng hoặc dùng chung khi `users_id IS NULL`, có trạng thái hoạt động |
| `transactions` | Thu, chi hoặc một dòng chuyển nội bộ; hai FK ví ghép với `users_id` để bắt buộc cùng tài khoản |
| `budgets` | Hạn mức dương, kỳ WEEK/MONTH, ngày bắt đầu/kết thúc; `outcome_id IS NULL` là ngân sách tổng |
| `idempotency_keys` | Unique theo người dùng, thao tác, khóa; SHA-256 nội dung yêu cầu và JSON kết quả `201` để phát lại |

Khóa chính dùng `BIGINT UNSIGNED AUTO_INCREMENT`, các khóa ngoại cùng kiểu. Tiền dùng **BIGINT có dấu**, đơn vị đồng; khoản thu/chuyển dương, khoản chi âm. Loại giao dịch quy định danh mục và ví đích được phép có mặt, kể cả trường hợp NULL. Giá trị khoản chi nhỏ nhất được nhận là `-9223372036854775807` để độ lớn vẫn nằm trong miền số nguyên có dấu 64 bit. API cần kiểm tra tràn trước khi cộng/trừ số dư. Truyền tiền qua JSON bằng chuỗi số nguyên; PHP chạy 64 bit, không chuyển tiền sang float. Tổng nhiều giao dịch có thể vượt BIGINT, nên giữ kết quả SUM dạng chuỗi số chính xác và kiểm tra miền trước khi ép kiểu.

Mọi FK dùng hành vi RESTRICT mặc định của InnoDB. Không khai báo CASCADE/SET NULL để bảo toàn lịch sử. Khi ví hoặc danh mục đã được tham chiếu, API chuyển trạng thái hoạt động thay cho xóa vật lý. Chỉ mục hỗ trợ lịch sử theo tài khoản/ngày, ví nguồn/đích, lọc chi theo danh mục và tìm ví mặc định theo ưu tiên **tăng dần**, ID tăng dần sau migration 004.

`DATETIME` lưu giờ Việt Nam. Mỗi kết nối PHP phải đặt `SET SESSION time_zone = '+07:00'`; chỉ chạy lệnh này lúc import không cấu hình các kết nối về sau. PHP đặt `date_default_timezone_set('Asia/Ho_Chi_Minh')`. Offset MySQL tránh yêu cầu nạp timezone tables trên Windows. API nhận ISO 8601 có offset, chuyển về giờ Việt Nam rồi mới lưu. Ngân sách đọc từ `budgets_start 00:00:00` đến trước ngày kế tiếp của `budgets_end`.

PDM hiện tại vẫn là SAP SQL Anywhere 17. SQL này được viết trực tiếp theo kiến trúc chốt, **không phải bản export từ PDM**. Khi đồng bộ ERD/PDM và chương từ điển dữ liệu, cần đổi ID `CHAR(10)` thành kiểu ID trên, thêm quan hệ sở hữu danh mục và các bảng xác thực/chống ghi trùng; bổ sung loại giao dịch, bỏ `wal_wallets_id` trùng với `destination_wallet_id`; đổi `transactions_occured_at` thành `transactions_occurred_at`, `transactions_created_time` thành `transactions_created_at`, `users_phoneNumber` thành `users_phone_number`; đổi hạn mức DECIMAL thành BIGINT và bỏ `income_id` khỏi budgets. `users_role` cũ chưa có nghiệp vụ phân quyền trong UC1–UC24 nên chưa đưa vào schema. Tệp PowerDesigner chưa được sửa và chưa có migration dữ liệu từ mô hình cũ.

## Trách nhiệm của API khi triển khai tiếp

Schema không tự ghi số dư bằng trigger. Dịch vụ PHP phải khóa các ví theo `wallets_id` tăng dần, kiểm tra chủ sở hữu/trạng thái, ghi giao dịch cùng số dư trong một giao tác. Khi sửa/xóa, khóa bản ghi hiện tại, hoàn tác ảnh hưởng cũ rồi áp dụng ảnh hưởng mới. Khi tạo ví, gán số dư hiện tại bằng số dư đầu kỳ; khi đổi số dư đầu kỳ, cộng phần chênh lệch trong giao tác.

Khóa ngoại chỉ xác nhận danh mục tồn tại. API phải kiểm tra `users_id = người dùng hiện tại OR users_id IS NULL`, đúng loại và đang hoạt động trước khi ghi giao dịch/ngân sách; chỉ chủ sở hữu được sửa danh mục riêng và không được chuyển chủ sở hữu. Danh mục hệ thống chỉ đọc. MySQL không cung cấp cách ly đọc dữ liệu theo phiên ứng dụng bằng các FK này; mọi truy vấn API cần bộ lọc người dùng lấy từ token.

Token ngẫu nhiên được lưu dưới dạng SHA-256 nhị phân 32 byte (`hash('sha256', $token, true)` hoặc `UNHEX` khi kiểm thử). API xác nhận `expires_at`, `revoked_at` và `used_at`; tiêu thụ mã khôi phục bằng cập nhật có điều kiện trong giao tác, không chỉ SELECT rồi UPDATE rời rạc. Giới hạn tần suất đăng nhập/khôi phục thuộc bước 04.

Ghi bản ghi idempotency và giao dịch/số dư trong cùng giao tác. Unique chỉ bảo đảm không có hai hàng cùng khóa; API vẫn phải chuẩn hóa nội dung trước khi băm, xử lý đua ghi, so sánh hash và trả `409` khi nội dung khác. JSON phản hồi phải giữ tiền dạng chuỗi. Giữ kết quả phát lại ngay cả khi giao dịch gốc đã được sửa/xóa; vì vậy không tạo FK từ kết quả idempotency tới giao dịch. Chính sách hết hạn khóa chưa được chốt, nên chưa tự động dọn khóa.

Ngày bắt đầu/kết thúc và hạn mức đã có CHECK cơ bản. Quy ước đầu tuần, kỳ tháng đầy đủ, chính sách ngân sách trùng/chồng lấn và kiểm tra quyền danh mục được chốt ở bước 08; hiện schema cho phép các kỳ chồng lấn. Báo cáo/ngân sách chỉ tổng hợp `INCOME` hoặc `EXPENSE` tương ứng và loại `TRANSFER`.

## Chuẩn bị tài khoản MySQL cho PHP

Dùng tài khoản quản trị để import, sau đó tạo tài khoản riêng cho API. Thay chuỗi mật khẩu mẫu bên dưới bằng mật khẩu riêng trước khi chạy; không lưu mật khẩu thật vào Git.

```sql
CREATE USER 'ourbudget_app'@'127.0.0.1' IDENTIFIED BY 'THAY_BANG_MAT_KHAU_RIENG';
GRANT SELECT, INSERT, UPDATE, DELETE ON ourbudget.* TO 'ourbudget_app'@'127.0.0.1';
```

PDO sau này dùng `mysql:host=127.0.0.1;port=3306;dbname=ourbudget;charset=utf8mb4`, đọc mật khẩu từ cấu hình môi trường và bật exception, tắt emulated prepares. Không cấp quyền DDL cho tài khoản API. Chỉ mục và ràng buộc không thay thế kiểm tra quyền trong PHP.

## Chạy lại kiểm thử CSDL

Tạo một database thử **trống**, tên kết thúc bằng `_test`. Bộ kiểm thử tự import 001–004 và từ chối chạy khi database có bảng, vì vậy không import thủ công trước bước này.

```powershell
mysql -h 127.0.0.1 -P 3306 -u root -p --execute="CREATE DATABASE ourbudget_test CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"
$env:OURBUDGET_DB_HOST = '127.0.0.1'
$env:OURBUDGET_DB_PORT = '3306'
$env:OURBUDGET_DB_NAME = 'ourbudget_test'
$credential = Get-Credential -UserName root -Message 'Tai khoan MySQL cho database thu'
$env:OURBUDGET_DB_USER = $credential.UserName
$env:OURBUDGET_DB_PASSWORD = $credential.GetNetworkCredential().Password
try {
    php src/database/tests/verify-foundation.php
} finally {
    Remove-Item Env:OURBUDGET_DB_PASSWORD
    $credential = $null
}
```

Kết quả mong đợi `FOUNDATION RESULT: 59/59 passed`, exit code `0`, gồm 34 kiểm tra baseline và 25 kiểm tra nâng cấp/outbox. Bộ mới cố ý commit dữ liệu thử để kiểm tra worker, không giữ nguyên seed cho sử dụng lâu dài. AUTO_INCREMENT có thể có khoảng trống sau các ca bị từ chối/rollback, đây không phải lỗi. Muốn chạy lại, tạo database mới như `ourbudget_repeat_test` rồi thay `OURBUDGET_DB_NAME`. Dùng database trống khác và `tests/verify-install.php` để kiểm tra đường cài mới không có demo (7 kiểm tra).

[Báo cáo TEST-003](../bugs/TEST-003-mysql-database.md) giữ lịch sử kiểm tra baseline. [Báo cáo TEST-004](../bugs/TEST-004-step03-foundation.md) ghi kết quả PHP/MySQL, Android, migration và worker hiện hành; mô hình native PowerDesigner vẫn cần đồng bộ trước khi chốt toàn bộ bước 03.

## Nguồn kỹ thuật

- [MySQL CHECK constraints](https://dev.mysql.com/doc/refman/8.0/en/create-table-check-constraints.html) — CHECK được thực thi từ 8.0.16.
- [MySQL foreign keys](https://dev.mysql.com/doc/refman/8.0/en/example-foreign-keys.html) — bỏ ON DELETE/ON UPDATE tương đương RESTRICT trong InnoDB.
