import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../design_system/app_theme.dart';
import 'auth_controller.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  String _mode = 'login';
  String? _notice;

  @override
  void dispose() {
    for (final controller in [_name, _email, _password, _code]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _change(String mode) => setState(() {
    _mode = mode;
    _notice = null;
    _password.clear();
    _code.clear();
  });

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final success = await switch (_mode) {
      'register' => auth.register(
        _name.text.trim(),
        _email.text.trim(),
        _password.text,
      ),
      'forgot' => auth.forgot(_email.text.trim()),
      'reset' => auth.reset(
        _email.text.trim(),
        _code.text.trim(),
        _password.text,
      ),
      _ => auth.passwordLogin(_email.text.trim(), _password.text),
    };
    if (!mounted || !success) return;
    if (_mode == 'forgot') {
      setState(() {
        _mode = 'reset';
        _notice = 'Nếu email có tài khoản dùng mật khẩu, mã khôi phục đã được yêu cầu gửi. Tài khoản Google hãy dùng đăng nhập Google.';
      });
    } else if (_mode == 'reset') {
      setState(() {
        _mode = 'login';
        _password.clear();
        _code.clear();
        _notice = 'Đã đổi mật khẩu. Hãy đăng nhập lại.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final title = switch (_mode) {
      'register' => 'Tạo tài khoản',
      'forgot' => 'Quên mật khẩu',
      'reset' => 'Đặt lại mật khẩu',
      _ => 'Đăng nhập',
    };
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 72,
        title: Image.asset(
          'assets/icons/our-budget-wordmark.png',
          width: 204,
          height: 48,
          fit: BoxFit.contain,
          semanticLabel: 'OurBudget',
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(24),
              shrinkWrap: true,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 24),
                if (_notice != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: spacing),
                    child: Text(_notice!),
                  ),
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: spacing),
                    child: Text(
                      auth.error!,
                      style: const TextStyle(color: expense),
                    ),
                  ),
                if (_mode == 'register') ...[
                  TextFormField(
                    controller: _name,
                    enabled: !auth.busy,
                    decoration: const InputDecoration(labelText: 'Họ tên'),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Nhập họ tên.'
                        : null,
                  ),
                  const SizedBox(height: spacing),
                ],
                TextFormField(
                  controller: _email,
                  enabled: !auth.busy,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) => value == null || !value.contains('@')
                      ? 'Nhập email hợp lệ.'
                      : null,
                ),
                const SizedBox(height: spacing),
                if (_mode == 'reset') ...[
                  TextFormField(
                    controller: _code,
                    enabled: !auth.busy,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: 'Mã khôi phục trong email',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Dán mã nhận được qua email.'
                        : null,
                  ),
                  const SizedBox(height: spacing),
                ],
                if (_mode != 'forgot') ...[
                  TextFormField(
                    controller: _password,
                    enabled: !auth.busy,
                    obscureText: true,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: _mode == 'reset' ? 'Mật khẩu mới' : 'Mật khẩu',
                    ),
                    validator: (value) => value == null || value.length < 8
                        ? 'Nhập ít nhất 8 ký tự.'
                        : null,
                  ),
                  const SizedBox(height: spacing),
                ],
                FilledButton(
                  onPressed: auth.busy ? null : _submit,
                  child: Text(auth.busy ? 'Đang xử lý…' : title),
                ),
                if (_mode == 'login' || _mode == 'register') ...[
                  OutlinedButton.icon(
                    onPressed: auth.busy ? null : auth.googleLogin,
                    icon: const Icon(Icons.account_circle_outlined),
                    label: const Text('Tiếp tục với Google'),
                  ),
                  TextButton(
                    onPressed: auth.busy
                        ? null
                        : () =>
                              _change(_mode == 'login' ? 'register' : 'login'),
                    child: Text(
                      _mode == 'login'
                          ? 'Chưa có tài khoản? Đăng ký'
                          : 'Đã có tài khoản? Đăng nhập',
                    ),
                  ),
                ],
                if (_mode == 'login')
                  TextButton(
                    onPressed: auth.busy ? null : () => _change('forgot'),
                    child: const Text('Quên mật khẩu?'),
                  ),
                if (_mode == 'forgot' || _mode == 'reset')
                  TextButton(
                    onPressed: auth.busy ? null : () => _change('login'),
                    child: const Text('Quay lại đăng nhập'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
