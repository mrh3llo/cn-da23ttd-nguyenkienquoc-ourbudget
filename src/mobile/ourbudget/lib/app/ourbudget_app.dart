import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../design_system/app_theme.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/auth/presentation/auth_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/transactions/data/transaction_repository.dart';
import '../widgets/main_navigation_shell.dart';
import 'demo_app.dart';

class OurBudgetApp extends StatelessWidget {
  const OurBudgetApp({
    super.key,
    this.demo = false,
    this.createRepository = FakeTransactionRepository.new,
    this.authController,
  });
  final bool demo;
  final TransactionRepository Function() createRepository;
  final AuthController? authController;

  @override
  Widget build(BuildContext context) {
    if (demo || const bool.fromEnvironment('DEMO_MODE')) {
      return DemoOurBudgetApp(createRepository: createRepository);
    }
    return ChangeNotifierProvider(
      create: (_) =>
          (authController ??
                AuthController(
                  AuthRepository(ApiClient(const ApiConfig())),
                  SecureTokenStore(),
                  GoogleLogin(),
                ))
            ..restore(),
      child: const _AuthenticatedApp(),
    );
  }
}

class _AuthenticatedApp extends StatelessWidget {
  const _AuthenticatedApp();
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return MaterialApp(
      key: ValueKey(auth.generation),
      title: 'OurBudget',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: switch (auth.state) {
        SessionState.restoring => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        SessionState.signedOut => const AuthPage(),
        SessionState.unavailable => Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    auth.error ??
                        'Chưa kiểm tra được phiên. Hãy thử lại khi có mạng.',
                  ),
                  FilledButton(
                    onPressed: auth.restore,
                    child: const Text('Thử lại'),
                  ),
                  TextButton(
                    onPressed: () => auth.logout(),
                    child: const Text('Đăng xuất trên thiết bị'),
                  ),
                ],
              ),
            ),
          ),
        ),
        SessionState.signedIn => MainNavigationShell(
          key: ValueKey(auth.user!['id']),
          transactionsEnabled: false,
          home: (_, _) => const _ComingSoon(),
          pages: const [_ComingSoon(), _ComingSoon(), ProfilePage()],
        ),
      },
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon();
  @override
  Widget build(BuildContext context) => const Center(
    child: Padding(
      padding: EdgeInsets.all(24),
      child: Text(
        'Tài khoản của bạn đã sẵn sàng. Chức năng quản lý thu chi sẽ có trong bản cập nhật tiếp theo.',
        textAlign: TextAlign.center,
      ),
    ),
  );
}
