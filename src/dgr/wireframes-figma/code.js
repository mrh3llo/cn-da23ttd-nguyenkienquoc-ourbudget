const SCREENS = [
  ["home","Trang chủ","Trang chủ",[["balance","Tổng số dư khả dụng","5.420.000 đ","3 nguồn tiền đang hoạt động"],["budget","Ngân sách tháng","1.740.000 đ / 3.000.000 đ","58% · An toàn","58"],["heading","Giao dịch gần đây","Xem tất cả","history"],["tx","Ăn uống","Tiền mặt · 12:35","−45.000 đ"],["tx","Lương","Ngân hàng · 09:00","+4.000.000 đ"],["tx","Di chuyển","Tiền mặt · 08:10","−25.000 đ"],["tx","Mua sắm","Ví điện tử · Hôm qua","−120.000 đ"],["tx","Cà phê","Tiền mặt · Hôm qua","−35.000 đ"]]],
  ["quick","Giao dịch mới","",[["tabs","Chi tiêu","Thu nhập","income"],["field","Số tiền","25.000 đ"],["grid","Danh mục","Ăn uống","Di chuyển","Mua sắm","Hóa đơn"],["field","Nguồn tiền","Tiền mặt · Mặc định"],["link","Thêm ghi chú hoặc đổi ngày giờ","optional"],["button","Lưu giao dịch","home"]],"sheet"],
  ["income","Giao dịch mới","",[["tabs","Thu nhập","Chi tiêu","quick"],["field","Số tiền","500.000 đ"],["grid","Danh mục","Lương","Thưởng","Hoàn tiền","Khác"],["field","Nguồn tiền","Tiền mặt · Mặc định"],["link","Thêm ghi chú hoặc đổi ngày giờ","optional"],["button","Lưu giao dịch","home"]],"sheet"],
  ["optional","Giao dịch mới","",[["tabs","Chi tiêu","Thu nhập","income"],["field","Số tiền","25.000 đ"],["grid","Danh mục","Ăn uống","Di chuyển","Mua sắm","Hóa đơn"],["field","Nguồn tiền","Tiền mặt · Mặc định"],["field","Ghi chú","Bữa trưa"],["field","Ngày và giờ","Hôm nay, 12:35"],["button","Lưu giao dịch","home"]],"sheet"],
  ["error","Giao dịch mới","",[["tabs","Chi tiêu","Thu nhập","income"],["error","Số tiền","0 đ","Nhập số tiền lớn hơn 0 đ."],["grid","Danh mục","Ăn uống","Di chuyển","Mua sắm","Hóa đơn"],["field","Nguồn tiền","Tiền mặt · Mặc định"],["link","Thêm ghi chú hoặc đổi ngày giờ","optional"],["button","Lưu giao dịch",""]],"sheet"],
  ["history","Lịch sử","Lịch sử",[["field","Tìm giao dịch","Tên danh mục hoặc ghi chú"],["filters","Tháng này","Tất cả ví","Danh mục"],["heading","Hôm nay, 18/11"],["text","Thu +4.000.000 đ  ·  Chi −70.000 đ"],["tx","Ăn uống","Tiền mặt · 12:35","−45.000 đ","edit-tx"],["tx","Lương","Ngân hàng · 09:00","+4.000.000 đ"],["tx","Di chuyển","Tiền mặt · 08:10","−25.000 đ"],["heading","Hôm qua, 17/11"],["text","Thu 0 đ  ·  Chi −155.000 đ"],["tx","Mua sắm","Ví điện tử · 19:00","−120.000 đ"],["tx","Cà phê","Tiền mặt · 09:40","−35.000 đ"]]],
  ["edit-tx","Chỉnh sửa giao dịch","",[["field","Số tiền","45.000 đ"],["field","Danh mục","Ăn uống"],["field","Nguồn tiền","Tiền mặt"],["field","Ngày và giờ","18/11, 12:35"],["field","Ghi chú","Bữa trưa"],["button","Lưu thay đổi","history"],["link","Xóa giao dịch","delete-tx"]]],
  ["delete-tx","Xóa giao dịch?","",[["text","Giao dịch Ăn uống sẽ bị xóa và số dư Tiền mặt được cập nhật."],["button","Quay lại","edit-tx"],["link","Xóa giao dịch","history"]],"sheet"],
  ["budgets","Ngân sách","Ngân sách",[["filters","Tháng 11","01/11 – 30/11"],["budget","Ăn uống","600.000 đ / 1.000.000 đ","60% · An toàn","60","budget-edit"],["budget","Di chuyển","340.000 đ / 400.000 đ","85% · Cảnh báo","85"],["budget","Mua sắm","510.000 đ / 500.000 đ","102% · Vượt hạn mức","102"],["button","Thêm ngân sách","budget-form"],["link","Xem báo cáo","report"]]],
  ["budget-form","Thiết lập ngân sách","",[["field","Danh mục","Ăn uống"],["field","Hạn mức","1.000.000 đ"],["field","Chu kỳ","Tháng"],["field","Ngày bắt đầu","01/11/2026"],["field","Ngày kết thúc","30/11/2026"],["button","Lưu ngân sách","budgets"]]],
  ["alert","Trang chủ","Trang chủ",[["balance","Tổng số dư khả dụng","5.420.000 đ","3 nguồn tiền đang hoạt động"],["alert","Mua sắm đã vượt hạn mức","Đã chi 510.000 đ / 500.000 đ","budgets"],["budget","Ngân sách tháng","1.740.000 đ / 3.000.000 đ","58% · An toàn","58"],["heading","Giao dịch gần đây"],["tx","Mua sắm","Ví điện tử · 19:00","−120.000 đ"]]],
  ["profile","Cá nhân","Cá nhân",[["card","Minh Anh","minhanh@example.com"],["link","Thông tin cá nhân","profile-edit"],["link","Nguồn tiền","wallets"],["link","Danh mục thu chi","categories"],["link","Báo cáo thống kê","report"],["link","Đăng xuất","login"]]],
  ["profile-edit","Thông tin cá nhân","",[["field","Họ và tên","Minh Anh"],["field","Email","minhanh@example.com"],["field","Ảnh đại diện","Chọn ảnh"],["field","Mật khẩu","Đổi mật khẩu"],["button","Lưu thay đổi","profile"]]],
  ["wallets","Nguồn tiền","",[["balance","Tổng số dư","5.420.000 đ","3 nguồn tiền đang hoạt động"],["card","Tiền mặt","420.000 đ · Mặc định","wallet-edit"],["card","Ngân hàng","4.500.000 đ"],["card","Ví điện tử","500.000 đ"],["button","Thêm nguồn tiền","wallet-form"],["link","Chuyển tiền nội bộ","transfer"]]],
  ["wallet-form","Thêm nguồn tiền","",[["field","Tên nguồn tiền","Tiền mặt"],["field","Loại nguồn tiền","Tiền mặt"],["field","Số dư ban đầu","0 đ"],["button","Lưu nguồn tiền","wallets"]]],
  ["transfer","Chuyển tiền nội bộ","",[["field","Từ nguồn tiền","Ngân hàng"],["field","Đến nguồn tiền","Tiền mặt"],["field","Số tiền","200.000 đ"],["text","Trừ số dư ví nguồn và cộng vào ví đích."],["button","Xác nhận chuyển tiền","wallets"]]],
  ["categories","Danh mục","",[["tabs","Chi tiêu","Thu nhập"],["card","Ăn uống","Chi tiêu","category-edit"],["card","Di chuyển","Chi tiêu"],["card","Mua sắm","Chi tiêu"],["card","Hóa đơn","Chi tiêu"],["button","Thêm danh mục","category-form"]]],
  ["category-form","Thêm danh mục","",[["tabs","Chi tiêu","Thu nhập"],["field","Tên danh mục","Ăn uống"],["field","Biểu tượng","Chọn biểu tượng"],["field","Màu sắc","Chọn màu"],["button","Lưu danh mục","categories"]]],
  ["report","Báo cáo thống kê","",[["filters","Tháng 11","Tất cả ví"],["card","Thu nhập","4.000.000 đ"],["card","Chi tiêu","1.740.000 đ"],["donut","Phân bổ chi tiêu","Ăn uống · Mua sắm · Khác"],["chart","Thu chi theo tuần","Tuần 1 · Tuần 2 · Tuần 3 · Tuần 4"]]],
  ["login","Đăng nhập","",[["field","Email","Nhập email"],["field","Mật khẩu","Nhập mật khẩu"],["button","Đăng nhập","home"],["link","Quên mật khẩu?","reset"]]],
  ["register","Đăng ký","",[["field","Họ và tên","Nhập họ và tên"],["field","Email","Nhập email"],["field","Số điện thoại","Nhập số điện thoại"],["field","Mật khẩu","Tạo mật khẩu"],["button","Tạo tài khoản","home"]]],
  ["reset","Quên mật khẩu","",[["field","Email","minhanh@example.com"],["button","Gửi mã xác thực","otp"],["link","Quay lại đăng nhập","login"]]],
  ["otp","Đặt lại mật khẩu","",[["field","Mã xác thực","Nhập mã từ email"],["field","Mật khẩu mới","Nhập mật khẩu mới"],["button","Đặt lại mật khẩu","login"]]],
  ["wallet-edit","Chỉnh sửa nguồn tiền","",[["field","Tên nguồn tiền","Tiền mặt"],["field","Loại nguồn tiền","Tiền mặt"],["field","Số dư ban đầu","420.000 đ"],["button","Lưu thay đổi","wallets"],["link","Xóa nguồn tiền","wallet-delete"]]],
  ["wallet-delete","Xóa nguồn tiền?","",[["text","Các giao dịch liên quan đến ví Tiền mặt có thể bị ảnh hưởng."],["button","Quay lại","wallet-edit"],["link","Xóa nguồn tiền","wallets"]],"sheet"],
  ["category-edit","Chỉnh sửa danh mục","",[["field","Tên danh mục","Ăn uống"],["field","Biểu tượng","Chọn biểu tượng"],["field","Màu sắc","Chọn màu"],["button","Lưu thay đổi","categories"],["link","Xóa danh mục","category-delete"]]],
  ["category-delete","Xóa danh mục?","",[["text","Bạn sắp xóa danh mục Ăn uống."],["button","Quay lại","category-edit"],["link","Xóa danh mục","categories"]],"sheet"],
  ["budget-edit","Chỉnh sửa ngân sách","",[["field","Danh mục","Ăn uống"],["field","Hạn mức","1.000.000 đ"],["field","Chu kỳ","Tháng"],["field","Ngày bắt đầu","01/11/2026"],["field","Ngày kết thúc","30/11/2026"],["button","Lưu thay đổi","budgets"],["link","Xóa ngân sách","budget-delete"]]],
  ["budget-delete","Xóa ngân sách?","",[["text","Bạn sắp xóa hạn mức của danh mục Ăn uống."],["button","Quay lại","budget-edit"],["link","Xóa ngân sách","budgets"]],"sheet"],
  ["wallet-picker","Chọn nguồn tiền","",[["card","Tiền mặt","420.000 đ · Mặc định","quick"],["card","Ngân hàng","4.500.000 đ","quick-bank"],["card","Ví điện tử","500.000 đ","quick-ewallet"]],"sheet"],
  ["quick-bank","Giao dịch mới · Ngân hàng","",[],"sheet"],
  ["quick-ewallet","Giao dịch mới · Ví điện tử","",[],"sheet"],
  ["history-filter","Lọc giao dịch","",[["field","Khoảng thời gian","01/11 – 30/11"],["field","Nguồn tiền","Tiền mặt"],["field","Danh mục","Tất cả"],["button","Áp dụng bộ lọc","history-cash"]],"sheet"],
  ["history-cash","Lịch sử · Tiền mặt","Lịch sử",[["field","Tìm giao dịch","Tên danh mục hoặc ghi chú"],["filters","Tháng này","Tiền mặt","Danh mục"],["heading","Hôm nay, 18/11"],["text","Thu 0 đ · Chi −70.000 đ"],["tx","Ăn uống","Tiền mặt · 12:35","−45.000 đ","edit-tx"],["tx","Di chuyển","Tiền mặt · 08:10","−25.000 đ"]]],
  ["categories-income","Danh mục · Thu nhập","",[["tabs","Chi tiêu","Thu nhập"],["card","Lương","Thu nhập"],["card","Thưởng","Thu nhập"],["card","Hoàn tiền","Thu nhập"],["button","Thêm danh mục","category-form-income"]]],
  ["category-form-income","Thêm danh mục thu","",[["tabs","Chi tiêu","Thu nhập"],["field","Tên danh mục","Hoàn tiền"],["field","Biểu tượng","Chọn biểu tượng"],["field","Màu sắc","Chọn màu"],["button","Lưu danh mục","categories-income"]]]
];

