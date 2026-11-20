import 'package:material_ui/material_ui.dart';

import '../../../core/format/finance_format.dart';
import '../../../design_system/app_theme.dart';
import '../../../widgets/ledger_cards.dart';
import '../../transactions/presentation/ledger_list.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key});

  @override
  Widget build(BuildContext context) => LedgerList(
    pageKey: 'budgets',
    content: (ledger) {
      final budget = ledger.budgetFor(DateTime.now());
      return [
        if (budget == null)
          const Text('Chưa có ngân sách.')
        else ...[
          Text(
            'Kỳ hiện tại · ${displayDate(DateTime.now()).substring(3)}',
            style: const TextStyle(color: muted),
          ),
          const SizedBox(height: 12),
          BudgetProgressCard(budget: budget),
        ],
      ];
    },
  );
}
