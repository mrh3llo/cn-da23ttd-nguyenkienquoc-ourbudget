import 'package:material_ui/material_ui.dart';

import '../../../core/format/finance_format.dart';
import '../../../design_system/app_theme.dart';
import '../../../widgets/ledger_cards.dart';
import 'ledger_list.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String? _wallet;

  @override
  Widget build(BuildContext context) => LedgerList(
    pageKey: 'history',
    content: (ledger) {
      final byDay = <String, List<Widget>>{};
      for (final entry in ledger.entries) {
        if (_wallet != null && _wallet != entry.walletId) continue;
        (byDay[displayDate(entry.occurredAt)] ??= []).addAll([
          TransactionTile(
            entry: entry,
            walletName: walletName(ledger, entry.walletId),
          ),
          const SizedBox(height: 8),
        ]);
      }
      return [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            ChoiceChip(
              label: const Text('Tất cả ví'),
              selected: _wallet == null,
              onSelected: (_) => setState(() => _wallet = null),
            ),
            for (final wallet in ledger.wallets)
              ChoiceChip(
                label: Text(wallet.name),
                selected: _wallet == wallet.id,
                onSelected: (selected) =>
                    setState(() => _wallet = selected ? wallet.id : null),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (byDay.isEmpty) const Text('Chưa có giao dịch.'),
        for (final day in byDay.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              day.key,
              style: const TextStyle(
                color: ink,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          ...day.value,
        ],
      ];
    },
  );
}
