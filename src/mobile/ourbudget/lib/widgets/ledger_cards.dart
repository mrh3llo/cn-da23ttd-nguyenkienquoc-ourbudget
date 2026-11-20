import 'package:material_ui/material_ui.dart';

import '../core/format/finance_format.dart';
import '../design_system/app_theme.dart';
import '../features/transactions/data/transaction_repository.dart';

class BalanceHeaderCard extends StatelessWidget {
  const BalanceHeaderCard({super.key, required this.total});

  final BigInt total;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: primary,
      borderRadius: BorderRadius.circular(cardRadius),
    ),
    child: Padding(
      padding: const EdgeInsets.all(spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng số dư khả dụng',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            formatVnd(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              height: 36 / 28,
              fontWeight: FontWeight.w700,
              fontFeatures: numeric,
            ),
          ),
        ],
      ),
    ),
  );
}

class BudgetProgressCard extends StatelessWidget {
  const BudgetProgressCard({super.key, required this.budget, this.onTap});

  final BudgetSummary budget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final percent = budget.spent * BigInt.from(100) ~/ budget.limit;
    final (label, color) = percent >= BigInt.from(100)
        ? ('Vượt hạn mức', expense)
        : percent >= BigInt.from(80)
        ? ('Cảnh báo', warning)
        : ('An toàn', income);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(cardRadius),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      budget.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      fontFeatures: numeric,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${formatVnd(budget.spent)} / ${formatVnd(budget.limit)}',
                style: const TextStyle(fontFeatures: numeric),
              ),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(color: muted, fontSize: 12)),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: percent >= BigInt.from(100) ? 1 : percent.toInt() / 100,
                minHeight: 8,
                borderRadius: BorderRadius.circular(999),
                color: color,
                backgroundColor: outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData categoryIcon(String label) => switch (label) {
  'Ăn uống' => Icons.restaurant_outlined,
  'Di chuyển' => Icons.directions_bus_outlined,
  'Mua sắm' => Icons.shopping_bag_outlined,
  'Hóa đơn' => Icons.receipt_long_outlined,
  'Lương' => Icons.payments_outlined,
  'Thưởng' => Icons.card_giftcard_outlined,
  'Hoàn tiền' => Icons.replay_outlined,
  _ => Icons.category_outlined,
};

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.entry,
    required this.walletName,
  });

  final TransactionEntry entry;
  final String walletName;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  categoryIcon(entry.category),
                  color: primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.category,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '$walletName · ${displayTime(entry.occurredAt)}',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            formatVnd(entry.amount, showPlus: true),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFeatures: numeric,
              color: entry.amount.isNegative ? expense : income,
            ),
          ),
        ],
      ),
    ),
  );
}
