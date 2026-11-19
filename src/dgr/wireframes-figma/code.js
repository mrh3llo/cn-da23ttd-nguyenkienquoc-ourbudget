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
  ["login","Đăng nhập","",[["heading","Our Budget"],["field","Email","minhanh@example.com"],["field","Mật khẩu","••••••••"],["button","Đăng nhập","home"],["link","Quên mật khẩu?","reset"],["link","Tạo tài khoản","register"]]],
  ["register","Đăng ký","",[["field","Họ và tên","Minh Anh"],["error","Email","minhanh@","Nhập email đúng định dạng."],["field","Số điện thoại","Nhập số điện thoại"],["field","Mật khẩu","Tạo mật khẩu"],["button","Tạo tài khoản","home"],["link","Đã có tài khoản? Đăng nhập","login"]]],
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
const detailed = figma.command !== 'wireframe';
const pageName = detailed ? 'Giao diện chi tiết · Our Budget' : 'Wireframes · Our Budget · Bản sửa bố cục';
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
  ['Ghi chép hằng ngày', ['home', 'history', 'budgets', 'report']],
  ['Quản lý tài khoản', ['profile', 'wallets', 'categories']]
];
const detailRows = {
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
  register: 'login', reset: 'login', otp: 'reset'
};
const bankNames = { 'quick-bank': 'Ngân hàng', 'quick-ewallet': 'Ví điện tử' };
const overlayReturn = { 'delete-tx': 'edit-tx', 'wallet-delete': 'wallet-edit', 'category-delete': 'category-edit', 'budget-delete': 'budget-edit', 'wallet-picker': 'quick', 'history-filter': 'history' };
let step = 'Kiểm tra tệp và thư viện';

async function build() {
  const existing = figma.root.children.find(p => p.name === pageName);
  if (existing) {
    await figma.setCurrentPageAsync(existing);
    figma.closePlugin('Trang wireframe đã có trong tệp.');
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
    const screenGroups = detailed ? detailGroups : groups;
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
        n.textAutoResize = width ? 'HEIGHT' : 'WIDTH_AND_HEIGHT';
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
    const header = (frame, title, dst) => {
      const head = stack('Thanh tiêu đề', contentWidth, [
        ...(dst ? [click(t('‹', 'headingH1', 'primaryMain'), dst)] : []),
        t(title, 'headingH1')
      ], { horizontal:true, gap:12 });
      return place(frame,head,16,24);
    };
    const nav = (frame, active) => {
      const n = place(frame,use(navigation[active]),0,H-88);
      for (const child of n.children) click(child, tabs[child.name] || (child.name.includes('FloatingActionButton') ? 'quick' : null));
    };
    const drawContent = (frame, data, withLinks = true) => {
      const [id, title, active, rows] = data;
      header(frame, title, withLinks ? (detailed && id === 'report' ? 'back' : back[id]) : null);
      const content = stack('Nội dung',contentWidth,rows.map(row => render(row,id)),{gap:detailed ? 12 : 8});
      place(frame,content,16,68);
      if (active) nav(frame,active);
      contentBounds.push([frame, content, H - (active ? 88 : 0)]);
    };
    const byId = Object.fromEntries(SCREENS.map(s=>[s[0],s]));
    for (const [rowIndex, [heading, ids]] of screenGroups.entries()) {
      const label = t(heading,'headingH1');
      place(page,label,0,rowIndex * 960);
      for (const [col,[id,title,active,rows,kind]] of ids.map(id=>byId[id]).entries()) {
        step = 'Dựng màn hình ' + title;
        const frame = screen(title,page,col*430,rowIndex*960+64);
        destinations[id] = frame;
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
    step = 'Thiết lập luồng prototype';
    const starts = [{nodeId:destinations.home.id,name:'Ghi chép hằng ngày'}];
    if (!detailed) starts.push({nodeId:destinations.login.id,name:'Tài khoản và đăng nhập'});
    page.flowStartingPoints = starts;
    page.name = pageName;
    const preview = [destinations.home, destinations[detailed ? 'history' : 'quick'], destinations.budgets];
    page.selection = preview;
    figma.viewport.scrollAndZoomIntoView(preview);
    figma.closePlugin('Đã tạo ' + Object.keys(destinations).length + (detailed ? ' màn hình chính.' : ' wireframe có liên kết prototype.'));
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
