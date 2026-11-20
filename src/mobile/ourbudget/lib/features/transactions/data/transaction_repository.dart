import '../../../core/format/finance_format.dart';

enum TransactionKind { expense, income }

const expenseCategories = ['Ăn uống', 'Di chuyển', 'Mua sắm', 'Hóa đơn'];
const incomeCategories = ['Lương', 'Thưởng', 'Hoàn tiền', 'Khác'];

class Wallet {
  const Wallet(this.id, this.name, this.balance, {this.isDefault = false});

  final String id;
  final String name;
  final BigInt balance;
  final bool isDefault;
}

class BudgetSummary {
  const BudgetSummary(this.name, this.spent, this.limit);

  final String name;
  final BigInt spent;
  final BigInt limit;
}

class TransactionEntry {
  TransactionEntry({
    required this.id,
    required this.category,
    required this.walletId,
    required this.amount,
    required DateTime occurredAt,
    this.note = '',
  }) : occurredAt = vietnamTime(occurredAt);

  factory TransactionEntry.fromJson(Map<String, Object?> json) {
    return TransactionEntry(
      id: json['id'] as String,
      category: json['category'] as String,
      walletId: json['wallet_id'] as String,
      amount: decodeVnd(json['amount']),
      occurredAt: decodeVietnamTime(json['occurred_at']),
      note: json['note'] as String? ?? '',
    );
  }

  final String id;
  final String category;
  final String walletId;
  final BigInt amount;
  final DateTime occurredAt;
  final String note;
}

class Ledger {
  const Ledger(this.wallets, this.entries, this.budgetLimit);

  final List<Wallet> wallets;
  final List<TransactionEntry> entries;
  final BigInt budgetLimit;

  BigInt get totalBalance =>
      wallets.fold(BigInt.zero, (sum, wallet) => sum + wallet.balance);

  BudgetSummary? budgetFor(DateTime period) {
    if (budgetLimit <= BigInt.zero) return null;
    final month = vietnamTime(period);
    final spent = entries
        .where(
          (entry) =>
              entry.amount.isNegative &&
              entry.occurredAt.year == month.year &&
              entry.occurredAt.month == month.month,
        )
        .fold(BigInt.zero, (sum, entry) => sum - entry.amount);
    return BudgetSummary('Ngân sách tháng', spent, budgetLimit);
  }
}

abstract interface class TransactionRepository {
  Future<Ledger> load();
  Future<Ledger> create({
    required String category,
    required String walletId,
    required BigInt amount,
    required DateTime occurredAt,
    required String note,
  });
}

class FakeTransactionRepository implements TransactionRepository {
  FakeTransactionRepository({DateTime Function()? now}) {
    final today = vietnamTime((now ?? DateTime.now)());
    final yesterday = vietnamDateTime(
      DateTime.utc(today.year, today.month, today.day - 1),
      19,
      0,
    );
    _ledger = Ledger(
      [
        Wallet('cash', 'Tiền mặt', BigInt.from(420000), isDefault: true),
        Wallet('bank', 'Ngân hàng', BigInt.from(4500000)),
        Wallet('ewallet', 'Ví điện tử', BigInt.from(500000)),
      ],
      [
        TransactionEntry(
          id: '1',
          category: 'Ăn uống',
          walletId: 'cash',
          amount: BigInt.from(-45000),
          occurredAt: vietnamDateTime(today, 12, 35),
        ),
        TransactionEntry(
          id: '2',
          category: 'Lương',
          walletId: 'bank',
          amount: BigInt.from(4000000),
          occurredAt: vietnamDateTime(today, 9, 0),
        ),
        TransactionEntry(
          id: '3',
          category: 'Di chuyển',
          walletId: 'cash',
          amount: BigInt.from(-25000),
          occurredAt: vietnamDateTime(today, 8, 10),
        ),
        TransactionEntry(
          id: '4',
          category: 'Mua sắm',
          walletId: 'ewallet',
          amount: BigInt.from(-120000),
          occurredAt: yesterday,
        ),
        TransactionEntry(
          id: '5',
          category: 'Hóa đơn',
          walletId: 'bank',
          amount: BigInt.from(-1550000),
          occurredAt: vietnamDateTime(today, 7, 0),
        ),
      ]..sort((a, b) => b.occurredAt.compareTo(a.occurredAt)),
      BigInt.from(3000000),
    );
  }

  late Ledger _ledger;
  var _nextId = 6;

  @override
  Future<Ledger> load() async => _ledger;

  @override
  Future<Ledger> create({
    required String category,
    required String walletId,
    required BigInt amount,
    required DateTime occurredAt,
    required String note,
  }) async {
    final categories = amount.isNegative ? expenseCategories : incomeCategories;
    if (amount == BigInt.zero ||
        !categories.contains(category) ||
        !_ledger.wallets.any((wallet) => wallet.id == walletId)) {
      throw const FormatException('Giao dịch không hợp lệ.');
    }
    final entry = TransactionEntry.fromJson({
      'id': '${_nextId++}',
      'category': category,
      'wallet_id': walletId,
      'amount': amount.toString(),
      'occurred_at': encodeVietnamTime(occurredAt),
      'note': note,
    });
    _ledger = Ledger(
      [
        for (final wallet in _ledger.wallets)
          if (wallet.id == walletId)
            Wallet(
              wallet.id,
              wallet.name,
              wallet.balance + amount,
              isDefault: wallet.isDefault,
            )
          else
            wallet,
      ],
      [entry, ..._ledger.entries]
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt)),
      _ledger.budgetLimit,
    );
    return _ledger;
  }
}
