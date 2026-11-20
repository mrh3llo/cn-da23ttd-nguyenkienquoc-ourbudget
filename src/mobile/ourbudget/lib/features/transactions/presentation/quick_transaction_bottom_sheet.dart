import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/format/finance_format.dart';
import '../../../design_system/app_theme.dart';
import '../../../widgets/ledger_cards.dart';
import '../data/transaction_repository.dart';
import 'ledger_view_model.dart';

class QuickTransactionBottomSheet extends StatefulWidget {
  const QuickTransactionBottomSheet({super.key, required this.wallets});

  final List<Wallet> wallets;

  @override
  State<QuickTransactionBottomSheet> createState() =>
      _QuickTransactionBottomSheetState();
}

class _QuickTransactionBottomSheetState
    extends State<QuickTransactionBottomSheet> {
  final _form = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _note = TextEditingController();
  var _kind = TransactionKind.expense;
  String? _category;
  late String _walletId = widget.wallets
      .firstWhere(
        (wallet) => wallet.isDefault,
        orElse: () => widget.wallets.first,
      )
      .id;
  DateTime? _occurredAt;
  bool _optional = false;
  String? _saveError;

  Future<void> _chooseTime() async {
    final local = vietnamTime(_occurredAt ?? DateTime.now());
    final day = await showDatePicker(
      context: context,
      initialDate: DateTime(local.year, local.month, local.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100, 12, 31),
    );
    if (day == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: local.hour, minute: local.minute),
    );
    if (time == null || !mounted) return;
    setState(() => _occurredAt = vietnamDateTime(day, time.hour, time.minute));
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saveError = null);
    final value = decodeVnd(_amount.text.replaceAll('.', ''));
    final saved = await context.read<LedgerViewModel>().save(
      category: _category!,
      walletId: _walletId,
      amount: _kind == TransactionKind.expense ? -value : value,
      occurredAt: _occurredAt ?? DateTime.now(),
      note: _note.text.trim(),
    );
    if (!mounted) return;
    if (saved) {
      Navigator.pop(context, true);
    } else {
      setState(() => _saveError = 'Chưa lưu được giao dịch. Vui lòng thử lại.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = context.select((LedgerViewModel model) => model.saving);
    final categories = _kind == TransactionKind.expense
        ? expenseCategories
        : incomeCategories;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return PopScope(
      canPop: !saving,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(spacing),
            child: Form(
              key: _form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Giao dịch mới',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Đóng',
                        onPressed: saving ? null : () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  SegmentedButton<TransactionKind>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(
                        value: TransactionKind.expense,
                        label: Text('Chi tiêu'),
                      ),
                      ButtonSegment(
                        value: TransactionKind.income,
                        label: Text('Thu nhập'),
                      ),
                    ],
                    selected: {_kind},
                    onSelectionChanged: saving
                        ? null
                        : (values) {
                            if (values.first == _kind) return;
                            setState(() {
                              _kind = values.first;
                              _category = null;
                            });
                          },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    key: const Key('transaction-amount'),
                    controller: _amount,
                    autofocus: true,
                    enabled: !saving,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontFeatures: numeric),
                    decoration: const InputDecoration(
                      labelText: 'Số tiền',
                      suffixText: 'đ',
                    ),
                    inputFormatters: [
                      TextInputFormatter.withFunction((old, next) {
                        if (!RegExp(r'^[0-9.]*$').hasMatch(next.text)) {
                          return old;
                        }
                        final digits = next.text.replaceAll('.', '');
                        if (digits.isEmpty) return TextEditingValue.empty;
                        final formatted = formatVnd(BigInt.parse(digits));
                        final text = formatted.substring(
                          0,
                          formatted.length - 2,
                        );
                        return TextEditingValue(
                          text: text,
                          selection: TextSelection.collapsed(
                            offset: text.length,
                          ),
                        );
                      }),
                    ],
                    validator: (value) {
                      final amount = BigInt.tryParse(
                        (value ?? '').replaceAll('.', ''),
                      );
                      if (amount == null || amount <= BigInt.zero) {
                        return 'Nhập số tiền lớn hơn 0 đ.';
                      }
                      final limit = BigInt.one << 63;
                      if (amount > limit ||
                          (_kind == TransactionKind.income &&
                              amount == limit)) {
                        return 'Số tiền vượt giới hạn.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  const Text('Danh mục'),
                  FormField<String>(
                    key: ValueKey(_kind),
                    initialValue: _category,
                    validator: (value) =>
                        value == null ? 'Hãy chọn danh mục.' : null,
                    builder: (field) => LayoutBuilder(
                      builder: (context, constraints) {
                        final scale =
                            MediaQuery.textScalerOf(context).scale(14) / 14;
                        final columns =
                            constraints.maxWidth >= 320 && scale <= 1.3 ? 4 : 2;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                for (final category in categories)
                                  SizedBox(
                                    width:
                                        (constraints.maxWidth -
                                                4 * (columns - 1)) /
                                            columns -
                                        0.1,
                                    child: FilterChip(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                      labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      label: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            categoryIcon(category),
                                            size: 18,
                                            color: primary,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            category,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      selected: _category == category,
                                      showCheckmark: false,
                                      onSelected: saving
                                          ? null
                                          : (_) {
                                              field.didChange(category);
                                              setState(
                                                () => _category = category,
                                              );
                                            },
                                    ),
                                  ),
                              ],
                            ),
                            if (field.errorText case final error?)
                              Text(
                                error,
                                style: const TextStyle(color: expense),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _walletId,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Nguồn tiền'),
                    items: [
                      for (final wallet in widget.wallets)
                        DropdownMenuItem(
                          value: wallet.id,
                          child: Text(
                            wallet.isDefault
                                ? '${wallet.name} · Mặc định'
                                : wallet.name,
                          ),
                        ),
                    ],
                    onChanged: saving ? null : (id) => _walletId = id!,
                  ),
                  TextButton(
                    onPressed: saving
                        ? null
                        : () => setState(() => _optional = !_optional),
                    child: Text(
                      _optional
                          ? 'Ẩn tùy chọn'
                          : 'Thêm ghi chú hoặc đổi ngày giờ',
                    ),
                  ),
                  if (_optional) ...[
                    TextField(
                      controller: _note,
                      enabled: !saving,
                      decoration: const InputDecoration(labelText: 'Ghi chú'),
                    ),
                    TextButton(
                      onPressed: saving ? null : _chooseTime,
                      child: Text(
                        _occurredAt == null
                            ? 'Ngày giờ: Hiện tại'
                            : '${displayDate(_occurredAt!)} · ${displayTime(_occurredAt!)}',
                      ),
                    ),
                  ],
                  if (_saveError case final error?)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        error,
                        style: const TextStyle(color: expense),
                      ),
                    ),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: saving ? null : _save,
                    child: Text(saving ? 'Đang lưu…' : 'Lưu giao dịch'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }
}
