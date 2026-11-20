import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ourbudget/app/ourbudget_app.dart';
import 'package:ourbudget/features/transactions/data/transaction_repository.dart';

void main() {
  testWidgets('giữ bộ lọc và lưu giao dịch từ tab Lịch sử', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const OurBudgetApp());
    await tester.pumpAndSettle();
    expect(find.text('5.420.000 đ'), findsOneWidget);

    await tester.tap(find.text('Xem tất cả'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ChoiceChip, 'Tiền mặt'));
    await tester.pumpAndSettle();
    expect(find.text('Lương'), findsNothing);
    await tester.tap(find.byKey(const ValueKey('tab-2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tab-1')));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Tiền mặt'))
          .selected,
      isTrue,
    );

    await tester.tap(find.byTooltip('Ghi giao dịch'));
    await tester.pumpAndSettle();
    expect(find.text('Tiền mặt · Mặc định'), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Giao dịch mới'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, 'Tiền mặt'), findsOneWidget);

    await tester.tap(find.byTooltip('Ghi giao dịch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu giao dịch'));
    await tester.pumpAndSettle();
    expect(find.text('Nhập số tiền lớn hơn 0 đ.'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('transaction-amount')),
      '25000',
    );
    expect(find.text('25.000'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilterChip, 'Ăn uống'));
    await tester.ensureVisible(find.text('Lưu giao dịch'));
    await tester.tap(find.text('Lưu giao dịch'));
    await tester.pumpAndSettle();
    expect(find.text('−25.000 đ'), findsWidgets);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Tiền mặt'))
          .selected,
      isTrue,
    );
    await tester.tap(find.byKey(const ValueKey('tab-0')));
    await tester.pumpAndSettle();
    expect(find.text('5.395.000 đ'), findsOneWidget);
  });

  testWidgets('tải lại sau lỗi và phân biệt dữ liệu rỗng', (tester) async {
    await tester.pumpWidget(OurBudgetApp(createRepository: _FailThenEmpty.new));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Không thể tải dữ liệu. Hãy thử lại.'), findsOneWidget);
    await tester.tap(find.text('Tải lại'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có giao dịch.'), findsOneWidget);
  });

  testWidgets('giữ bản nháp khoản thu sau lỗi lưu và cho thử lại', (
    tester,
  ) async {
    await tester.pumpWidget(OurBudgetApp(createRepository: _FailFirstSave.new));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ghi giao dịch'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thu nhập'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(FilterChip, 'Ăn uống'), findsNothing);
    await tester.tap(find.widgetWithText(FilterChip, 'Thưởng'));
    await tester.enterText(
      find.byKey(const Key('transaction-amount')),
      '50000',
    );
    final save = find.text('Lưu giao dịch');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(
      find.text('Chưa lưu được giao dịch. Vui lòng thử lại.'),
      findsOneWidget,
    );
    expect(find.text('50.000'), findsOneWidget);
    expect(
      tester
          .widget<FilterChip>(find.widgetWithText(FilterChip, 'Thưởng'))
          .selected,
      isTrue,
    );

    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Giao dịch mới'), findsNothing);
    expect(find.text('5.470.000 đ'), findsOneWidget);
  });

  testWidgets('cổng phiên đặt lại tab và dữ liệu của phiên thử', (
    tester,
  ) async {
    var created = 0;
    await tester.pumpWidget(
      OurBudgetApp(
        createRepository: () {
          created++;
          return FakeTransactionRepository();
        },
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tab-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Thoát phiên thử nghiệm'));
    await tester.pumpAndSettle();
    expect(find.text('Mở bản thử nghiệm'), findsOneWidget);
    await tester.tap(find.text('Mở bản thử nghiệm'));
    await tester.pumpAndSettle();
    expect(find.text('5.420.000 đ'), findsOneWidget);
    expect(created, 2);
  });

  testWidgets('biểu mẫu cuộn được trên màn hình hẹp với chữ lớn và bàn phím', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(const OurBudgetApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ghi giao dịch'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    await tester.pumpAndSettle();

    final save = find.text('Lưu giao dịch');
    final form = find.byType(SingleChildScrollView).last;
    await tester.dragUntilVisible(save, form, const Offset(0, -100));
    await tester.tap(save);
    await tester.pumpAndSettle();
    expect(find.text('Nhập số tiền lớn hơn 0 đ.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

class _FailFirstSave extends FakeTransactionRepository {
  var _attempts = 0;

  @override
  Future<Ledger> create({
    required String category,
    required String walletId,
    required BigInt amount,
    required DateTime occurredAt,
    required String note,
  }) async {
    if (_attempts++ == 0) throw const FormatException();
    return super.create(
      category: category,
      walletId: walletId,
      amount: amount,
      occurredAt: occurredAt,
      note: note,
    );
  }
}

class _FailThenEmpty extends FakeTransactionRepository {
  var _attempts = 0;

  @override
  Future<Ledger> load() async {
    if (_attempts++ == 0) throw const FormatException();
    return Ledger(const [], const [], BigInt.zero);
  }
}
