import 'package:material_ui/material_ui.dart';

import '../../../design_system/app_theme.dart';
import '../../../widgets/ledger_cards.dart';
import '../../transactions/presentation/ledger_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.openHistory,
    required this.openBudget,
  });

  final VoidCallback openHistory;
  final VoidCallback openBudget;

  @override
  Widget build(BuildContext context) => LedgerList(
    pageKey: 'home',
    content: (ledger) {
      final budget = ledger.budgetFor(DateTime.now());
      return [
        BalanceHeaderCard(total: ledger.totalBalance),
        const SizedBox(height: 12),
        if (budget != null && budget.spent >= budget.limit) ...[
          const Text(
            'Ngân sách tháng đã chạm hoặc vượt hạn mức.',
            style: TextStyle(color: expense, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
        ],
        if (budget != null)
          BudgetProgressCard(budget: budget, onTap: openBudget),
        const SizedBox(height: 12),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Giao dịch gần đây',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            TextButton(onPressed: openHistory, child: const Text('Xem tất cả')),
          ],
        ),
        if (ledger.entries.isEmpty) const Text('Chưa có giao dịch.'),
        for (final entry in ledger.entries.take(3)) ...[
          TransactionTile(
            entry: entry,
            walletName: walletName(ledger, entry.walletId),
          ),
          const SizedBox(height: 8),
        ],
      ];
    },
  );
}
