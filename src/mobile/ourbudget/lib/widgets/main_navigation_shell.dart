import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../design_system/app_theme.dart';
import '../features/transactions/presentation/ledger_view_model.dart';
import '../features/transactions/presentation/quick_transaction_bottom_sheet.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({
    super.key,
    required this.pages,
    required this.home,
  });

  final List<Widget> pages;
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

  void _select(int index) => setState(() => _index = index);

  Future<void> _openTransaction() async {
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

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _index == 0,
    onPopInvokedWithResult: (popped, _) {
      if (!popped) _select(0);
    },
    child: Scaffold(
      appBar: AppBar(title: Text(_labels[_index])),
      body: IndexedStack(
        index: _index,
        children: [
          widget.home(() => _select(1), () => _select(2)),
          ...widget.pages,
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Ghi giao dịch',
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        onPressed: _openTransaction,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 4,
        height: 72,
        padding: EdgeInsets.zero,
        child: Row(
          children: [
            _destination(0),
            _destination(1),
            const SizedBox(width: 64),
            _destination(2),
            _destination(3),
          ],
        ),
      ),
    ),
  );

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
