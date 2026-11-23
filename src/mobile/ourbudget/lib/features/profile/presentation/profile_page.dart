import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../design_system/app_theme.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../finance/presentation/finance_directory_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static void _unavailable(BuildContext context, String title) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('$title chưa khả dụng.')));
  }

  static List<Widget> headerActions(BuildContext context) => [
    IconButton(
      tooltip: 'Thông báo',
      onPressed: () => _unavailable(context, 'Thông báo'),
      icon: const Icon(Icons.notifications_outlined),
    ),
    IconButton(
      tooltip: 'Cài đặt',
      onPressed: () => _unavailable(context, 'Cài đặt'),
      icon: const Icon(Icons.settings_outlined),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    if (user == null) {
      return const Center(child: Text('Chưa có thông tin tài khoản.'));
    }

    void openAccount({bool editAvatar = false}) {
      Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => _AccountInformationPage(editAvatar: editAvatar),
        ),
      );
    }

    Widget menuRow(IconData icon, String title, VoidCallback onTap) => ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );

    Widget menuGroup(List<Widget> rows) => Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: outline),
            rows[i],
          ],
        ],
      ),
    );

    final theme = Theme.of(context);
    final name = (user['name'] as String? ?? '').trim();
    final email = (user['email'] as String? ?? '').trim();
    return SafeArea(
      top: false,
      bottom: false,
      minimum: const EdgeInsets.all(spacing),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Row(
                  children: [
                    _ProfileAvatar(url: user['avatar_url'] as String? ?? ''),
                    IconButton(
                      tooltip: 'Chỉnh ảnh đại diện',
                      onPressed: () => openAccount(editAvatar: true),
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? 'Chưa có họ tên' : name,
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email.isEmpty ? 'Chưa có email' : email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: muted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _VerificationBadge(
                            verified: user['email_verified'] == true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: spacing),
                menuGroup([
                  menuRow(
                    Icons.person_outline,
                    'Thông tin tài khoản',
                    openAccount,
                  ),
                  menuRow(
                    Icons.account_balance_wallet_outlined,
                    'Quản lý ví',
                    () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) =>
                            const FinanceDirectoryPage(wallets: true),
                      ),
                    ),
                  ),
                  menuRow(
                    Icons.category_outlined,
                    'Danh mục',
                    () => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => const FinanceDirectoryPage(),
                      ),
                    ),
                  ),
                ]),
                const SizedBox(height: 12),
                menuGroup([
                  menuRow(
                    Icons.help_outline,
                    'Trợ giúp & Phản hồi',
                    () => _unavailable(context, 'Trợ giúp & Phản hồi'),
                  ),
                  menuRow(
                    Icons.info_outline,
                    'Giới thiệu về ứng dụng',
                    () => showAboutDialog(
                      context: context,
                      applicationName: 'OurBudget',
                    ),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: auth.busy ? null : () => auth.logout(),
              style: FilledButton.styleFrom(
                backgroundColor: expense,
                foregroundColor: Colors.white,
              ),
              child: const Text('Đăng xuất'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.verified});
  final bool verified;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: verified ? primarySoft : background,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Text(
        verified ? 'Đã xác minh' : 'Chưa xác minh',
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: verified ? primary : muted),
      ),
    ),
  );
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    const fallback = Icon(Icons.person_outline, size: 32, color: muted);
    return ClipOval(
      child: SizedBox.square(
        dimension: 64,
        child: ColoredBox(
          color: primarySoft,
          child: url.isEmpty
              ? const Center(child: fallback)
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Center(child: fallback),
                ),
        ),
      ),
    );
  }
}

class _AccountInformationPage extends StatefulWidget {
  const _AccountInformationPage({required this.editAvatar});
  final bool editAvatar;

  @override
  State<_AccountInformationPage> createState() =>
      _AccountInformationPageState();
}

class _AccountInformationPageState extends State<_AccountInformationPage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _avatar = TextEditingController();
  final _password = TextEditingController();
  var _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthController>().user;
    if (!_initialized && user != null) {
      _name.text = user['name'] as String;
      _email.text = user['email'] as String;
      _phone.text = user['phone'] as String? ?? '';
      _avatar.text = user['avatar_url'] as String? ?? '';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _avatar.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _action(Future<bool> result, String message) async {
    if (await result && mounted) {
      _password.clear();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();
    final verified = user['email_verified'] == true;
    final avatarUrl = user['avatar_url'] as String? ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin tài khoản'),
        leading: IconButton(
          tooltip: 'Quay lại',
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(spacing),
          children: [
            Center(child: _ProfileAvatar(url: avatarUrl)),
            const SizedBox(height: spacing),
            Text(user['email'] as String, textAlign: TextAlign.center),
            Center(child: _VerificationBadge(verified: verified)),
            if (auth.error != null)
              Text(auth.error!, style: const TextStyle(color: expense)),
            if (auth.notice != null)
              Text(auth.notice!, textAlign: TextAlign.center),
            const SizedBox(height: spacing),
            if (!verified)
              TextButton(
                onPressed: auth.busy
                    ? null
                    : () => _action(
                        auth.resendVerification(user['email'] as String),
                        'Đã yêu cầu gửi lại email xác minh.',
                      ),
                child: const Text('Gửi lại email xác minh'),
              ),
            for (final entry in [
              (_name, 'Họ tên'),
              (_email, 'Email'),
              (_phone, 'Số điện thoại'),
              (_avatar, 'URL ảnh đại diện HTTPS'),
            ]) ...[
              TextField(
                controller: entry.$1,
                autofocus: widget.editAvatar && entry.$1 == _avatar,
                enabled: !auth.busy,
                decoration: InputDecoration(labelText: entry.$2),
              ),
              const SizedBox(height: spacing),
            ],
            if (user['has_password'] == true) ...[
              TextField(
                controller: _password,
                enabled: !auth.busy,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mật khẩu hiện tại',
                  helperText: 'Dùng khi máy chủ yêu cầu xác thực lại.',
                ),
              ),
              const SizedBox(height: spacing),
            ],
            FilledButton(
              onPressed: auth.busy
                  ? null
                  : () => _action(
                      auth.updateProfile({
                        'name': _name.text.trim(),
                        'email': _email.text.trim(),
                        'phone': _phone.text.trim(),
                        'avatar_url': _avatar.text.trim(),
                        'current_password': _password.text,
                      }),
                      'Đã cập nhật hồ sơ. Nếu đổi email, hãy xác minh địa chỉ mới.',
                    ),
              child: const Text('Lưu hồ sơ'),
            ),
            if (user['google_linked'] == true)
              const ListTile(
                leading: Icon(Icons.check_circle_outline),
                title: Text('Đã liên kết Google'),
              )
            else
              OutlinedButton(
                onPressed: auth.busy
                    ? null
                    : () => _action(
                        auth.linkGoogle(_password.text),
                        'Đã mở trang Google để liên kết tài khoản.',
                      ),
                child: const Text('Liên kết tài khoản Google'),
              ),
          ],
        ),
      ),
    );
  }
}
