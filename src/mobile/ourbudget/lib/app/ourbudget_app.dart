import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../design_system/app_theme.dart';
import '../features/budgets/presentation/budgets_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/transactions/data/transaction_repository.dart';
import '../features/transactions/presentation/history_page.dart';
import '../features/transactions/presentation/ledger_view_model.dart';
import '../widgets/main_navigation_shell.dart';

class OurBudgetApp extends StatelessWidget {
  const OurBudgetApp({
    super.key,
    this.createRepository = FakeTransactionRepository.new,
  });

  final TransactionRepository Function() createRepository;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'OurBudget',
    debugShowCheckedModeBanner: false,
    theme: appTheme,
    locale: const Locale('vi'),
    supportedLocales: const [Locale('vi')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: ChangeNotifierProvider(
      create: (_) => _DemoSession(),
      child: _SessionGate(createRepository: createRepository),
    ),
  );
}

class _DemoSession extends ChangeNotifier {
  var active = true;

  void setActive(bool value) {
    active = value;
    notifyListeners();
  }
}

class _SessionGate extends StatelessWidget {
  const _SessionGate({required this.createRepository});

  final TransactionRepository Function() createRepository;

  @override
  Widget build(BuildContext context) {
    final active = context.select((_DemoSession session) => session.active);
    if (!active) {
      return Scaffold(
        appBar: AppBar(title: const Text('OurBudget')),
        body: Center(
          child: FilledButton(
            onPressed: () => context.read<_DemoSession>().setActive(true),
            child: const Text('Mở bản thử nghiệm'),
          ),
        ),
      );
    }
    return ChangeNotifierProvider(
      create: (_) => LedgerViewModel(createRepository())..load(),
      child: MainNavigationShell(
        home: (history, budget) =>
            HomePage(openHistory: history, openBudget: budget),
        pages: const [HistoryPage(), BudgetsPage(), _ProfilePage()],
      ),
    );
  }
}

class _ProfilePage extends StatelessWidget {
  const _ProfilePage();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(spacing),
    children: [
      const ListTile(
        title: Text('OurBudget'),
        subtitle: Text('Quản lý chi tiêu cá nhân · Bản thử nghiệm'),
      ),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text('Thoát phiên thử nghiệm'),
        onTap: () => context.read<_DemoSession>().setActive(false),
      ),
    ],
  );
}
