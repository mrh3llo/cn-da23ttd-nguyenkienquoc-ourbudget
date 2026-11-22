import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../design_system/app_theme.dart';
import '../../auth/presentation/auth_controller.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _avatar = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  var _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final user = context.read<AuthController>().user!;
      _name.text = user['name'] as String;
      _email.text = user['email'] as String;
      _phone.text = user['phone'] as String? ?? '';
      _avatar.text = user['avatar_url'] as String? ?? '';
      _initialized = true;
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _name,
      _email,
      _phone,
      _avatar,
      _password,
      _code,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _action(Future<bool> result, String message) async {
    if (await result && mounted) {
      _password.clear();
      _code.clear();
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
    return ListView(
      padding: const EdgeInsets.all(spacing),
      children: [
        Center(
          child: ClipOval(
            child: user['avatar_url'] is String
                ? Image.network(
                    user['avatar_url'] as String,
                    width: 64,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.person, size: 64),
                  )
                : const Icon(Icons.person, size: 64),
          ),
        ),
        const SizedBox(height: spacing),
        Text(user['email'] as String, textAlign: TextAlign.center),
        Text(
          verified ? 'Email đã xác minh' : 'Email chưa xác minh',
          textAlign: TextAlign.center,
        ),
        if (auth.error != null)
          Text(auth.error!, style: const TextStyle(color: expense)),
        const SizedBox(height: spacing),
        if (!verified) ...[
          TextField(
            controller: _code,
            enabled: !auth.busy,
            decoration: const InputDecoration(
              labelText: 'Mã xác minh trong email',
            ),
          ),
          FilledButton(
            onPressed: auth.busy
                ? null
                : () => _action(
                    auth.verifyEmail(_code.text.trim()),
                    'Đã xác minh email.',
                  ),
            child: const Text('Xác minh email'),
          ),
          TextButton(
            onPressed: auth.busy
                ? null
                : () => _action(
                    auth.resendVerification(),
                    'Đã yêu cầu gửi lại mã.',
                  ),
            child: const Text('Gửi lại mã xác minh'),
          ),
        ],
        for (final entry in [
          (_name, 'Họ tên'),
          (_email, 'Email'),
          (_phone, 'Số điện thoại'),
          (_avatar, 'URL ảnh đại diện HTTPS'),
        ]) ...[
          TextField(
            controller: entry.$1,
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
              helperText: 'Cần khi đổi email hoặc liên kết Google.',
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
                    'Đã liên kết Google.',
                  ),
            child: const Text('Liên kết tài khoản Google'),
          ),
        const SizedBox(height: spacing),
        OutlinedButton.icon(
          onPressed: () => auth.logout(),
          icon: const Icon(Icons.logout),
          label: const Text('Đăng xuất'),
        ),
      ],
    );
  }
}
