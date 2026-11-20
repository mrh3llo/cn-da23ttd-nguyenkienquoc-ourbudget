import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../design_system/app_theme.dart';
import '../data/transaction_repository.dart';
import 'ledger_view_model.dart';

String walletName(Ledger ledger, String id) =>
    ledger.wallets.where((wallet) => wallet.id == id).firstOrNull?.name ??
    'Nguồn tiền';

class LedgerList extends StatelessWidget {
  const LedgerList({super.key, required this.pageKey, required this.content});

  final String pageKey;
  final List<Widget> Function(Ledger) content;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LedgerViewModel>();
    final ledger = model.ledger;
    if (ledger == null) {
      return Center(
        child: model.failure == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(spacing),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(model.failure!.message, textAlign: TextAlign.center),
                    TextButton(
                      onPressed: model.load,
                      child: const Text('Tải lại'),
                    ),
                  ],
                ),
              ),
      );
    }
    return RefreshIndicator(
      onRefresh: model.load,
      child: ListView(
        key: PageStorageKey(pageKey),
        primary: false,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(spacing, 8, spacing, 72),
        children: [
          if (model.loading) const LinearProgressIndicator(),
          if (model.failure case final failure?)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Semantics(liveRegion: true, child: Text(failure.message)),
            ),
          ...content(ledger),
        ],
      ),
    );
  }
}
