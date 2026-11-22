# TEST-006 — Chuẩn hóa CSDL, cấu hình môi trường và thương hiệu

Ngày: 22/11/2026. Môi trường: Windows, PHP 8.2.12, MySQL 8.0.46 thử riêng cổng 13316, Flutter/Dart theo SDK dự án, Android Emulator API 37.

## 1. Tổng kết

Đã chuẩn hóa schema theo `thesis/doc/2. Báo cáo đề tài.docx`, cập nhật các consumer PHP/Flutter có liên quan, thêm cấu hình .env, SQL cài mới/migration và hướng dẫn InfinityFree. Sau đó hoàn tất logo xác thực và icon Android/iOS. Không sửa Word; SHA-256 vẫn khớp bản trích đối chiếu. Không chạy migration hoặc xóa dữ liệu trên CSDL cá nhân. Tác giả chọn tự triển khai SQL qua phpMyAdmin; không tạo backup CSDL cá nhân trong phiên này.

## 2. Thay đổi CSDL

Giữ đúng 7 bảng. `report-schema.json` trích cột/kiểu từ Word và ghi SHA-256 nguồn; kiểm thử đối chiếu metadata MySQL xác nhận khớp toàn bộ tên và kiểu, không chỉ số bảng.

| Nhóm | Thay đổi |
| --- | --- |
| users | INT cho ID; name/email/phone 50/150/10; password/avatar TEXT; các tên cột xác thực theo Word |
| Danh mục | BIGINT cho ID và FK; bỏ thuộc tính users_id/is_active ngoài Word khỏi schema mới |
| wallets | INT cho ID/chủ ví; priority và active priority SMALLINT; cột sinh wallets_active_priority giữ UNIQUE ví hoạt động |
| transactions | Bỏ transactions_type; INT cho ID/ví/chủ; destination_wallet_id; tên thời gian theo Word |
| budgets | Bổ sung income_id đúng Word; DECIMAL(19,0); WEEK/MONTH/YEAR |
| Ràng buộc | Giữ bảo vệ quyền sở hữu hai ví, lịch sử RESTRICT, dấu/danh mục/số tiền hợp lệ; thêm FK ngân sách–danh mục thu |

Ngoại lệ đã được tác giả duyệt: BIGINT cho FK danh mục để khớp PK; DECIMAL(19,0) cho VND; destination_wallet_id thay wal_wallets_id. Giữ cách viết users_verification_experes_at và transactions_occured_at theo Word.

Chuyển ví được nhận diện trước bằng ví đích. Ghi mới dùng số tiền dương, trừ nguồn/cộng đích trong cùng giao tác. Thu/chi và ngân sách luôn loại giao dịch có ví đích. Model Flutter thêm destinationWalletId và loại suy ra; Provider truyền ví đích, repository mẫu cập nhật cả hai ví; lịch sử xét ví nguồn lẫn đích và trình bày chuyển ví bằng màu trung tính.

Migration 007 chỉ dành cho schema bảy bảng v006. Nó chặn toàn bộ ALTER nếu danh mục còn chủ sở hữu/trạng thái riêng hoặc dữ liệu vượt giới hạn mới. Kiểm thử xác nhận trường hợp hợp lệ giữ mọi hàng và giá trị còn lại, chỉ bỏ cột loại suy ra và các cột danh mục mặc định. CSDL cá nhân đang có hai danh mục thu và hai danh mục chi riêng; giữ nguyên, không tự chuyển thành công khai.

## 3. Tệp thay đổi và tạo mới