const W = 390;
const H = 844;
const contentWidth = 358;
const profileReview = figma.command === 'profile-review';
const detailed = figma.command !== 'wireframe';
const pageName = profileReview ? 'Our Budget · Cá nhân · Bản duyệt'
  : detailed ? 'Giao diện chi tiết · Our Budget · Xác thực' : 'Wireframes · Our Budget · Xác thực';
// Official mark from developers.google.com/static/identity/images/g-logo.png, downsampled to 40 px.
const googleMarkPng = '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';
// Figma's plugin sandbox cannot read the standalone our-budget-wordmark.svg.
const wordmarkSvg = `<svg xmlns="http://www.w3.org/2000/svg" width="204" height="48" viewBox="0 0 204 48">
  <circle cx="16.8" cy="21.6" r="12.4" fill="none" stroke="#1E6F5C" stroke-width="3.6"/>
  <circle cx="16.8" cy="21.6" r="8" fill="none" stroke="#1E6F5C" stroke-width="1.3" opacity=".62"/>
  <path fill="#0F172A" d="M85.6,23.02L85.6,29.66 88.68,29.66C89.99,29.66 91.02,29.36 91.77,28.75 92.51,28.14 92.88,27.31 92.88,26.25 92.88,25.25 92.52,24.45 91.78,23.88 91.05,23.31 90.03,23.02 88.72,23.02L85.6,23.02z M155.05,19.66C153.82,19.66 152.85,20.14 152.15,21.1 151.44,22.06 151.09,23.42 151.09,25.16 151.09,26.66 151.43,27.85 152.09,28.72 152.76,29.6 153.68,30.03 154.84,30.03 155.98,30.03 156.91,29.59 157.62,28.71 158.33,27.82 158.69,26.65 158.69,25.2L158.69,23.77C158.69,22.64 158.35,21.67 157.68,20.87 157,20.06 156.13,19.66 155.05,19.66z M132.73,19.66C131.5,19.66 130.54,20.14 129.85,21.11 129.15,22.08 128.81,23.41 128.81,25.09 128.81,26.67 129.14,27.89 129.81,28.75 130.48,29.6 131.4,30.03 132.59,30.03 133.71,30.03 134.63,29.58 135.34,28.68 136.05,27.78 136.4,26.58 136.4,25.09L136.4,23.74C136.4,22.57 136.06,21.59 135.38,20.82 134.7,20.05 133.82,19.66 132.73,19.66z M176.7,19.15C175.81,19.15 175.04,19.52 174.39,20.26 173.74,21 173.34,21.92 173.2,23.02L179.83,23.02C179.83,20.44,178.78,19.15,176.7,19.15z M102.18,15.85L107.71,15.85 107.71,26.22C107.71,28.76 108.72,30.03 110.74,30.03 111.73,30.03 112.53,29.68 113.13,28.99 113.73,28.29 114.02,27.34 114.02,26.15L114.02,15.85 119.56,15.85 119.56,33.85 114.02,33.85 114.02,31.1 113.94,31.1C112.57,33.23 110.73,34.29 108.43,34.29 104.26,34.29 102.18,31.76 102.18,26.71L102.18,15.85z M33.06,15.85L38.59,15.85 38.59,26.22C38.59,28.76 39.6,30.03 41.62,30.03 42.61,30.03 43.41,29.68 44.01,28.99 44.61,28.29 44.9,27.34 44.9,26.15L44.9,15.85 50.44,15.85 50.44,33.85 44.9,33.85 44.9,31.1 44.82,31.1C43.45,33.23 41.61,34.29 39.31,34.29 35.14,34.29 33.06,31.76 33.06,26.71L33.06,15.85z M65.49,15.53C66.07,15.53,66.53,15.6,66.86,15.74L66.86,20.86C66.19,20.49 65.41,20.31 64.52,20.31 63.32,20.31 62.37,20.75 61.69,21.64 61.01,22.52 60.67,23.73 60.67,25.25L60.67,33.85 55.12,33.85 55.12,15.85 60.67,15.85 60.67,19.19 60.74,19.19C61.62,16.75,63.2,15.53,65.49,15.53z M176.73,15.41C179.36,15.41 181.39,16.19 182.82,17.75 184.26,19.3 184.98,21.42 184.98,24.09L184.98,26.43 173.24,26.43C173.42,29.04 175.07,30.35 178.18,30.35 180.16,30.35 181.9,29.88 183.4,28.94L183.4,32.95C181.73,33.84 179.57,34.29 176.91,34.29 174,34.29 171.75,33.48 170.14,31.87 168.54,30.26 167.73,28.01 167.73,25.13 167.73,22.14 168.6,19.77 170.34,18.03 172.07,16.28 174.2,15.41 176.73,15.41z M153.62,15.41C155.81,15.41,157.46,16.25,158.55,17.94L158.62,17.94 158.62,15.85 164.17,15.85 164.17,31.79C164.17,35.13 163.2,37.72 161.27,39.55 159.34,41.38 156.54,42.3 152.87,42.3 150.44,42.3 148.52,41.96 147.1,41.26L147.1,36.59C148.95,37.67 150.82,38.21 152.71,38.21 154.58,38.21 156.04,37.71 157.07,36.72 158.1,35.73 158.62,34.39 158.62,32.69L158.62,31.26 158.55,31.26C157.28,33.28 155.41,34.29 152.94,34.29 150.64,34.29 148.82,33.48 147.47,31.86 146.12,30.24 145.45,28.08 145.45,25.36 145.45,22.31 146.2,19.89 147.7,18.1 149.2,16.3 151.17,15.41 153.62,15.41z M85.6,12.82L85.6,18.8 88.1,18.8C89.27,18.8 90.2,18.52 90.87,17.95 91.54,17.38 91.88,16.6 91.88,15.6 91.88,13.75 90.5,12.82 87.73,12.82L85.6,12.82z M195.12,10.38L195.12,15.85 199.16,15.85 199.16,19.94 195.12,19.94 195.12,27.22C195.12,29.09 195.86,30.03 197.35,30.03 197.94,30.03 198.54,29.86 199.16,29.52L199.16,33.64C198.34,34.07 197.11,34.29 195.45,34.29 191.54,34.29 189.58,32.25 189.58,28.19L189.58,19.94 186.66,19.94 186.66,15.85 189.58,15.85 189.58,11.96 195.12,10.38z M79.93,8.64L89.1,8.64C91.92,8.64 94.08,9.16 95.59,10.19 97.1,11.22 97.86,12.67 97.86,14.55 97.86,15.91 97.4,17.09 96.48,18.11 95.56,19.13 94.38,19.84 92.95,20.24L92.95,20.31C94.75,20.53 96.18,21.2 97.25,22.3 98.32,23.4 98.86,24.74 98.86,26.32 98.86,28.63 98.03,30.46 96.38,31.82 94.73,33.17 92.47,33.85 89.61,33.85L79.93,33.85 79.93,8.64z M136.3,7.2L141.85,7.2 141.85,33.85 136.3,33.85 136.3,31.37 136.23,31.37C134.96,33.31 133.1,34.29 130.65,34.29 128.4,34.29 126.59,33.49 125.22,31.9 123.85,30.32 123.17,28.1 123.17,25.25 123.17,22.27 123.92,19.89 125.43,18.1 126.94,16.3 128.93,15.41 131.37,15.41 133.69,15.41 135.31,16.24 136.23,17.9L136.3,17.9 136.3,7.2z"/>
</svg>`;
const navigation = { 'Trang chủ': '4:17', 'Lịch sử': '4:26', 'Ngân sách': '4:30', 'Cá nhân': '4:34' };
const tabs = { 'Trang chủ': 'home', 'Lịch sử': 'history', 'Ngân sách': 'budgets', 'Cá nhân': 'profile' };
const sheets = { quick: '4:149', income: '4:173', error: '4:197', optional: '4:249', 'quick-bank': '4:149', 'quick-ewallet': '4:149' };
const groups = [
  ['Tổng quan và ghi chép', ['home', 'alert', 'quick', 'income', 'optional', 'error', 'wallet-picker', 'quick-bank', 'quick-ewallet']],
  ['Lịch sử giao dịch', ['history', 'history-filter', 'history-cash', 'edit-tx', 'delete-tx']],
  ['Ngân sách và báo cáo', ['budgets', 'budget-form', 'budget-edit', 'budget-delete', 'report']],
  ['Cá nhân, nguồn tiền và danh mục', ['profile', 'profile-edit', 'wallets', 'wallet-form', 'wallet-edit', 'wallet-delete', 'transfer', 'categories', 'categories-income', 'category-form', 'category-form-income', 'category-edit', 'category-delete']],
  ['Đăng nhập và khôi phục', ['login', 'register', 'reset', 'otp']]
];
const detailGroups = [
  ['Đăng nhập và đăng ký', ['login', 'register']],
  ['Ghi chép hằng ngày', ['home', 'history', 'budgets', 'report']],
  ['Quản lý tài khoản', ['profile', 'wallets', 'categories']]
];
const detailRows = {
  login: SCREENS.find(screen => screen[0] === 'login')[3].filter(row => row[2] !== 'reset'),
  home: [
    ['balance', 'Tổng số dư khả dụng', '5.420.000 đ'],
    ['budget', 'Ngân sách tháng', '1.740.000 đ / 3.000.000 đ', '58% · An toàn', '58', 'budgets'],
    ['heading', 'Giao dịch gần đây', 'Xem tất cả', 'history'],
    ...SCREENS[0][3].filter(row => row[0] === 'tx').slice(0, 3)
  ],
  history: [
    ['filters', 'Tháng 11', 'Tất cả ví', 'Danh mục'],
    ...SCREENS.find(screen => screen[0] === 'history')[3].filter(row => row[0] === 'heading' || row[0] === 'tx')
  ],
  categories: [
    ['heading', 'Chi tiêu'],
    ...SCREENS.find(screen => screen[0] === 'categories')[3].filter(row => row[0] === 'card').slice(0, 3),
    ['heading', 'Thu nhập'],
    ...SCREENS.find(screen => screen[0] === 'categories-income')[3].filter(row => row[0] === 'card').slice(0, 2),
    ['button', 'Thêm danh mục']
  ]
};
const back = {
  'edit-tx': 'history', 'budget-form': 'budgets', 'budget-edit': 'budgets',
  'profile-edit': 'profile', wallets: 'profile', 'wallet-form': 'wallets', 'wallet-edit': 'wallets',
  transfer: 'wallets', categories: 'profile', 'categories-income': 'profile',
  'category-form': 'categories', 'category-form-income': 'categories-income', 'category-edit': 'categories', report: 'budgets',
  reset: 'login', otp: 'reset'
};
const bankNames = { 'quick-bank': 'Ngân hàng', 'quick-ewallet': 'Ví điện tử' };
const overlayReturn = { 'delete-tx': 'edit-tx', 'wallet-delete': 'wallet-edit', 'category-delete': 'category-edit', 'budget-delete': 'budget-edit', 'wallet-picker': 'quick', 'history-filter': 'history' };
const reviewScreens = [
  ['profile-edit', 'Thông tin tài khoản', '', []],
  ['avatar-preview', 'Ảnh đại diện', '', []],
  ['quick', 'Thêm giao dịch', '', []],
  ['help', 'Trợ giúp & Phản hồi', '', []],
  ['about', 'Giới thiệu về ứng dụng', '', []],
  ['notifications', 'Thông báo', '', []],
  ['settings', 'Cài đặt', '', []]
];
const reviewGroups = [
  ['Cá nhân và điều hướng', ['profile', 'profile-edit', 'home', 'history', 'budgets', 'quick']],
  ['Các màn hình liên quan', ['wallets', 'categories', 'help', 'about', 'notifications', 'settings', 'login', 'avatar-preview']]
];
const reviewIcons = {
  person: '<circle cx="12" cy="8" r="4"/><path d="M4 21v-2a8 5 0 0 1 16 0v2"/>',
  edit: '<path d="m4 16 12-12 4 4L8 20H4zM14 6l4 4"/>',
  notifications: '<path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9M10 21h4"/>',
  settings: '<path d="M10 3h4l1 3 3 1 2-1 2 4-2 2v2l2 2-2 4-3-1-2 1-1 2h-4l-1-2-2-1-3 1-2-4 2-2v-2l-2-2 2-4 2 1 3-1z"/><circle cx="12" cy="12" r="3"/>',
  wallet: '<path d="M20 8V5H5a2 2 0 0 0 0 4h16v11H5a2 2 0 0 1-2-2V7M21 12h-6v4h6"/>',
  category: '<path d="m7 3 5 8H2zM3 15h8v7H3z"/><circle cx="17.5" cy="17.5" r="4"/>',
  help: '<circle cx="12" cy="12" r="9"/><path d="M9 9a3 3 0 1 1 5 2c-2 1-2 2-2 3m0 3h.01"/>',
  info: '<circle cx="12" cy="12" r="9"/><path d="M12 11v6m0-10h.01"/>',
  chevron: '<path d="m9 6 6 6-6 6"/>',
  back: '<path d="m12 5-7 7 7 7M5 12h14"/>'
};
let step = 'Kiểm tra tệp và thư viện';

