import 'package:flutter_test/flutter_test.dart';
import 'package:ourbudget/features/transactions/data/transaction_repository.dart';
import 'package:ourbudget/features/transactions/presentation/ledger_view_model.dart';

void main() {
  test(
    'transfer changes both wallets but never income/expense or budget',
    () async {
      final now = DateTime(2026, 11, 22, 12);
      final repo = FakeTransactionRepository(now: () => now);
      final model = LedgerViewModel(repo);
      addTearDown(model.dispose);
      await model.load();
      final before = model.ledger!;
      expect(
        await model.save(
          category: '',
          walletId: 'cash',
          destinationWalletId: 'bank',
          amount: BigInt.from(20000),
          occurredAt: now,
          note: '',
        ),
        isTrue,
      );
      final after = model.ledger!;
      expect(after.totalBalance, before.totalBalance);
      expect(
        after.wallets[0].balance,
        before.wallets[0].balance - BigInt.from(20000),
      );
      expect(
        after.wallets[1].balance,
        before.wallets[1].balance + BigInt.from(20000),
      );
      expect(after.budgetFor(now)!.spent, before.budgetFor(now)!.spent);
      expect(
        after.entries.firstWhere((e) => e.id == '6').kind,
        TransactionKind.transfer,
      );
      // Destination takes precedence over sign even when reading an older negative transfer.
      final legacy = TransactionEntry(
        id: 'legacy',
        category: '',
        walletId: 'cash',
        destinationWalletId: 'bank',
        amount: BigInt.from(-20000),
        occurredAt: now,
      );
      expect(legacy.kind, TransactionKind.transfer);
      expect(
        Ledger([], [legacy], BigInt.from(100000)).budgetFor(now)!.spent,
        BigInt.zero,
      );
      for (final target in ['cash', 'missing']) {
        expect(
          await model.save(
            category: '',
            walletId: 'cash',
            destinationWalletId: target,
            amount: BigInt.one,
            occurredAt: now,
            note: '',
          ),
          isFalse,
        );
        expect(model.ledger, same(after));
      }
      expect(
        await model.save(
          category: 'Lương',
          walletId: 'cash',
          amount: BigInt.from(1000),
          occurredAt: now,
          note: '',
        ),
        isTrue,
      );
      expect(
        model.ledger!.entries.firstWhere((e) => e.id == '7').kind,
        TransactionKind.income,
      );
      expect(
        await model.save(
          category: 'Ăn uống',
          walletId: 'cash',
          amount: BigInt.from(-500),
          occurredAt: now,
          note: '',
        ),
        isTrue,
      );
      expect(
        model.ledger!.entries.firstWhere((e) => e.id == '8').kind,
        TransactionKind.expense,
      );
    },
  );
}