| Phạm vi | Tệp |
| --- | --- |
| Schema/seed | database/001_schema.sql, 002_seed_system.sql, 003_seed_demo.sql |
| Migration mới | database/007_preflight.sql, 007_standardize_report.sql |
| Đối chiếu | database/report-schema.json, model-reference.md, tests/verify-report.php, tests/export-model-reference.php |
| Kiểm thử CSDL | tests/verify.php, verify-install.php, verify-money.php, verify-migration.php, fixtures/schema-v006.sql |
| Backend cấu hình | backend/.env (Git bỏ qua), .env.example, .htaccess, public/.htaccess, src/Environment.php, src/bootstrap.php, tests/environment.php; .gitignore ở gốc |
| Backend consumer | src/AuthService.php, src/MailQueue.php, public/index.php, bin/migrate.php; tests/auth.php |
| Mô hình native | dgr/database-dgr/ERD_OurBudget.cdm, PDM_OurBudget.pdm: tên/kiểu; PDM thêm đối chiếu nullable. Giữ nguyên object ID và liên kết |
| Flutter | auth_page.dart, transaction_repository.dart, ledger_view_model.dart, history_page.dart, ledger_cards.dart, pubspec.yaml |
| Flutter kiểm thử | test/auth_branding_test.dart, transfer_test.dart, widget_test.dart; integration_test/backend_connection_test.dart |
| Tài nguyên | assets/icons/*.png, 4.0x/our-budget-wordmark.png, our-budget-icon.svg; Android mipmap/drawable adaptive và AndroidManifest.xml |
| iOS | Khung ios/ từ Flutter SDK, Runner/Info.plist, AppIcon catalog và PNG; analysis_options.yaml tự thêm loại trừ ios |
| Tạo lại thương hiệu | mobile/ourbudget/tool/generate_brand_assets.py, requirements-brand.txt, BRANDING.md |
| Tài liệu | database/README.md, schema-explained.md, INFINITYFREE.md; docs/final-system-architecture.md, implementation-roadmap.md, http-api-contract.md và các tham chiếu tên cột liên quan |

Working tree đã có nhiều thay đổi từ phiên trước; bảng này mô tả phạm vi phiên hiện tại, không coi toàn bộ git diff là thay đổi mới.

## 4. Triển khai InfinityFree

Xem [hướng dẫn chi tiết](../database/INFINITYFREE.md). Database trống: chọn đúng database trong phpMyAdmin, import 001 rồi 002; không import seed demo 003. Database cũ: chỉ dùng 007 khi đúng baseline và preflight đạt; không chồng schema mới lên dữ liệu hiện có.

`.env` đã điền host/port/database/username được cung cấp; mật khẩu vẫn là `<INSERT_DATABASE_PASSWORD>`. Parser đọc nguyên văn, không nội suy/chạy lệnh. Biến DB_* của tiến trình ưu tiên cao nhất, sau đó OURBUDGET_DB_* để tương thích kiểm thử, rồi .env, rồi config cũ. Placeholder bị từ chối trước khi kết nối. `.env` không nằm trong Git hoặc Flutter assets.

InfinityFree free không hỗ trợ remote MySQL từ Workbench/máy cá nhân và chặn mobile/API bằng JavaScript-cookie challenge. Import SQL không đồng nghĩa Flutter dùng được API trên hosting này. [Remote MySQL](https://forum.infinityfree.com/t/issue-with-remote-mysql-database-connection/100347/2), [giới hạn API](https://forum.infinityfree.com/t/browser-security-system-features-and-limitations/49353).

## 5. Kết quả kiểm thử

| Nhóm | Kết quả |
| --- | --- |
| Schema, CHECK/FK, độ chính xác tiền | 32/32 đạt |
| Thu, chi, chuyển ví và tổng hợp loại chuyển ví | 6/6 đạt; rollback giữ dữ liệu fixture |
| Đối chiếu Word–MySQL | Khớp đúng 7 bảng, tên cột và kiểu đã duyệt |
| Migration | Chặn danh mục riêng; giữ hàng/giá trị của fixture hợp lệ; schema sau chuyển khớp Word |
| PHP xác thực | 52/52 đạt |
| Cài mới và queue | 12/12 đạt |
| HTTP/fixture | 32/32 đạt |
| Xác thực qua HTTP thật | 20/20 đạt |
| .env và kiểm tra cấu hình | 17/17 đạt |
| Flutter unit/widget | 15/15 đạt |
| Android integration | 2/2 đạt qua API 18081 và MySQL thử 13316 |
| Flutter analyze | No issues found |
| APK debug | Build thành công; cài bằng adb install -r thành công |
| Logo giao diện | Đã quan sát Login, Register, Forgot trên emulator; widget test kiểm tra vị trí bằng nhau và màn hình hẹp/chữ lớn/bàn phím |
| Android launcher | Đã quan sát chữ O chính thức trong launcher sau cài APK |
| Asset iOS | 19 slot đúng kích thước, RGB không alpha, gồm 1024x1024; chưa build iOS |
| Mô hình native | XML hợp lệ; object ID/Ref giữ nguyên; PDM tên/kiểu 7 bảng khớp fixture |

Ảnh tại `graphify-out/ourbudget-login.png`, `ourbudget-register.png`, `ourbudget-forgot.png`, `ourbudget-launcher.png` (bằng chứng cục bộ, thư mục bị Git bỏ qua).

APK thông thường cuối cùng dùng API_BASE_URL=http://10.0.2.2:8080 cho emulator; APK không chứa backend. Kiểm thử tích hợp dùng cổng thử 18081, sau đó đã build/cài lại bản thường. Không gửi email SMTP thật trong kiểm thử.

## 6. Chưa nghiệm thu và giới hạn

- Chưa kết nối tài khoản InfinityFree thật: chưa có mật khẩu và free hosting không hỗ trợ luồng mobile/API. Quy tắc Apache .htaccess và MariaDB chưa được kiểm tra trên host thật.
- CSDL cá nhân giữ schema cũ theo quyết định bàn giao SQL. Backend mới cần schema mới và .env hợp lệ trước khi phục vụ tài khoản thật.
- API tài chính và giao diện chuyển ví thực chưa tồn tại từ bước 04; phiên này kiểm thử SQL và model/repository mẫu, không tuyên bố đã bổ sung endpoint tài chính.
- iOS cần macOS/Xcode, ký ứng dụng và cấu hình Google client/URL scheme riêng. Chưa build/cài iPhone; chưa ký Android release.
- Không mở được PowerDesigner qua công cụ điều khiển Windows (native pipe unavailable). PDM vẫn mang target SAP SQL Anywhere 17; chưa nghiệm thu native CHECK/generated/identity và sinh DDL MySQL. Dùng SQL 001 đã kiểm thử, không sinh SQL triển khai từ PDM hiện tại.
- Google đăng nhập thật và SMTP Inbox không nằm trong kiểm thử tự động lần này.

## 7. Bước tiếp theo

1. Tác giả import schema mới vào database trống bằng phpMyAdmin; điền mật khẩu trong .env phía backend.
2. Chọn môi trường cho phép API di động và kết nối database tương ứng trước khi đổi API_BASE_URL của Flutter. Không đưa DB credentials vào app.
3. Mở PowerDesigner, xác nhận các mô hình và chuyển DBMS đúng MySQL trước khi sinh DDL; đối chiếu với model-reference.md.
4. Thử APK trên điện thoại thật và nghiệm thu Google; sau đó mới tiếp tục nghiệp vụ ví/danh mục/giao dịch theo roadmap.

Theo yêu cầu bổ sung, đã chạy `npx --yes skills add supabase/agent-skills --agent codex --global --yes`: cài supabase và supabase-postgres-best-practices vào ~/.agents/skills. Chưa áp dụng Supabase hay chuyển MySQL sang PostgreSQL.