const reviewNavName = 'Bottom Navigation Bar / 5 mục';
const addTransactionLabel = 'Thêm giao dịch';
const oldNavAudit = 'Nhãn trung tâm dùng AppTypography/captionLabel.';
const newNavAudit = 'Nút trung tâm chỉ hiển thị biểu tượng +.';
const fabName = /FloatingActionButton|Thêm giao dịch|Ghi giao dịch/i;

function checkReviewNav(set) {
  const labels = Object.keys(navigation);
  if (set?.type !== 'COMPONENT_SET' || set.children.length !== labels.length) {
    throw Error('Không tìm thấy đủ bốn biến thể thanh điều hướng trên trang bản duyệt.');
  }
  return labels.map(label => {
    const variant = set.children.find(n => n.name === 'Selected=' + label);
    const original = variant?.findChild(n => n.type === 'INSTANCE');
    const fab = original?.findOne(n => fabName.test(n.name));
    if (!fab || fab.width < 44 || fab.height < 44 ||
        Math.abs(fab.absoluteTransform[0][2] + fab.width/2 -
          variant.absoluteTransform[0][2] - variant.width/2) > 4) {
      throw Error('Kiểm tra instance điều hướng và vị trí nút + của biến thể ' + label + '.');
    }
    if (original.findOne(n => n.type === 'TEXT' && n.visible && n.characters === addTransactionLabel)) {
      throw Error('Instance gốc có nhãn Thêm giao dịch trong biến thể ' + label + '.');
    }
    return variant;
  });
}

