# Giải thích schema MySQL và các bảng bổ sung so với ERD

**Phạm vi phiên bản:** phần đối chiếu 7 thực thể/10 bảng dưới đây giải thích baseline `001_schema.sql`. Bản triển khai hiện tại chạy thêm `004_step03_foundation.sql`, thành 14 bảng; xem phần bổ sung cuối tài liệu và [metadata hiện hành](model-reference.md). Bản ERD/PDM native chưa được đồng bộ, vì vậy không dùng chúng sinh lại schema triển khai.

Tài liệu này giải thích [001_schema.sql](001_schema.sql) và phần bổ sung [004_step03_foundation.sql](004_step03_foundation.sql). Nội dung baseline đối chiếu trực tiếp với [ERD_OurBudget.cdm](../dgr/database-dgr/ERD_OurBudget.cdm), [PDM_OurBudget.pdm](../dgr/database-dgr/PDM_OurBudget.pdm) và [kiến trúc đã chốt](../docs/final-system-architecture.md) tại ngày 20/11/2026. Cách import nằm trong [README](README.md).

## Bổ sung của migration 004

`user_identities` biểu diễn danh tính ngoài do Google cấp. Mỗi hàng liên kết một users_id với provider và provider_subject (`sub`), unique theo provider/subject và theo user/provider. Đây không phải một tài khoản người dùng thứ hai. `users_password` được phép NULL để không tạo mật khẩu giả cho tài khoản Google-only; API bước 04 phải từ chối đăng nhập mật khẩu khi NULL và không tự liên kết theo email.

`email_verifications` lưu hash token xác minh, địa chỉ được xác minh, thời hạn và thời điểm sử dụng. Nó khác password_resets: chứng minh quyền kiểm soát email không đồng nghĩa với đặt lại mật khẩu. `users.email_verified_at` phản ánh trạng thái email hiện tại; đổi email phải xóa trạng thái này. API phải tiêu thụ token một lần bằng cập nhật có điều kiện trong giao tác và đối chiếu địa chỉ hiện tại.

`email_outbox` là hàng đợi kỹ thuật bền vững, mỗi event_id duy nhất tương ứng một sự kiện đã commit. Hàng chứa người nhận snapshot, loại sự kiện, payload tối thiểu, trạng thái, số lần thử và lịch retry. claim_token/locked_until bảo vệ việc nhận hàng giữa các worker; sent_at là thời điểm transport chấp nhận (với file transport là thời điểm ghi tệp), không phải bằng chứng người nhận đã đọc. Rollback nghiệp vụ xóa cả outbox. Worker gửi ngoài giao tác nên lỗi SMTP không làm mất dữ liệu tài chính. Đây là thực thể vận hành, không mở rộng mô hình nghiệp vụ thu/chi.

`schema_migrations` lưu phiên bản cấu trúc đã áp dụng. Nó không chứa dữ liệu người dùng và giúp health endpoint phân biệt database kết nối được với database đã sẵn sàng cho mã hiện tại. Cùng ba bảng kỹ thuật của baseline, bốn bảng mới đưa tổng số bảng lên 14.

Thứ tự ví được chuyển từ quy ước baseline giảm dần sang tăng dần 0..N−1. `active_priority` là cột tính toán chỉ có giá trị khi ví hoạt động, dùng cho unique chống trùng thứ tự; ví ngừng hoạt động nhận NULL ở cột này. Không đưa cột sinh này thành trường nhập liệu trong ERD nghiệp vụ. Xem [bản đối chiếu MySQL hiện hành](model-reference.md) để đồng bộ mô hình native.

**Nhận xét của bạn là đúng: schema có ba bảng chưa xuất hiện trong ERD/PDM hiện tại.** ERD và PDM đang có 7 thực thể/bảng, còn SQL tạo 10 bảng. Khi viết SQL, mình đã bổ sung `auth_sessions`, `password_resets` và `idempotency_keys` để hiện thực hóa các yêu cầu kỹ thuật trong bản kiến trúc chốt. Vì vậy, đây là schema triển khai có bổ sung thiết kế, chưa phải bản chuyển đổi một-một từ mô hình ER của bạn.

## 1. Đối chiếu toàn bộ bảng

