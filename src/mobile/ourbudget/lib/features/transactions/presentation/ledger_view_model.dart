import 'package:flutter/foundation.dart';

import '../../../core/network/api_failure.dart';
import '../data/transaction_repository.dart';

class LedgerViewModel extends ChangeNotifier {
  LedgerViewModel(this._repository);

  final TransactionRepository _repository;
  Ledger? ledger;
  ApiFailure? failure;
  bool loading = false;
  bool saving = false;
  bool _disposed = false;

  Future<void> load() async {
    if (loading || saving) return;
    loading = true;
    failure = null;
    notifyListeners();
    try {
      ledger = await _repository.load();
    } on Exception {
      failure = ApiFailure.unavailable;
    } finally {
      loading = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<bool> save({
    String? destinationWalletId,
    required String category,
    required String walletId,
    required BigInt amount,
    required DateTime occurredAt,
    required String note,
  }) async {
    if (saving || loading) return false;
    saving = true;
    notifyListeners();
    try {
      ledger = await _repository.create(
        destinationWalletId: destinationWalletId,
        category: category,
        walletId: walletId,
        amount: amount,
        occurredAt: occurredAt,
        note: note,
      );
      failure = null;
      return true;
    } on Exception {
      return false;
    } finally {
      saving = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