function styleLogout(button, vars) {
  for (const key of ['expense', 'primaryMain', 'surface']) {
    if (vars[key]?.resolvedType !== 'COLOR') throw Error('Thiếu biến màu ' + key);
  }
  const label = button.findOne(n => n.type === 'TEXT' && n.characters === 'Đăng xuất');
  const isBackground = node => {
    if (node.type === 'TEXT' || !node.visible || !Array.isArray(node.fills)) return false;
    return node.fills.some(fill => fill.type === 'SOLID' && fill.visible !== false &&
      ['primaryMain', 'expense'].some(key => {
        const variable = vars[key];
        if (fill.boundVariables?.color) return fill.boundVariables.color.id === variable.id;
        const color = variable.resolveForConsumer(node).value;
        return ['r', 'g', 'b'].every(channel => Math.abs(fill.color[channel] - color[channel]) < 0.005);
      }));
  };
  const background = isBackground(button) ? button : button.findOne(isBackground);
  if (!background || !label) throw Error('Không tìm thấy nền hoặc chữ của nút Đăng xuất.');
  const bindFill = (node, variable) => {
    const { r, g, b } = variable.resolveForConsumer(node).value;
    node.fills = [figma.variables.setBoundVariableForPaint(
      {type:'SOLID',color:{r,g,b}}, 'color', variable
    )];
  };
  bindFill(background, vars.expense);
  bindFill(label, vars.surface);
}

async function updateReviewPage(page) {
  const set = page.findChild(n => n.name === reviewNavName);
  const captions = checkReviewNav(set).flatMap(variant =>
    variant.children.filter(n => n.type === 'TEXT' && n.characters === addTransactionLabel));
  const audit = page.findChild(n => n.name === 'Kiểm kê và ghi chú duyệt');
  const note = audit?.findOne(n => n.type === 'TEXT' && n.characters.includes(oldNavAudit));
  if (note) {
    const fonts = note.getRangeAllFontNames(0, note.characters.length);
    await Promise.all(fonts.map(font => figma.loadFontAsync(font)));
    const start = note.characters.indexOf(oldNavAudit);
    note.insertCharacters(start, newNavAudit, 'AFTER');
    note.deleteCharacters(start + newNavAudit.length,start + newNavAudit.length + oldNavAudit.length);
  }
  const profile = page.findChild(n => n.type === 'FRAME' && n.name === 'Cá nhân');
  const logout = profile?.findChild(n => n.type === 'INSTANCE' && n.name === 'Đăng xuất');
  if (!logout) throw Error('Không tìm thấy nút Đăng xuất trên màn hình Cá nhân.');
  const vars = Object.fromEntries((await figma.variables.getLocalVariablesAsync()).map(v => [v.name, v]));
  styleLogout(logout, vars);
  captions.forEach(node => node.remove());
  page.selection = [logout];
  figma.viewport.scrollAndZoomIntoView([profile]);
  figma.closePlugin('Đã cập nhật nút Đăng xuất và thanh điều hướng trên trang bản duyệt.');
}