| Bảng trong SQL | Có trong ERD/PDM hiện tại? | Vai trò |
| --- | --- | --- |
| `users` | Có | Tài khoản và hồ sơ người dùng |
| `wallet_categories` | Có | Loại nguồn tiền: tiền mặt, ngân hàng, ví điện tử |
| `wallets` | Có | Các ví của người dùng, số dư và độ ưu tiên |
| `income_categories` | Có | Danh mục thu nhập |
| `outcome_categories` | Có | Danh mục chi tiêu |
| `transactions` | Có | Khoản thu, khoản chi hoặc chuyển nội bộ |
| `budgets` | Có | Hạn mức chi tiêu theo kỳ và phạm vi |
| `auth_sessions` | **Chưa có** | Phiên đăng nhập, hạn sử dụng và thu hồi token |
| `password_resets` | **Chưa có** | Yêu cầu khôi phục mật khẩu có hạn và dùng một lần |
| `idempotency_keys` | **Chưa có** | Ghi nhớ yêu cầu tạo giao dịch đã xử lý để tránh ghi tiền hai lần |

Bảy bảng đầu mô tả dữ liệu nghiệp vụ mà người dùng quản lý. Ba bảng bổ sung lưu trạng thái vận hành của API. Chúng vẫn là các thực thể dữ liệu cần thể hiện trong mô hình triển khai nếu hệ thống sử dụng thiết kế SQL hiện tại.

## 2. Vì sao phát sinh ba bảng này?

[Đặc tả use-case](../docs/use-case-diagram.md) đã có UC2 đăng nhập, UC3 quên mật khẩu và UC4 đăng xuất. Trong mục **Giao tác, yêu cầu gửi lại và bảo mật** của kiến trúc chốt, hệ thống còn yêu cầu lưu hash token, thu hồi phiên, mã khôi phục có hạn dùng một lần và lưu khóa chống ghi trùng cùng kết quả xử lý. Mục **Đặc tả triển khai và tiêu chí nghiệm thu** cũng yêu cầu ERD/PDM thể hiện các dữ liệu này.

Kiến trúc quy định những khả năng cần có, nhưng không ấn định chính xác tên bảng, tên cột hay kiểu khóa chính. Việc chọn ba bảng riêng với các tên hiện tại là quyết định triển khai của mình ở bước viết SQL. Cách này tận dụng MySQL đang có và cho phép các trạng thái cần đi cùng nhau được ghi trong giao tác InnoDB. Các chức năng tương ứng vẫn cần mã PHP để hoạt động.

### 2.1. `auth_sessions` — Phiên đăng nhập

`users` trả lời câu hỏi “đây là tài khoản nào”, còn `auth_sessions` ghi nhận một lần cấp quyền truy cập cho tài khoản đó. Khi đăng nhập thành công, API dự kiến cấp một token ngẫu nhiên cho ứng dụng và lưu hash của token trong bảng này. Khi ứng dụng gọi API, máy chủ kiểm tra token để xác định người dùng và hiệu lực phiên.

| Trường | Ý nghĩa trong schema |
| --- | --- |
| `session_id` | Khóa chính tự tăng, định danh bản ghi phiên; không phải token đăng nhập |
| `users_id` | Khóa ngoại đến tài khoản sở hữu phiên, bắt buộc có |
| `token_hash` | Hash token dạng nhị phân 32 byte; unique để không có hai phiên mang cùng hash |
| `created_at` | Thời điểm tạo phiên, mặc định thời gian hiện tại của kết nối |
| `expires_at` | Thời điểm hết hạn; CHECK yêu cầu lớn hơn `created_at` |
| `revoked_at` | Thời điểm thu hồi; NULL nghĩa là chưa ghi nhận thu hồi |

Quan hệ là **một người dùng có từ 0 đến nhiều phiên; mỗi phiên thuộc đúng một người dùng**. Bảng cho phép nhiều phiên nhưng chưa quyết định sản phẩm có cho đăng nhập đồng thời nhiều thiết bị hay không. Bảng cũng chưa lưu tên thiết bị, IP hoặc refresh token.

Ví dụ, tài khoản A đăng nhập lúc 08:00, API tạo phiên hết hạn lúc 20:00. Nếu A đăng xuất lúc 09:00, API ghi `revoked_at = 09:00`. Từ thời điểm đó, token cũ phải bị từ chối dù chưa đến 20:00. Nếu chỉ xóa token trong điện thoại mà không thu hồi phía máy chủ, một bản sao token còn tồn tại có thể vẫn được gửi đến API.

Để chấp nhận phiên, PHP phải kiểm tra hash khớp, `revoked_at IS NULL`, chưa đến `expires_at` và tài khoản còn hoạt động. **Cột thời hạn và CHECK không tự ngăn một yêu cầu HTTP dùng token đã hết hạn.** CHECK hiện chỉ kiểm tra thứ tự hai mốc thời gian khi ghi dữ liệu.

