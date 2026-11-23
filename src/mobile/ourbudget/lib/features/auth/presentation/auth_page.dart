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
  String _mode = 'login';
  String? _notice;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _change(String mode) => setState(() {
    _mode = mode;
    _notice = null;
    _password.clear();
  });

  Future<void> _submit(String mode) async {
    if (!_form.currentState!.validate()) return;
    final auth = context.read<AuthController>();
    final success = await switch (mode) {
      'register' => auth.register(
        _name.text.trim(),
        _email.text.trim(),
        _password.text,
      ),
      'forgot' => auth.forgot(_email.text.trim()),
      'reset' => auth.reset(_password.text),
      _ => auth.passwordLogin(_email.text.trim(), _password.text),
    };
    if (!mounted || !success) return;
    if (mode == 'forgot' || mode == 'register') {
      setState(() {
        _mode = 'login';
        _password.clear();
        _notice = auth.notice;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final mode = auth.isPasswordRecovery ? 'reset' : _mode;
    final title = switch (mode) {
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
                if (_notice != null || auth.notice != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: spacing),
                    child: Text(_notice ?? auth.notice!),
                  ),
                if (auth.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: spacing),
                    child: Text(
                      auth.error!,
                      style: const TextStyle(color: expense),
                    ),
                  ),
                if (mode == 'register') ...[
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
                if (mode != 'reset') ...[
                  TextFormField(
                    controller: _email,
                    enabled: !auth.busy,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: const InputDecoration(labelText: 'Email'),
                    validator: (value) => value == null ||
                            !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                .hasMatch(value.trim())
                        ? 'Nhập email hợp lệ.'
                        : null,
                  ),
                  const SizedBox(height: spacing),
                ],
                if (mode != 'forgot') ...[
                  TextFormField(
                    controller: _password,
                    enabled: !auth.busy,
                    obscureText: true,
                    autocorrect: false,
                    autofillHints: mode == 'login'
                        ? const [AutofillHints.password]
                        : const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      labelText: mode == 'reset' ? 'Mật khẩu mới' : 'Mật khẩu',
                    ),
                    validator: (value) => value == null || value.length < 8
                        ? 'Nhập ít nhất 8 ký tự.'
                        : null,
                  ),
                  const SizedBox(height: spacing),
                ],
                FilledButton(
                  onPressed: auth.busy ? null : () => _submit(mode),
                  child: Text(auth.busy ? 'Đang xử lý…' : title),
                ),
                if (mode == 'login' || mode == 'register') ...[
                  OutlinedButton.icon(
                    onPressed: auth.busy ? null : auth.googleLogin,
                    icon: const Icon(Icons.account_circle_outlined),
                    label: const Text('Tiếp tục với Google'),
                  ),
                  TextButton(
                    onPressed: auth.busy
                        ? null
                        : () => _change(mode == 'login' ? 'register' : 'login'),
                    child: Text(
                      mode == 'login'
                          ? 'Chưa có tài khoản? Đăng ký'
                          : 'Đã có tài khoản? Đăng nhập',
                    ),
                  ),
                ],
                if (mode == 'login')
                  TextButton(
                    onPressed: auth.busy ? null : () => _change('forgot'),
                    child: const Text('Quên mật khẩu?'),
                  ),
                if (mode == 'forgot' || mode == 'reset')
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