async function build() {
  const existing = figma.root.children.find(p => p.name === pageName);
  if (existing) {
    await figma.setCurrentPageAsync(existing);
    if (profileReview) return updateReviewPage(existing);
    figma.closePlugin('Trang đã có trong tệp.');
    return;
  }

  const idList = [...new Set([...Object.values(navigation), ...Object.values(sheets), '4:94', '4:146', '4:101', '4:109', '4:119', '4:128', '4:137', '4:340'])];
  const source = Object.fromEntries(await Promise.all(idList.map(async id => [id, await figma.getNodeByIdAsync(id)])));
  if (idList.some(id => source[id]?.type !== 'COMPONENT')) throw Error('Mở đúng tệp Our Budget chứa trang Component Library.');
  const vars = Object.fromEntries((await figma.variables.getLocalVariablesAsync()).map(v => [v.name, v]));
  const styles = Object.fromEntries((await figma.getLocalTextStylesAsync()).filter(s => s.name.startsWith('AppTypography/')).map(s => [s.name.split('/')[1], s]));
  const required = ['primaryMain','primarySoft','background','surface','border','textPrimary','textMuted','income','incomeTextAA','expense','warning'];
  if (required.some(key => !vars[key])) throw Error('Thiếu biến màu trong tệp Our Budget.');
  if (['headingH1','headingH2','bodyRegular','bodyMedium','captionLabel','numericAmount','displayBalance'].some(key => !styles[key] || styles[key].fontName.family !== 'Inter')) throw Error('Thiếu kiểu chữ Inter trong tệp Our Budget.');
  const library = profileReview ? await figma.getNodeByIdAsync('2:45') : null;
  if (profileReview && library?.type !== 'PAGE') throw Error('Không tìm thấy trang Component Library.');
  if (library) await library.loadAsync();
  const localComponents = library?.findAllWithCriteria({ types: ['COMPONENT', 'COMPONENT_SET'] }) ?? [];
  const lookup = names => {
    const match = localComponents.find(n => names.includes(n.name.trim().toLowerCase()));
    return match?.type === 'COMPONENT_SET' ? match.defaultVariant : match;
  };
  const fonts = [...Object.values(styles).map(s => s.fontName)];
  for (const component of Object.values(source)) {
    for (const text of component.findAll(node => node.type === 'TEXT')) {
      fonts.push(...text.getRangeAllFontNames(0, text.characters.length));
    }
  }
  await Promise.all([...new Map(fonts.map(font => [JSON.stringify(font), font])).values()].map(font => figma.loadFontAsync(font)));

  const page = figma.createPage();
  page.name = pageName + ' · Đang tạo';
  try {
    await figma.setCurrentPageAsync(page);
    const destinations = {};
    const screenGroups = profileReview ? reviewGroups : detailed ? detailGroups : groups;
    const screenIds = new Set(screenGroups.flatMap(([, ids]) => ids));
    const handlers = [];
    const textStyles = [];
    const contentBounds = [];
    const bottomPanels = [];
    const paint = (node, key, opacity = 1) => {
      const { value: { r, g, b } } = vars[key].resolveForConsumer(node);
      return figma.variables.setBoundVariableForPaint({ type: 'SOLID', color: { r, g, b }, opacity }, 'color', vars[key]);
    };
    const solid = (node, key, opacity) => { node.fills = [paint(node, key, opacity)]; return node; };
    const outline = (node, key = 'border') => { node.strokes = [paint(node, key)]; node.strokeWeight = 1; node.strokeAlign = 'INSIDE'; return node; };
    const bind = (node, key, token) => { if (vars[token]) node.setBoundVariable(key, vars[token]); };
    const pad = (node, x, y) => {
      for (const side of ['Left', 'Right', 'Top', 'Bottom']) {
        const n = ['Left', 'Right'].includes(side) ? x : y;
        node['padding' + side] = n;
        bind(node, 'padding' + side, 'AppSpacing/' + n);
      }
    };
    const stack = (name, width, children, options = {}) => {
      const n = figma.createFrame();
      n.name = name;
      n.fills = [];
      n.clipsContent = false;
      n.layoutMode = options.horizontal ? 'HORIZONTAL' : 'VERTICAL';
      // resize() fixes both axes. Restore Hug contents after setting the width.
      if (width) n.resize(width, 1);
      n.primaryAxisSizingMode = options.horizontal && width ? 'FIXED' : 'AUTO';
      n.counterAxisSizingMode = !options.horizontal && width ? 'FIXED' : 'AUTO';
      n.counterAxisAlignItems = options.horizontal ? 'CENTER' : 'MIN';
      n.itemSpacing = options.gap ?? 8;
      bind(n, 'itemSpacing', 'AppSpacing/' + n.itemSpacing);
      if (options.padding) pad(n, ...options.padding);
      for (const child of children) n.appendChild(child);
      if (options.spread) n.primaryAxisAlignItems = 'SPACE_BETWEEN';
      return n;
    };
    const t = (label, style = 'bodyRegular', color = 'textPrimary', width) => {
      const n = figma.createText();
      n.fontName = styles[style].fontName;
      n.characters = label;
      n.name = label;
      textStyles.push(n.setTextStyleIdAsync(styles[style].id).then(() => {
        solid(n, color);
        if (width) n.resize(width, n.height);
        n.textAutoResize = width || n.layoutSizingHorizontal === 'FILL' ? 'HEIGHT' : 'WIDTH_AND_HEIGHT';
      }));
      return n;
    };
    const radius = (node, value, token) => {
      node.cornerRadius = value;
      for (const corner of ['topLeftRadius','topRightRadius','bottomLeftRadius','bottomRightRadius']) bind(node, corner, 'AppRadius/' + token);
      return node;
    };
    const rect = (name, w, h, color) => {
      const n = figma.createRectangle();
      n.name = name;
      n.resize(w, h);
      return solid(n, color);
    };
    const card = (name, children) => {
      const n = radius(outline(solid(stack(name, contentWidth, children, { padding: [16, 12], gap: 8 }), 'surface')), 16, 'radiusCard');
      n.effects = [{type:'DROP_SHADOW',color:{r:0,g:0,b:0,a:0.04},offset:{x:0,y:2},radius:8,spread:0,visible:true,blendMode:'NORMAL'}];
      return n;
    };
    const click = (node, destination) => {
      if (node && destination && (!detailed || destination === 'back' || screenIds.has(destination))) handlers.push([node, destination]);
      return node;
    };
    const use = (id, name) => {
      const n = source[id].createInstance();
      if (name) n.name = name;
      return n;
    };
    const overrides = (node, values) => {
      const children = node.findAll(x => x.type === 'TEXT');
      for (let i = 0; i < values.length; i++) if (values[i] != null && children[i]) children[i].characters = values[i];
    };
    const part = (node, name) => node.findOne(x => x.name === name || x.type === 'TEXT' && x.characters === name);
    const link = (label, dst, danger = false) => click(stack(label, contentWidth, [t(label, 'bodyMedium', danger ? 'expense' : 'primaryMain')], { horizontal: true, padding: [0, 12] }), dst);

    const shadowed = (id, title, amount) => {
      const n = use(id);
      if (id === '4:94') {
        n.setProperties({ 'Số dư#4:0': amount });
        if (title !== 'Tổng số dư khả dụng') overrides(n, [title]);
      }
      return n;
    };
    const budget = (title, value, state, percent, dst) => {
      const n = use(Number(percent) >= 100 ? '4:137' : Number(percent) >= 80 ? '4:128' : '4:119');
      n.setProperties({ 'Danh mục#4:13': title });
      overrides(n, [null, percent + '%', value, state.split(' · ')[1]]);
      const track = part(n, 'Tiến trình');
      if (track && 'children' in track && track.children.length) {
        const fill = track.children[0];
        if ('resize' in fill) fill.resize(track.width * Math.min(Number(percent), 100) / 100, fill.height);
      }
      return click(n, dst);
    };
    const field = (label, value, err) => {
      const input = radius(outline(solid(stack('Ô nhập · ' + label, contentWidth, [t(value, 'bodyRegular', 'textPrimary', contentWidth - 24)], { horizontal: true, padding: [12, 12] }), 'surface'), err ? 'expense' : 'border'), 8, 'radiusSmall');
      return stack(label, contentWidth, [t(label, 'bodyMedium'), input, ...(err ? [t(err, 'captionLabel', 'expense', contentWidth)] : [])], { gap: 4 });
    };
    const button = (label, dst) => {
      const n = use('4:146', label);
      overrides(n, [label]);
      return click(n, dst);
    };
    const chip = label => radius(outline(solid(stack(label, null, [t(label, 'bodyMedium', 'primaryMain')], { horizontal: true, padding: [12, 8] }), 'primarySoft')), 8, 'radiusSmall');

    const render = (row, screen) => {
      const [kind, a, b, c, d, e] = row;
      switch (kind) {
        case 'balance': return shadowed('4:94', a, b);
        case 'budget': return budget(a, b, c, d, e || (screen === 'home' || screen === 'alert' ? 'budgets' : 'budget-edit'));
        case 'tx': {
          const n = use(c.startsWith('+') ? '4:109' : '4:101', a);
          overrides(n, [a, b, c]);
          const amount = n.findAll(x => x.type === 'TEXT')[2];
          if (amount && c.startsWith('+')) solid(amount, 'incomeTextAA');
          return click(n, d || (screen === 'home' ? 'history' : null));
        }
        case 'heading': return b ? stack(a, contentWidth, [t(a, 'headingH2'), click(t(b, 'bodyMedium', 'primaryMain'), c)], { horizontal: true, spread: true }) : t(a, 'headingH2');
        case 'text': return t(a, 'bodyRegular', 'textPrimary', contentWidth);
        case 'field': return field(a, b);
        case 'error': return field(a, b, c);
        case 'button': return button(a, b);
        case 'link': return link(a, b, a.startsWith('Xóa'));
        case 'filters': return click(stack('Bộ lọc', contentWidth, row.slice(1).map(chip), { horizontal: true }), screen.startsWith('history') ? 'history-filter' : null);
        case 'tabs': {
          const form = screen.startsWith('category-form');
          const selected = screen.includes('income');
          return stack('Loại danh mục', contentWidth, [
            click(chip(selected ? 'Chi tiêu' : '✓ Chi tiêu'), form ? 'category-form' : 'categories'),
            click(chip(selected ? '✓ Thu nhập' : 'Thu nhập'), form ? 'category-form-income' : 'categories-income')
          ], { horizontal: true });
        }
        case 'card': return click(card(a, [t(a, 'headingH2'), t(b, /\d+.*đ/.test(b) ? 'numericAmount' : 'bodyRegular')]), c);
        case 'alert': {
          const n = use('4:340');
          n.setProperties({ 'Nội dung cảnh báo#4:43': a + ' · 102%.' });
          return click(n, c);
        }
        case 'donut': {
          const segments = figma.createFrame();
          segments.name = 'Tỷ trọng theo danh mục';
          segments.fills = [];
          segments.resize(112, 112);
          const parts = [[0, 0.34, 'primaryMain'], [0.34, 0.64, 'expense'], [0.64, 1, 'warning']];
          for (const [start,end,color] of parts) {
            const wedge = figma.createEllipse();
            wedge.resize(112, 112);
            wedge.arcData = { startingAngle: start * 2 * Math.PI, endingAngle: end * 2 * Math.PI, innerRadius: 0.67 };
            solid(wedge,color);
            segments.appendChild(wedge);
            wedge.x = 0; wedge.y = 0;
          }
          return card(a, [t(a,'headingH2'), segments, t('Ăn uống 34% · Mua sắm 30% · Khác 36%','captionLabel')]);
        }
        case 'chart': {
          const pairs = [[28,40],[96,62],[48,44],[68,78]].map(([income,expense], i) => {
            const pair = stack('Thu và chi', null, [rect('Thu',16,income,'income'),rect('Chi',16,expense,'expense')],{horizontal:true,gap:4});
            pair.counterAxisAlignItems = 'MAX';
            return stack('Tuần ' + (i+1),null,[pair,t('Tuần ' + (i+1),'captionLabel')]);
          });
          const bars = stack('Biểu đồ cột', contentWidth - 32, pairs, { horizontal: true, spread: true });
          bars.counterAxisAlignItems = 'MAX';
          return card(a, [t(a,'headingH2'), bars, t('Xanh · Thu nhập     Đỏ · Chi tiêu','captionLabel')]);
        }
        default: throw Error('Không nhận dạng được nhóm ' + kind);
      }
    };

    const screen = (title, parent, x, y) => {
      const n = figma.createFrame();
      n.name = title;
      n.resize(W, H);
      n.x = x; n.y = y;
      n.clipsContent = true;
      solid(n, 'background');
      n.layoutGrids = [{ pattern:'COLUMNS', alignment:'STRETCH', gutterSize:12, count:4, offset:16, visible:false }];
      parent.appendChild(n);
      return n;
    };
    const place = (parent, n, x, y) => { parent.appendChild(n); n.x=x; n.y=y; return n; };
    const header = (title, dst) =>
      stack('Thanh tiêu đề', contentWidth, [
        ...(dst ? [click(t('‹', 'headingH1', 'primaryMain'), dst)] : []),
        t(title, 'headingH1')
      ], { horizontal:true, gap:12 });
    const nav = (frame, active) => {
      const n = place(frame,use(navigation[active]),0,H-88);
      for (const child of n.children) click(child, tabs[child.name] || (child.name.includes('FloatingActionButton') ? 'quick' : null));
    };
    const reused = new Set();
    const fallbacks = new Set();
    const icon = (key, size = 24) => {
      const component = lookup([key, 'icon/' + key, 'icons/' + key]);
      if (component && component.width === 24 && component.height === 24) {
        const instance = component.createInstance();
        if (size !== 24) instance.rescale(size / 24);
        reused.add(component.name);
        return instance;
      }
      fallbacks.add('Icon · ' + key);
      const node = figma.createNodeFromSvg(
        '<svg xmlns="http://www.w3.org/2000/svg" width="' + size + '" height="' + size +
        '" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">' +
        reviewIcons[key] + '</svg>'
      );
      node.name = 'Icon · ' + key;
      for (const child of node.findAll(n => n.type === 'VECTOR')) child.strokes = [paint(child, 'textMuted')];
      return node;
    };
    const actionIcon = (label, key, dst) => {
      const node = stack(label, 48, [icon(key)], { horizontal:true, gap:0 });
      node.resize(48,48);
      node.layoutSizingVertical = 'FIXED';
      node.primaryAxisAlignItems = 'CENTER';
      return click(node, dst);
    };
    const fillWidth = node => { node.layoutSizingHorizontal = 'FILL'; return node; };
    const profileHeader = (title, main, showBack) => {
      const heading = t(title, 'headingH1');
      const actions = main ? [
        actionIcon('Thông báo', 'notifications', 'notifications'),
        actionIcon('Cài đặt', 'settings', 'settings')
      ] : [];
      const node = stack('Thanh tiêu đề', contentWidth, [
        ...(showBack ? [actionIcon('Quay lại', 'back', 'back')] : []), heading, ...actions
      ], { horizontal:true, gap:4 });
      fillWidth(heading);
      return node;
    };
    const avatar = dst => {
      const existing = lookup(['avatar', 'ảnh đại diện']);
      const node = existing ? existing.createInstance() : solid(stack('Ảnh đại diện',64,[icon('person',32)],{gap:0}), 'primarySoft');
      if (existing) reused.add(existing.name);
      else {
        fallbacks.add('Ảnh đại diện');
        node.resize(64,64);
        node.layoutSizingVertical = 'FIXED';
        node.counterAxisAlignItems = 'CENTER';
        node.primaryAxisAlignItems = 'CENTER';
        radius(node,32,'radiusFull');
      }
      return stack('Ảnh đại diện và nút chỉnh sửa', null,
        [node, actionIcon('Chỉnh ảnh đại diện', 'edit', dst)], {horizontal:true, gap:0});
    };
    const verified = () => {
      const existing = lookup(['badge / verified','badge/verified','đã xác minh']);
      if (existing?.findOne(n => n.type === 'TEXT' && n.characters === 'Đã xác minh')) {
        reused.add(existing.name);
        return existing.createInstance();
      }
      fallbacks.add('Nhãn xác minh');
      return radius(solid(stack('Trạng thái email',null,[t('Đã xác minh','captionLabel','primaryMain')],
        {horizontal:true,padding:[8,4]}),'primarySoft'),8,'radiusSmall');
    };
    const menuItems = [
      ['Thông tin tài khoản','person','profile-edit'],
      ['Quản lý ví','wallet','wallets'],
      ['Danh mục','category','categories'],
      ['Trợ giúp & Phản hồi','help','help'],
      ['Giới thiệu về ứng dụng','info','about']
    ];
    let menuRow, menuLabel;
    const reviewRow = (label, key) => {
      if (!menuRow) {
        menuRow = figma.createComponent();
        menuRow.name = 'Profile / Menu Item';
        const title = t('Thông tin tài khoản','bodyMedium');
        const base = stack('Nội dung mục',contentWidth,[title,icon('chevron',20)],
          {horizontal:true,padding:[12,12],gap:12});
        base.paddingLeft = 48;
        bind(base,'paddingLeft','AppSpacing/48');
        fillWidth(title);
        menuRow.layoutMode = 'VERTICAL';
        menuRow.resize(contentWidth,48);
        menuRow.counterAxisSizingMode = 'FIXED';
        menuRow.primaryAxisSizingMode = 'AUTO';
        menuRow.fills = [];
        menuRow.appendChild(base);
        fillWidth(base);
        menuRow.x = 2800;
        menuRow.y = 680;
        menuLabel = menuRow.addComponentProperty('Nhãn','TEXT','Thông tin tài khoản');
        title.componentPropertyReferences = {characters:menuLabel};
      }
      const row = menuRow.createInstance();
      row.setProperties({[menuLabel]:label});
      const wrapper = stack(label,contentWidth,[row],{gap:0});
      fillWidth(row);
      const leading = icon(key);
      wrapper.appendChild(leading);
      leading.layoutPositioning = 'ABSOLUTE';
      leading.x = 12;
      leading.y = 12;
      return wrapper;
    };
    const menuGroup = (name, rows) => {
      const children = rows.flatMap(([label,key,dst], i) => {
        const existing = lookup([label.toLowerCase()]);
        const useExisting = existing?.findOne(n => n.type === 'TEXT' && n.characters === label);
        let row;
        if (useExisting) {
          reused.add(existing.name);
          row = click(existing.createInstance(),dst);
        } else {
          fallbacks.add('Mục danh sách');
          row = click(reviewRow(label,key),dst);
        }
        return [...(i ? [rect('Đường phân cách',contentWidth,1,'border')] : []),row];
      });
      const group = radius(outline(solid(stack(name, contentWidth, children,{gap:0}),'surface')),16,'radiusCard');
      children.forEach(fillWidth);
      return group;
    };
    const variantsByTab = {};
    const navSlots = {};
    let navHeight;
    if (profileReview) {
      step = 'Tạo biến thể thanh điều hướng';
      const variants = Object.entries(navigation).map(([label,id]) => {
        const variant = figma.createComponent();
        variant.name = 'Selected=' + label;
        const original = use(id);
        reused.add(source[id].name);
        const fab = original.findOne(n => fabName.test(n.name));
        if (!fab) throw Error('Không tìm thấy nút thêm giao dịch trong ' + source[id].name);
        const extra = 24;
        variant.resize(W,original.height + extra);
        variant.clipsContent = false;
        navHeight = variant.height;
        solid(variant,'surface');
        original.resize(W,original.height);
        place(variant,original,0,0);
        original.constraints = {horizontal:'STRETCH',vertical:'MIN'};
        const center = fab.absoluteTransform[0][2] - variant.absoluteTransform[0][2] + fab.width/2;
        const top = fab.absoluteTransform[1][2] - variant.absoluteTransform[1][2];
        if (Math.abs(center-W/2)>4 || fab.width<44 || fab.height<44) {
          throw Error('Kiểm tra lại vị trí hoặc kích thước nút nổi trong ' + source[id].name);
        }
        navSlots[label] = {top};
        variantsByTab[label] = variant;
        return variant;
      });
      const set = figma.combineAsVariants(variants,page);
      set.name = reviewNavName;
      set.description = 'Bốn trạng thái đích từ Component Library. Hành động trung tâm mở Thêm giao dịch.';
      variants.forEach((v,i) => { v.x = 16; v.y = 16 + i * (navHeight+16); });
      set.resize(W+32,16+variants.length*(navHeight+16));
      set.x = 2800;
      set.y = 64;
    }
    const reviewNav = (frame, active) => {
      const instance = variantsByTab[active].createInstance();
      place(frame,instance,0,H-instance.height);
      instance.constraints = {horizontal:'STRETCH',vertical:'MAX'};
      const hitStrip = stack('Điểm chạm điều hướng',W,[],{horizontal:true,gap:0});
      const start = Math.min(0,navSlots[active].top);
      hitStrip.resize(W,instance.height-start);
      hitStrip.primaryAxisSizingMode = 'FIXED';
      hitStrip.counterAxisSizingMode = 'FIXED';
      place(frame,hitStrip,0,instance.y+start);
      hitStrip.constraints = {horizontal:'STRETCH',vertical:'MAX'};
      const destinationsBySlot = [...Object.entries(tabs)];
      destinationsBySlot.splice(2,0,[addTransactionLabel,'quick']);
      for (const [label,dst] of destinationsBySlot) {
        const target = figma.createFrame();
        target.name = label;
        target.fills = [];
        hitStrip.appendChild(target);
        fillWidth(target);
        target.layoutSizingVertical = 'FILL';
        click(target,dst);
      }
    };
    const reviewContent = (frame, id, title, active, rows) => {
      if (id === 'login') return drawContent(frame,[id,title,active,rows]);
      const main = id === 'profile';
      const headerNode = place(frame,profileHeader(title,main,!main && !active),16,24);
      headerNode.constraints = {horizontal:'STRETCH',vertical:'MIN'};
      let content = rows.map(row => render(row,id));
      if (main) content = [
        stack('Hồ sơ',contentWidth,[avatar('profile-edit'),
          stack('Danh tính',null,[t('Minh Anh','headingH2'),t('minhanh@example.com','bodyRegular','textMuted'),verified()],{gap:4})
        ],{horizontal:true,gap:8}),
        menuGroup('Tài khoản và tài chính',menuItems.slice(0,3)),
        menuGroup('Hỗ trợ và ứng dụng',menuItems.slice(3))
      ];
      if (id === 'profile-edit') content = [
        avatar('avatar-preview'), verified(),
        field('Họ và tên','Minh Anh'),
        field('Email','minhanh@example.com'),
        field('Số điện thoại','090 000 0000'),
        button('Lưu thay đổi','profile')
      ];
      if (id === 'quick') {
        const sheet = use(sheets.quick);
        reused.add(source[sheets.quick].name);
        content = [sheet];
        click(part(sheet,'Lưu giao dịch'),'back');
      }
      if (id === 'avatar-preview') content = [
        avatar(null),
        t('Chọn ảnh đại diện','bodyMedium'),
        button('Chọn ảnh','profile-edit')
      ];
      if (!content.length) content = [t('Màn hình tham chiếu trong prototype.','bodyRegular','textMuted',contentWidth)];
      const footer = main ? button('Đăng xuất','login') : null;
      const body = stack('Nội dung',contentWidth,content,{gap:12});
      const top = 84;
      const bottom = H - (active ? navHeight : 16) - (footer ? footer.height+24 : 0);
      const scroll = figma.createFrame();
      scroll.name = 'Vùng cuộn dọc';
      scroll.resize(contentWidth,bottom-top);
      scroll.fills = [];
      scroll.clipsContent = true;
      scroll.overflowDirection = 'VERTICAL';
      place(frame,scroll,16,top);
      scroll.constraints = {horizontal:'STRETCH',vertical:'STRETCH'};
      place(scroll,body,0,0);
      body.constraints = {horizontal:'STRETCH',vertical:'MIN'};
      if (id === 'quick') {
        const sheet = content[0];
        if (sheet.width > contentWidth) sheet.rescale(contentWidth/sheet.width);
      }
      if (footer) {
        footer.resize(contentWidth,footer.height);
        place(frame,footer,16,bottom+12);
        footer.constraints = {horizontal:'STRETCH',vertical:'MAX'};
        styleLogout(footer, vars);
      }
      if (active) reviewNav(frame,active);
    };
    const authTabs = current => stack('Chuyển chế độ tài khoản', contentWidth,
      [['login', 'Đăng nhập'], ['register', 'Đăng ký']].map(([id, label]) => {
        const selected = id === current;
        const tab = stack(label, (contentWidth - 8) / 2, [t(label, 'bodyMedium', selected ? 'primaryMain' : 'textPrimary')],
          { horizontal: true, padding: [12, 12] });
        tab.primaryAxisAlignItems = 'CENTER';
        const border = selected ? 'primaryMain' : 'border';
        radius(outline(solid(tab, selected ? 'primarySoft' : 'surface'), border), 8, 'radiusSmall');
        return click(tab, selected ? null : id);
      }), { horizontal: true, gap: 8 });
    const googleAuth = title => {
      const separator = stack('Phân cách Google', contentWidth, [
        rect('Đường phân cách', 148, 1, 'border'),
        t('Hoặc', 'captionLabel', 'textMuted'),
        rect('Đường phân cách', 148, 1, 'border')
      ], { horizontal: true, spread: true });
      const icon = figma.createRectangle();
      icon.name = 'Google G';
      icon.resize(20, 20);
      const googleImage = figma.createImage(figma.base64Decode(googleMarkPng));
      icon.fills = [{ type: 'IMAGE', scaleMode: 'FIT', imageHash: googleImage.hash }];
      const label = title + ' bằng Google';
      const action = stack(label, contentWidth, [icon, t(label, 'bodyMedium')], { horizontal: true, padding: [12, 12] });
      action.primaryAxisAlignItems = 'CENTER';
      radius(outline(solid(action, 'surface')), 8, 'radiusSmall');
      return stack('Xác thực bằng Google', contentWidth, [separator, click(action, 'home')], { gap: 12 });
    };
    const drawContent = (frame, data, withLinks = true) => {
      const [id, title, active, rows] = data;
      const auth = id === 'login' || id === 'register';
      const head = header(title, withLinks ? (detailed && id === 'report' ? 'back' : back[id]) : null);
      const content = stack('Nội dung',contentWidth,rows.map(row => render(row,id)),{gap:auth || detailed ? 12 : 8});
      if (auth) {
        const logo = figma.createNodeFromSvg(wordmarkSvg);
        logo.name = 'Our Budget · Wordmark';
        const form = stack('Tài khoản', contentWidth, [logo, head, authTabs(id), content, googleAuth(title)], { gap: 16 });
        place(frame, form, 16, 32);
        contentBounds.push([frame, form, H]);
        return;
      }
      place(frame,head,16,24);
      place(frame,content,16,68);
      if (active) nav(frame,active);
      contentBounds.push([frame, content, H - (active ? 88 : 0)]);
    };
    const byId = Object.fromEntries((profileReview ? [...SCREENS,...reviewScreens] : SCREENS).map(s=>[s[0],s]));
    for (const [rowIndex, [heading, ids]] of screenGroups.entries()) {
      const label = t(heading,'headingH1');
      place(page,label,0,rowIndex * 960);
      for (const [col,[id,title,active,rows,kind]] of ids.map(id=>byId[id]).entries()) {
        step = 'Dựng màn hình ' + title;
        const frame = screen(title,page,col*430,rowIndex*960+64);
        destinations[id] = frame;
        if (profileReview) {
          reviewContent(frame,id,title,active,detailRows[id] ?? (id === 'profile' ? [] : rows));
          continue;
        }
        if (!kind) {
          drawContent(frame, detailed && detailRows[id] ? [id, title, active, detailRows[id]] : byId[id]);
          continue;
        }
        const mainId = id === 'wallet-picker' ? 'home' : overlayReturn[id] || 'home';
        const originalHandlers = handlers.length;
        drawContent(frame,byId[mainId],false);
        handlers.length=originalHandlers;
        const dimmer = place(frame,rect('Chạm nền để đóng',W,H,'textPrimary'),0,0);
        solid(dimmer,'textPrimary',0.46);
        click(dimmer,overlayReturn[id] || 'home');

        if (sheets[id]) {
          const sheet = use(sheets[id]);
          if (bankNames[id]) sheet.setProperties({'Nguồn tiền#4:36':bankNames[id]});
          place(frame,sheet,0,0);
          bottomPanels.push([frame, sheet]);
          click(part(sheet,'Chi tiêu'), 'quick');
          click(part(sheet,'Thu nhập'), 'income');
          click(part(sheet,bankNames[id] || 'Ví tiền mặt'), 'wallet-picker');
          click(part(sheet,'Thêm ghi chú hoặc chỉnh ngày giờ') || part(sheet,'Ẩn chi tiết'), id === 'optional' ? 'quick' : 'optional');
          if (id === 'quick') click(part(sheet,'25.000 đ'), 'error');
          if (id === 'error') click(part(sheet,'0 đ'), 'quick');
          if (id !== 'error') click(part(sheet,'Lưu giao dịch'), 'home');
        } else {
          const panel = solid(stack(title,W,[t(title,'headingH1'),...rows.map(row=>render(row,id))],{padding:[16,24],gap:12}), 'surface');
          panel.topLeftRadius=24; panel.topRightRadius=24;
          bind(panel,'topLeftRadius','AppRadius/radiusSheet');
          bind(panel,'topRightRadius','AppRadius/radiusSheet');
          place(frame,panel,0,0);
          bottomPanels.push([frame, panel]);
        }
      }
    }
    step = 'Kiểm tra kiểu chữ';
    await Promise.all(textStyles);
    step = 'Kiểm tra bố cục';
    for (const [frame, content, bottom] of contentBounds) {
      if (content.y + content.height > bottom) throw Error('Nội dung vượt khung: ' + frame.name);
    }
    for (const [frame, panel] of bottomPanels) {
      if (panel.height > H) throw Error('Hộp thoại vượt khung: ' + frame.name);
      panel.y = H - panel.height;
    }
    for (const frame of Object.values(destinations)) {
      const badFont = frame.findOne(n => n.type === 'TEXT' && n.fontName !== figma.mixed && n.fontName.family !== 'Inter');
      if (badFont) throw Error('Kiểu chữ không khớp Inter: ' + badFont.name);
    }
    for (const [node,destination] of handlers) {
      step = 'Liên kết ' + node.name + ' → ' + destination;
      if (destination === 'back') {
        await node.setReactionsAsync([{ trigger: { type: 'ON_CLICK' }, actions: [{ type: 'BACK' }] }]);
        continue;
      }
      const next = destinations[destination];
      if (!next) throw Error('Thiếu đích prototype: ' + destination);
      const sourceFrame = node.getTopLevelFrame();
      if (sourceFrame?.parent?.id !== page.id || next.parent?.id !== page.id) {
        throw Error('Nguồn và đích prototype phải nằm trong các khung cấp cao nhất trên cùng một trang.');
      }
      // Nút của tab hoặc trạng thái đang mở không cần điều hướng.
      if (sourceFrame.id === next.id) continue;
      if (!('setReactionsAsync' in node)) throw Error('Layer không hỗ trợ prototype: ' + node.name);
      const transition = [ 'quick','wallet-picker','history-filter' ].includes(destination)
        ? {type:'MOVE_IN', direction:'TOP', duration:0.2, easing:{type:'EASE_OUT'}, matchLayers:false}
        : null;
      await node.setReactionsAsync([{trigger:{type:'ON_CLICK'},actions:[{type:'NODE',destinationId:next.id,navigation:'NAVIGATE',transition,preserveScrollPosition:false}]}]);
    }
    if (profileReview) {
      step = 'Kiểm tra bản duyệt';
      checkReviewNav(variantsByTab['Cá nhân'].parent);
      for (const [label,id] of Object.entries(tabs)) {
        const frame = destinations[id];
        const strip = frame.findChild(n => n.name === 'Điểm chạm điều hướng');
        if (variantsByTab[label].parent.type !== 'COMPONENT_SET' ||
            strip.children.length !== 5 || strip.children.some(n => n.width < 44 || n.height < 44) ||
            strip.children.filter(n => n.reactions.length > 0).length !== 4) {
          throw Error('Thiếu biến thể hoặc điểm chạm: ' + label);
        }
      }
      const values = required.map(name => {
        const {r,g,b} = vars[name].resolveForConsumer(destinations.profile).value;
        return name + ' #' + [r,g,b].map(channel => Math.round(channel*255).toString(16).padStart(2,'0')).join('').toUpperCase();
      });
      const typography = Object.values(styles).map(s =>
        [s.name,s.fontName.family,s.fontName.style,s.fontSize,
          s.lineHeight.unit === 'AUTO' ? 'tự động' : s.lineHeight.value + ' ' + s.lineHeight.unit].join(' · '));
      const effectStyles = await figma.getLocalEffectStylesAsync();
      const rows = [
        ['headingH1','Kiểm kê Design System'],
        ['bodyRegular','Nguồn kiểm kê là biến, kiểu chữ và component trong tệp Figma tại lúc chạy.'],
        ['headingH2','Màu ngữ nghĩa'],
        ...values.map(value => ['bodyRegular',value]),
        ['headingH2','Typography'],
        ...typography.map(value => ['bodyRegular',value]),
        ['headingH2','Khoảng cách, bo góc và lưới'],
        ['bodyRegular',Object.keys(vars).filter(name => /^App(Spacing|Radius)\//.test(name)).join(', ') || 'Tệp không có biến AppSpacing/AppRadius.'],
        ['bodyRegular','Khung 390 × 844. Lưới 4 cột, lề 16, gutter 12 theo plugin hiện có. Nội dung cuộn dọc và thanh điều hướng neo đáy.'],
        ['bodyRegular','Kiểu hiệu ứng cục bộ ' + (effectStyles.map(s => s.name).join(', ') || 'không phát hiện') + '.'],
        ['headingH2','Component và biến thể'],
        ['bodyRegular','Dùng lại ' + [...new Set([...reused,source['4:146'].name,source['4:94'].name,source['4:101'].name,source['4:109'].name,source['4:119'].name,source['4:128'].name,source['4:137'].name])].join(', ') + '.'],
        ['bodyRegular','Component Bottom Navigation Bar / 5 mục bọc bốn trạng thái điều hướng hiện có. Nút nổi giữ hiệu ứng và icon của nguồn. ' + newNavAudit],
        ['bodyRegular','Thành phần dựng từ token cục bộ ' + ([...fallbacks].join(', ') || 'không có') + '. Các icon dựng mới là vector nét viền để duyệt.'],
        ['bodyRegular','Mục menu dùng viền và đường phân cách từ border. Trạng thái tương tác được giữ trong instance gốc khi có. Thao tác prototype tại các khung mới là On click.'],
        ['headingH2','Prototype'],
        ['bodyRegular','Mở luồng Duyệt Cá nhân và thanh điều hướng. Có bốn tab, nút thêm giao dịch dẫn đến sheet hiện có và các liên kết từ menu Cá nhân.'],
        ['bodyRegular','Cần duyệt bố cục, icon dự phòng và khác biệt với bản vẽ tay ở chế độ Present. Các khung phụ hỗ trợ, giới thiệu, thông báo và cài đặt chỉ dùng để thử điều hướng.']
      ];
      const audit = solid(stack('Kiểm kê và ghi chú duyệt',560,rows.map(([style,value]) => t(value,style,'textPrimary',528)),
        {padding:[16,16],gap:8}),'surface');
      place(page,audit,3500,64);
      await Promise.all(textStyles);
    }
    step = 'Thiết lập luồng prototype';
    page.flowStartingPoints = profileReview ? [
      {nodeId:destinations.profile.id,name:'Duyệt Cá nhân và thanh điều hướng'}
    ] : [
      {nodeId:destinations.login.id,name:'Tài khoản và đăng nhập'},
      {nodeId:destinations.home.id,name:'Ghi chép hằng ngày'}
    ];
    page.name = pageName;
    const preview = profileReview ? [destinations.profile,destinations['profile-edit']] : [destinations.login, destinations.register];
    page.selection = preview;
    figma.viewport.scrollAndZoomIntoView(preview);
    figma.closePlugin(profileReview ? 'Đã tạo bản duyệt Cá nhân và thanh điều hướng.' :
      'Đã tạo ' + Object.keys(destinations).length + (detailed ? ' màn hình chính.' : ' wireframe có liên kết prototype.'));
  } catch (error) {
    await figma.setCurrentPageAsync(figma.root.children.find(p => p.id !== page.id));
    page.remove();
    throw error;
  }
}
build().catch(error => {
  console.error('Our Budget · ' + step, error);
  const detail = error?.message || (typeof error === 'string' && error) || 'Xem chi tiết trong bảng điều khiển Figma.';
  figma.closePlugin('Our Budget · ' + step + ' — ' + detail);
});
