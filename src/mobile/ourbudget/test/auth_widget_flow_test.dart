import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ourbudget/app/ourbudget_app.dart';
import 'package:ourbudget/core/config/api_config.dart';
import 'package:ourbudget/core/network/api_client.dart';
import 'package:ourbudget/features/auth/presentation/auth_controller.dart';
import 'package:ourbudget/features/auth/presentation/auth_page.dart';

import 'auth_controller_test.dart' show FakeAuth;

class _EmptyWalletApi extends ApiClient {
  _EmptyWalletApi()
    : super(const ApiConfig(baseUrl: 'https://example.invalid'));

  @override
  Future<List<Map<String, dynamic>>> list(
    String path, {
    Map<String, String> query = const {},
  }) async => [];
}

class _DirectoryApi extends ApiClient {
  _DirectoryApi() : super(const ApiConfig(baseUrl: 'https://example.invalid'));

  final created = <Map<String, dynamic>>[];

  @override
  Future<List<Map<String, dynamic>>> list(
    String path, {
    Map<String, String> query = const {},
  }) async => [
    {
      'name': query['type'] == 'income' ? 'Lương' : 'Ăn uống',
      'is_system': true,
    },
    for (final row in created)
      if (row['type'] == query['type']) row,
  ];

  @override
  Future<Map<String, dynamic>> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? explicitToken,
  }) async {
    expect(method, 'POST');
    expect(path, 'categories');
    created.add(body!);
    return {'id': '${created.length}'};
  }
}

void main() {
  testWidgets('loads existing categories and adds separately to each type', (
    tester,
  ) async {
    final gateway = FakeAuth();
    final api = _DirectoryApi();
    final auth = AuthController(gateway, api);
    gateway.signedIn();
    await auth.restore();
    await tester.pumpWidget(OurBudgetApp(authController: auth));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('tab-3')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Danh mục'));
    await tester.pumpAndSettle();

    for (final (tab, original, button, name) in [
      ('Chi tiêu', 'Ăn uống', 'Thêm danh mục chi', 'Mua sách'),
      ('Thu nhập', 'Lương', 'Thêm danh mục thu', 'Tiền thưởng'),
    ]) {
      await tester.tap(find.text(tab));
      await tester.pumpAndSettle();
      expect(find.text(original), findsOneWidget);
      await tester.tap(find.text(button));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), name);
      await tester.tap(find.text('Lưu'));
      await tester.pumpAndSettle();
      expect(find.text(name), findsOneWidget);
    }
    expect(api.created, [
      {'name': 'Mua sách', 'type': 'expense'},
      {'name': 'Tiền thưởng', 'type': 'income'},
    ]);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('invalid form input is blocked before authentication', (
    tester,
  ) async {
    final gateway = FakeAuth();
    final auth = AuthController(
      gateway,
      ApiClient(const ApiConfig(baseUrl: 'https://example.invalid')),
    );
    await auth.restore();
    await tester.pumpWidget(OurBudgetApp(authController: auth));
    await tester.pump(const Duration(milliseconds: 50));

    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pump();

    expect(find.text('Nhập email hợp lệ.'), findsOneWidget);
    expect(gateway.loginCalls, 0);
    expect(auth.state, SessionState.signedOut);
    await tester.pumpWidget(const SizedBox.shrink());
    await gateway.close();
  });

  testWidgets('signed-out routes are protected and logout returns to login', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.padding = const FakeViewPadding(left: 24);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    final gateway = FakeAuth();
    final auth = AuthController(gateway, _EmptyWalletApi());
    await auth.restore();
    await tester.pumpWidget(OurBudgetApp(authController: auth));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(AuthPage), findsOneWidget);

    gateway.signedIn();
    await tester.pump();
    expect(auth.state, SessionState.signedIn);
    expect(find.byType(AuthPage), findsNothing);

    final add = find.byTooltip('Ghi giao dịch');
    expect(add, findsOneWidget);
    expect(find.text('Thêm giao dịch'), findsNothing);
    final addCenter = tester.getCenter(add);
    expect(
      addCenter.dx,
      tester.view.physicalSize.width / tester.view.devicePixelRatio / 2,
    );
    final messenger = ScaffoldMessenger.of(tester.element(add));
    messenger.showSnackBar(const SnackBar(content: Text('Kiểm tra vị trí')));
    await tester.pumpAndSettle();
    expect(tester.getCenter(add), addCenter);
    messenger.removeCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.tap(add);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.text('Chưa có nguồn tiền.'), findsOneWidget);
    expect(find.text('Thêm nguồn tiền'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    for (final tab in [1, 2, 0, 3]) {
      final target = find.byKey(ValueKey('tab-$tab'));
      await tester.tap(target);
      await tester.pump();
      expect(tester.getCenter(add), addCenter);
      final destination = find
          .ancestor(
            of: target,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics && widget.properties.selected != null,
            ),
          )
          .first;
      expect(tester.widget<Semantics>(destination).properties.selected, isTrue);
    }
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('test@example.com'), findsOneWidget);
    expect(find.text('Đã xác minh'), findsOneWidget);
    await tester.tap(find.text('Thông tin tài khoản'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Họ tên'),
      'Tên đã sửa',
    );
    await tester.ensureVisible(find.text('Lưu hồ sơ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Lưu hồ sơ'));
    await tester.pumpAndSettle();
    expect(find.text('Thông tin tài khoản'), findsOneWidget);
    await tester.tap(find.byTooltip('Quay lại'));
    await tester.pumpAndSettle();
    expect(find.text('Tên đã sửa'), findsOneWidget);
    messenger.clearSnackBars();
    messenger.removeCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Đăng xuất'));
    await tester.pump();
    expect(auth.state, SessionState.signedOut);
    expect(find.byType(AuthPage), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
