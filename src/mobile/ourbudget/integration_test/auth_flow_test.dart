import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ourbudget/app/ourbudget_app.dart';
import 'package:ourbudget/core/config/api_config.dart';
import 'package:ourbudget/core/network/api_client.dart';
import 'package:ourbudget/features/auth/presentation/auth_controller.dart';

import '../test/auth_controller_test.dart' show FakeAuth;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('unauthenticated users stay on login until a session exists', (
    tester,
  ) async {
    final gateway = FakeAuth();
    final controller = AuthController(
      gateway,
      ApiClient(const ApiConfig(baseUrl: 'https://example.invalid')),
    );
    await controller.restore();
    await tester.pumpWidget(OurBudgetApp(authController: controller));
    await tester.pumpAndSettle();
    expect(find.text('Đăng nhập'), findsOneWidget);

    await tester.enterText(find.byType(EditableText).at(0), 'test@example.com');
    await tester.enterText(find.byType(EditableText).at(1), 'Password!123');
    await tester.tap(find.widgetWithText(FilledButton, 'Đăng nhập'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tài khoản của bạn đã sẵn sàng'), findsOneWidget);

    await controller.logout();
    await tester.pumpAndSettle();
    expect(find.text('Đăng nhập'), findsOneWidget);
    await gateway.close();
  });
}