Không gộp token vào một cột của `users` vì tài khoản và các phiên có vòng đời khác nhau. Cách tách bảng hỗ trợ thu hồi từng phiên hoặc toàn bộ phiên bằng truy vấn theo `users_id`. Nó phục vụ UC2 và UC4; chính sách thu hồi khi đổi mật khẩu được triển khai tiếp trong phân hệ tài khoản.

### 2.2. `password_resets` — Yêu cầu khôi phục mật khẩu

Bảng này hỗ trợ UC3. Một yêu cầu khôi phục cần có thông tin về tài khoản, bằng chứng xác nhận gửi qua email, thời hạn và trạng thái đã sử dụng. Nếu chỉ có email và hash mật khẩu trong `users`, máy chủ chưa có dữ liệu để xác định một yêu cầu khôi phục cụ thể còn hiệu lực hay đã được dùng.

| Trường | Ý nghĩa trong schema |
| --- | --- |
| `reset_id` | Khóa chính của yêu cầu khôi phục |
| `users_id` | Khóa ngoại đến tài khoản cần đổi mật khẩu |
| `token_hash` | Hash của token khôi phục; unique, không lưu token gốc |
| `created_at` | Thời điểm tạo yêu cầu |
| `expires_at` | Hạn dùng; phải sau thời điểm tạo |
| `used_at` | Thời điểm sử dụng thành công; NULL nghĩa là chưa ghi nhận sử dụng |

Quan hệ là **một người dùng có từ 0 đến nhiều yêu cầu khôi phục; mỗi yêu cầu thuộc đúng một người dùng**. Có nhiều bản ghi theo thời gian không có nghĩa mọi mã cũ đều phải được chấp nhận: chính sách vô hiệu hóa yêu cầu cũ khi gửi mã mới thuộc API.

Ví dụ, A yêu cầu đặt lại mật khẩu lúc 10:00, nhận liên kết qua email có token hết hạn lúc 10:15. Khi A xác nhận lúc 10:05, PHP kiểm tra token, hạn dùng và `used_at`, cập nhật hash mật khẩu trong `users`, đồng thời đánh dấu yêu cầu đã dùng trong cùng giao tác. Lần gửi lại token này phải thất bại. Các mốc 15 phút ở đây chỉ minh họa; schema chưa ấn định thời lượng hiệu lực.

Để hai yêu cầu gửi đồng thời không cùng sử dụng một token, API cần khóa bản ghi hoặc cập nhật có điều kiện và kiểm tra số hàng bị ảnh hưởng. Đặt `used_at` sau một câu SELECT rời rạc chưa đủ bảo đảm chỉ dùng một lần.

`token_hash` không phải `users_password`: một bên xác nhận quyền đặt lại mật khẩu trong thời gian ngắn, bên kia là hash mật khẩu dùng để kiểm tra đăng nhập. Schema hiện chưa có bảng hàng đợi email, bộ đếm thử OTP hay cơ chế giới hạn tần suất; các phần này không tự xuất hiện chỉ vì đã tạo `password_resets`.

Không dùng chung bảng với `auth_sessions` vì quyền của hai token khác nhau. Token phiên được gửi nhiều lần để truy cập tài nguyên; token khôi phục chỉ được dùng cho quy trình đổi mật khẩu và phải bị tiêu thụ sau khi thành công.

### 2.3. `idempotency_keys` — Chống ghi trùng khi gửi lại yêu cầu

Đây là bảng dễ gây nhầm nhất vì không tương ứng với một màn hình riêng. Nó bảo vệ các thao tác tạo khoản thu/chi và chuyển tiền khi điện thoại gửi lại cùng một yêu cầu do mất mạng hoặc chưa nhận được phản hồi.

Ví dụ, ví có 100.000 đ. Người dùng ghi chi 25.000 đ, máy chủ đã lưu và đưa số dư về 75.000 đ, nhưng phản hồi bị mất trên đường về điện thoại. Nếu điện thoại gửi lại và máy chủ coi đó là một thao tác mới, số dư có thể bị trừ tiếp xuống 50.000 đ. Khóa chống ghi trùng giúp máy chủ nhận ra đây là lần gửi lại của thao tác đã hoàn tất.

