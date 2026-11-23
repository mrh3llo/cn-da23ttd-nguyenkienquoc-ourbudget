# Chuyển cơ sở dữ liệu OurBudget sang Supabase

Ngày 22/11/2026, đích lưu trữ của backend được chuyển từ MySQL sang PostgreSQL
do Supabase quản lý. Ứng dụng Flutter vẫn gọi API PHP; xác thực tùy chỉnh,
Provider và hợp đồng REST được giữ nguyên. Không thay bằng Supabase Auth và
không đưa khóa bí mật hoặc thông tin kết nối CSDL vào ứng dụng di động.

Schema PostgreSQL trong `src/supabase/migrations/` giữ bảy thực thể được mô tả
trong báo cáo. Các khóa chính và khóa ngoại danh mục dùng bigint; khóa ví và
giao dịch dùng integer; số dư và giao dịch dùng số nguyên có dấu; hạn mức
ngân sách dùng numeric(19,0). Khóa băm SHA-256 được lưu dưới dạng bytea với
ràng buộc độ dài 32 byte. Tên users_phoneNumber trong Word được PostgreSQL
chuyển thành users_phonenumber theo quy tắc chuẩn hóa tên không đặt trong
ngoặc kép.

Giao dịch tiếp tục được nhận diện theo dấu số tiền và ví đích. Thu có số tiền
dương cùng income_id; chi có số tiền âm cùng outcome_id; chuyển ví có số
tiền dương và destination_wallet_id. Ràng buộc CHECK không cho phép số 0,
danh mục mâu thuẫn hoặc chuyển đến chính ví nguồn. Báo cáo thu/chi và ngân sách
phải loại các bản ghi có ví đích.

Các bảng đều bật RLS và không cấp quyền truy cập bảng cho vai trò anon hoặc
authenticated. Backend dùng PDO PostgreSQL với TLS bắt buộc. Khóa publishable
được lưu trong mẫu cấu hình để tham khảo nhưng hiện không được ứng dụng Flutter
sử dụng; khóa secret chỉ dành cho môi trường máy chủ.

Các tệp cài đặt/migration riêng cho MySQL và InfinityFree đã được loại bỏ.
Migration Supabase chỉ tạo schema và danh mục dùng chung trên CSDL mới; nó
không xóa hay chuyển dữ liệu của CSDL cũ. Việc xuất dữ liệu, chuyển đổi các
giá trị BINARY(32) sang bytea, nhập theo thứ tự khóa ngoại, kiểm tra số dư
và chuyển endpoint cần thực hiện trước khi cắt chuyển thực tế.

Hướng dẫn chạy migration và cấu hình backend nằm tại
../supabase/SUPABASE.md. Kết nối trực tiếp Supabase cần mạng IPv6 hoặc add-on
IPv4; backend chỉ IPv4 cần dùng session pooler. Đây là chế độ tương thích với
kết nối PDO tồn tại và prepared statements.
