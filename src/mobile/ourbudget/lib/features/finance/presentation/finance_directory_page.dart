import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../core/format/finance_format.dart';
import '../../../core/network/api_client.dart';
import '../../../design_system/app_theme.dart';
import '../../auth/presentation/auth_controller.dart';

class FinanceDirectoryPage extends StatefulWidget {
  const FinanceDirectoryPage({super.key, this.wallets = false, this.pickType});

  final bool wallets;
  final String? pickType;

  @override
  State<FinanceDirectoryPage> createState() => _FinanceDirectoryPageState();
}

class _FinanceDirectoryPageState extends State<FinanceDirectoryPage> {
  late String _type = widget.pickType ?? 'expense';
  late final ApiClient _api = context.read<AuthController>().api;
  late Future<List<Map<String, dynamic>>> _items = _load();

  Future<List<Map<String, dynamic>>> _load() => widget.wallets
      ? _api.list('wallets')
      : _api.list('categories', query: {'type': _type});

  void _reload() {
    setState(() {
      _items = _load();
    });
  }

  Future<void> _add() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            _EntryForm(api: _api, wallets: widget.wallets, type: _type),
      ),
    );
    if (mounted && created == true) _reload();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      title: Text(
        widget.wallets
            ? 'Quản lý ví'
            : widget.pickType == null
            ? 'Danh mục'
            : _type == 'income'
            ? 'Chọn danh mục thu'
            : 'Chọn danh mục chi',
      ),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(spacing),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!widget.wallets && widget.pickType == null) ...[
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('Chi tiêu')),
                  ButtonSegment(value: 'income', label: Text('Thu nhập')),
                ],
                selected: {_type},
                onSelectionChanged: (value) {
                  if (value.first == _type) return;
                  _type = value.first;
                  _reload();
                },
              ),
              const SizedBox(height: spacing),
            ],
            Expanded(
              child: FutureBuilder(
                future: _items,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_error(snapshot.error!)),
                          TextButton(
                            onPressed: _reload,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    );
                  }
                  final items = snapshot.data!;
                  if (items.isEmpty) {
                    return Center(
                      child: Text(
                        widget.wallets
                            ? 'Chưa có nguồn tiền.'
                            : 'Chưa có danh mục.',
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final subtitle = widget.wallets
                          ? '${item['category_name']} · ${formatVnd(BigInt.parse(item['current_balance'] as String))}'
                          : item['is_system'] == true
                          ? 'Danh mục hệ thống'
                          : 'Danh mục của bạn';
                      return Card(
                        child: ListTile(
                          title: Text(item['name'] as String),
                          subtitle: Text(subtitle),
                          onTap: widget.pickType != null
                              ? () => Navigator.pop(
                                  context,
                                  item['name'] as String,
                                )
                              : null,
                          trailing:
                              widget.wallets &&
                                  item['is_active'] == true &&
                                  item['priority'] == 0
                              ? const Text('Mặc định')
                              : null,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            FilledButton(
              onPressed: _add,
              child: Text(
                widget.wallets
                    ? 'Thêm nguồn tiền'
                    : _type == 'income'
                    ? 'Thêm danh mục thu'
                    : 'Thêm danh mục chi',
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

String _error(Object error) => error is ApiException
    ? error.message
    : 'Không tải được dữ liệu. Vui lòng thử lại.';

class _EntryForm extends StatefulWidget {
  const _EntryForm({
    required this.api,
    required this.wallets,
    required this.type,
  });
  final ApiClient api;
  final bool wallets;
  final String type;

  @override
  State<_EntryForm> createState() => _EntryFormState();
}

class _EntryFormState extends State<_EntryForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _balance = TextEditingController(text: '0');
  String? _walletType, _message;
  bool _saving = false;
  late Future<Map<String, dynamic>> _walletTypes = widget.api.send(
    'GET',
    'wallet-categories',
  );

  @override
  void dispose() {
    _name.dispose();
    _balance.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving ||
        !_form.currentState!.validate() ||
        (widget.wallets && _walletType == null)) {
      return;
    }
    setState(() {
      _saving = true;
      _message = null;
    });
    try {
      await widget.api.send(
        'POST',
        widget.wallets ? 'wallets' : 'categories',
        body: {
          'name': _name.text.trim(),
          if (widget.wallets) ...{
            'category_id': _walletType,
            'opening_balance': BigInt.parse(_balance.text.trim()).toString(),
          } else
            'type': widget.type,
        },
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _message = _error(error);
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: _saving ? null : () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          widget.wallets
              ? 'Thêm nguồn tiền'
              : widget.type == 'income'
              ? 'Thêm danh mục thu'
              : 'Thêm danh mục chi',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.all(spacing),
            children: [
              TextFormField(
                controller: _name,
                enabled: !_saving,
                maxLength: widget.wallets ? 100 : 150,
                decoration: InputDecoration(
                  labelText: widget.wallets ? 'Tên nguồn tiền' : 'Tên danh mục',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Nhập tên.' : null,
              ),
              if (widget.wallets) ...[
                FutureBuilder(
                  future: _walletTypes,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const LinearProgressIndicator();
                    }
                    if (snapshot.hasError) {
                      return TextButton(
                        onPressed: () => setState(() {
                          _walletTypes = widget.api.send(
                            'GET',
                            'wallet-categories',
                          );
                        }),
                        child: Text('${_error(snapshot.error!)} Thử lại'),
                      );
                    }
                    final types = (snapshot.data!['items'] as List)
                        .cast<Map<String, dynamic>>();
                    if (types.isEmpty) return const Text('Chưa có loại ví.');
                    return DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Loại nguồn tiền',
                      ),
                      items: [
                        for (final type in types)
                          DropdownMenuItem(
                            value: type['id'] as String,
                            child: Text(type['name'] as String),
                          ),
                      ],
                      onChanged: _saving
                          ? null
                          : (value) => setState(() => _walletType = value),
                      validator: (value) =>
                          value == null ? 'Chọn loại nguồn tiền.' : null,
                    );
                  },
                ),
                const SizedBox(height: spacing),
                TextFormField(
                  controller: _balance,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'Số dư đầu kỳ (đ)',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: true,
                  ),
                  validator: (value) {
                    final input = value?.trim() ?? '';
                    final balance = BigInt.tryParse(input);
                    return !RegExp(r'^-?[0-9]{1,19}$').hasMatch(input) ||
                            balance == null ||
                            balance < BigInt.parse('-9223372036854775808') ||
                            balance > BigInt.parse('9223372036854775807')
                        ? 'Nhập số tiền nguyên hợp lệ.'
                        : null;
                  },
                ),
              ],
              const SizedBox(height: spacing),
              if (_message != null)
                Text(_message!, style: const TextStyle(color: expense)),
              FilledButton(
                onPressed: _saving || (widget.wallets && _walletType == null)
                    ? null
                    : _save,
                child: Text(_saving ? 'Đang lưu…' : 'Lưu'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
