import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../design_system/app_theme.dart';
import '../core/network/api_client.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/finance/presentation/finance_directory_page.dart';
import '../features/transactions/data/transaction_repository.dart';
import '../features/transactions/presentation/ledger_view_model.dart';
import '../features/transactions/presentation/quick_transaction_bottom_sheet.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({
    super.key,
    required this.pages,
    required this.home,
    this.transactionsEnabled = true,
    this.profileActions,
  });

  final List<Widget> pages;
  final bool transactionsEnabled;
  final List<Widget> Function(BuildContext)? profileActions;
  final Widget Function(VoidCallback showHistory, VoidCallback showBudget) home;

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  static const _labels = ['Trang chủ', 'Lịch sử', 'Ngân sách', 'Cá nhân'];
  static const _icons = [
    Icons.home_outlined,
    Icons.receipt_long_outlined,
    Icons.bar_chart_outlined,
    Icons.person_outline,
  ];
  var _index = 0;
  var _loadingWallets = false;

  void _select(int index) => setState(() => _index = index);

  Future<void> _openTransaction() async {
    if (!widget.transactionsEnabled) {
      await _openTransactionPreview();
      return;
    }
    final model = context.read<LedgerViewModel>();
    final wallets = model.ledger?.wallets;
    if (wallets == null || wallets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wallets == null
                ? 'Chưa tải được nguồn tiền.'
                : 'Cần có nguồn tiền để ghi giao dịch.',
          ),
        ),
      );
      return;
    }
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(sheetRadius)),
      ),
      builder: (_) => ChangeNotifierProvider.value(
        value: model,
        child: QuickTransactionBottomSheet(wallets: wallets),
      ),
    );
    if (saved == true && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Đã lưu giao dịch mẫu.')));
    }
  }

  Future<void> _openTransactionPreview() async {
    if (_loadingWallets) return;
    setState(() => _loadingWallets = true);
    try {
      final items = await context.read<AuthController>().api.list('wallets');
      if (!mounted) return;
      final wallets = [
        for (final item in items)
          if (item['is_active'] == true)
            Wallet(
              item['id'] as String,
              item['name'] as String,
              BigInt.parse(item['current_balance'] as String),
              isDefault: item['priority'] == 0,
            ),
      ];
      if (wallets.isEmpty) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute(
            builder: (_) => const FinanceDirectoryPage(wallets: true),
          ),
        );
        return;
      }
      await showModalBottomSheet<void>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(sheetRadius),
          ),
        ),
        builder: (sheetContext) => QuickTransactionBottomSheet(
          wallets: wallets,
          pickCategory: (kind) => Navigator.of(sheetContext).push<String>(
            MaterialPageRoute(
              builder: (_) => FinanceDirectoryPage(
                pickType: kind == TransactionKind.income ? 'income' : 'expense',
              ),
            ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error is ApiException
                ? error.message
                : 'Không tải được nguồn tiền.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _loadingWallets = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeArea = MediaQuery.paddingOf(context);
    return PopScope(
      canPop: _index == 0,
      onPopInvokedWithResult: (popped, _) {
        if (!popped) _select(0);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_labels[_index]),
          actions: _index == 3 ? widget.profileActions?.call(context) : null,
        ),
        body: IndexedStack(
          index: _index,
          children: [
            widget.home(() => _select(1), () => _select(2)),
            ...widget.pages,
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          height: 72,
          padding: EdgeInsets.only(
            left: math.max(0.0, safeArea.right - safeArea.left),
            right: math.max(0.0, safeArea.left - safeArea.right),
          ),
          child: Row(
            children: [
              _destination(0),
              _destination(1),
              SizedBox(
                width: 64,
                child: Center(
                  child: FloatingActionButton(
                    tooltip: 'Ghi giao dịch',
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: const CircleBorder(),
                    onPressed: _loadingWallets ? null : _openTransaction,
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
              _destination(2),
              _destination(3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _destination(int index) => Expanded(
    child: Semantics(
      selected: _index == index,
      button: true,
      label: _labels[index],
      excludeSemantics: true,
      onTap: () => _select(index),
      child: InkWell(
        key: ValueKey('tab-$index'),
        onTap: () => _select(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _icons[index],
              size: 20,
              color: _index == index ? primary : muted,
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                _labels[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: _index == index ? primary : muted,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