| Trường | Ý nghĩa trong schema |
| --- | --- |
| `idempotency_id` | Khóa chính của bản ghi theo dõi yêu cầu |
| `users_id` | Người dùng đã gửi yêu cầu |
| `operation` | Phạm vi thao tác, hiện chỉ nhận `transactions.create` hoặc `transfers.create` |
| `idempotency_key` | Khóa do ứng dụng tạo cho một thao tác; giữ nguyên khi thử lại thao tác đó |
| `request_hash` | Hash 32 byte của nội dung yêu cầu đã chuẩn hóa, dùng phát hiện việc tái sử dụng khóa cho nội dung khác |
| `response_status` | Mã HTTP đã trả; CHECK hiện chỉ cho phép `201` |
| `response_body` | JSON kết quả tạo thành công để phát lại khi nhận yêu cầu lặp |
| `created_at` | Thời điểm lưu kết quả |

Ràng buộc `UNIQUE (users_id, operation, idempotency_key)` nghĩa là một bộ ba người dùng–thao tác–khóa chỉ có một bản ghi. Cùng chuỗi khóa ở hai tài khoản hoặc hai loại thao tác là hai phạm vi khác nhau. Cột khóa phân biệt hoa/thường theo collation `ascii_bin`.

| Tình huống API nhận được | Cách xử lý theo kiến trúc chốt |
| --- | --- |
| Khóa chưa được xử lý | Ghi giao dịch, số dư và kết quả idempotency trong cùng giao tác |
| Khóa đã có, nội dung giống nhau | Trả lại kết quả đã lưu, không ghi thêm giao dịch |
| Khóa đã có, nội dung khác nhau | Từ chối với `409 Conflict` |
| Hai yêu cầu cùng khóa đến đồng thời | PHP xử lý xung đột unique, rollback lần ghi không thành công rồi đọc/so sánh kết quả của lần đã commit |

Hai khoản chi thật sự khác nhau vẫn có thể có cùng số tiền, danh mục và ngày. Khi đó ứng dụng phải tạo hai khóa khác nhau. Không dùng “số tiền giống nhau” làm tiêu chí xóa giao dịch trùng.

Quan hệ là **một người dùng có từ 0 đến nhiều bản ghi idempotency; mỗi bản ghi thuộc đúng một người dùng**. Schema không có FK `transactions_id` trong bảng này. JSON giữ kết quả của yêu cầu tạo tại thời điểm nó thành công, kể cả khi giao dịch về sau được sửa hoặc xóa. Đây cũng là lý do kết quả phát lại có thể chứa số dư cũ; ứng dụng cần tải lại số dư mới nhất như kiến trúc đã quy định.

Unique chỉ ngăn hai hàng có cùng bộ khóa. Nó không tự so sánh `request_hash`, trả mã HTTP hoặc gộp các câu ghi thành một giao tác. Những hành vi đó cần PHP. Schema hiện lưu kết quả tạo thành công, chưa có trạng thái “đang xử lý”, chưa lưu kết quả lỗi và chưa có `expires_at`; chính sách dọn khóa chưa được chốt. Xóa khóa quá sớm sẽ làm mất khả năng nhận diện lần thử lại muộn.

## 3. Các thay đổi trong bảy bảng đã có

Ngoài ba bảng mới, SQL còn bổ sung hoặc điều chỉnh thuộc tính và ràng buộc. Vì vậy, chỉ thêm ba hình chữ nhật vào sơ đồ ER chưa đủ để đồng bộ đầy đủ với schema.

| Nhóm thay đổi | Giải thích |
| --- | --- |
| Khóa chính/ngoại | PDM dùng ID `CHAR(10)`, SQL chọn `BIGINT UNSIGNED AUTO_INCREMENT` và FK tương ứng. Đây là lựa chọn triển khai; kiến trúc chốt không bắt buộc đổi ID sang số. Cần cập nhật mô hình nếu giữ lựa chọn này. |
| Hồ sơ | `users` có điện thoại, URL avatar tùy chọn và thời điểm cập nhật; `users_role` trong PDM chưa được đưa vào SQL vì phạm vi hiện tại chưa triển khai phân quyền theo vai trò. |
| Sở hữu danh mục | Thêm `users_id` và trạng thái hoạt động vào hai bảng danh mục. NULL biểu thị danh mục hệ thống. FK xác nhận tài khoản tồn tại; API vẫn phải bảo đảm người dùng chỉ dùng/sửa danh mục trong phạm vi cho phép. |
| Chuyển nội bộ | `transactions_type` phân biệt INCOME/EXPENSE/TRANSFER; `destination_wallet_id` là ví đích. Không giữ `wal_wallets_id` trùng vai trò trong PDM. Một chuyển nội bộ lưu bằng một dòng giao dịch. |
| Cùng chủ ví | FK ghép `(users_id, wallets_id)` và `(users_id, destination_wallet_id)` bảo đảm ví nguồn/đích thuộc người dùng của giao dịch. Unique ghép trên `wallets` là khóa được tham chiếu, không phải một thực thể mới. |
| Số tiền | Thu dương, chi âm, chuyển dương; mọi giá trị tiền là BIGINT có dấu. Hạn mức ngân sách đổi từ DECIMAL trong PDM sang BIGINT theo kiến trúc chốt. |
| Ngân sách | Chỉ giữ `outcome_id`; NULL là ngân sách tổng. Bỏ `income_id` trong PDM, thêm `budgets_period` WEEK/MONTH. Quy tắc ngân sách trùng và độ dài kỳ đầy đủ còn thuộc bước nghiệp vụ sau. |
| Tên/thời gian | Chuẩn hóa `transactions_occured_at` thành `transactions_occurred_at`, `transactions_created_time` thành `transactions_created_at`, `users_phoneNumber` thành `users_phone_number`; DATETIME lưu theo quy ước giờ Việt Nam. |
| Bảo toàn lịch sử | FK giữ hành vi RESTRICT. Ví/danh mục có tham chiếu được ngừng hoạt động qua API thay vì xóa vật lý. |

Các dòng `PRIMARY KEY`, `UNIQUE KEY`, `KEY`, `FOREIGN KEY` và `CHECK` mô tả khóa, chỉ mục hoặc ràng buộc của bảng; chúng không tạo thêm thực thể. `response_body JSON` là một thuộc tính của `idempotency_keys`, không phải bảng riêng. SQL cũng không tạo bảng báo cáo hoặc bảng chuyển tiền: báo cáo được tổng hợp từ giao dịch, còn chuyển tiền dùng loại `TRANSFER`.

## 4. Cần thể hiện thế nào trong ERD và báo cáo?

Nếu ERD trong báo cáo dùng để mô tả **toàn bộ dữ liệu của hệ thống triển khai**, cần bổ sung ba thực thể và ba quan hệ dưới đây, rồi cập nhật từ điển dữ liệu theo các trường đã trình bày.

| Thực thể cha | Thực thể con | Bội số | Khóa liên kết |
| --- | --- | --- | --- |
| `users` | `auth_sessions` | Một tài khoản có 0..N phiên; mỗi phiên có đúng 1 tài khoản | `auth_sessions.users_id → users.users_id` |
| `users` | `password_resets` | Một tài khoản có 0..N yêu cầu; mỗi yêu cầu có đúng 1 tài khoản | `password_resets.users_id → users.users_id` |
| `users` | `idempotency_keys` | Một tài khoản có 0..N bản ghi; mỗi bản ghi có đúng 1 tài khoản | `idempotency_keys.users_id → users.users_id` |

Nếu muốn giữ sơ đồ bảy thực thể làm sơ đồ **nghiệp vụ tài chính**, có thể giữ nó với nhãn phạm vi rõ ràng và bổ sung một sơ đồ dữ liệu xác thực/chống ghi trùng cùng phần thuyết minh. Mô hình vật lý PDM phục vụ triển khai vẫn cần đủ 10 bảng và các ràng buộc, đồng thời đổi DBMS đích từ SAP SQL Anywhere 17 sang MySQL.

Với kiến trúc hiện đã chốt, ba bảng trên có mục đích cụ thể và nên được giữ khi tiếp tục triển khai. Tuy nhiên, không phải mọi ứng dụng tài chính đều buộc phải có đúng ba bảng với đúng các tên này. Có thể chọn cách lưu phiên hoặc trạng thái khác nếu thay đổi thiết kế tương ứng; chỉ xóa bảng mà giữ nguyên các yêu cầu thu hồi phiên, khôi phục một lần và chống ghi trùng sẽ để lại phần chức năng chưa có nơi lưu trạng thái.

Tài liệu này giải thích lựa chọn hiện tại để bạn đánh giá và đồng bộ mô hình. Nó không thay thế việc chốt lại ERD/PDM, và không xác nhận các chức năng PHP đã được triển khai. [Báo cáo kiểm thử CSDL](../bugs/TEST-003-mysql-database.md) ghi rõ phần kiểm chứng SQL và phần API còn chờ.
