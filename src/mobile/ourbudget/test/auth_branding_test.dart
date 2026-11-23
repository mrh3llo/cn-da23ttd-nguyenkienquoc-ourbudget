import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ourbudget/app/ourbudget_app.dart';
import 'package:ourbudget/core/config/api_config.dart';
import 'package:ourbudget/core/network/api_client.dart';
import 'package:ourbudget/features/auth/presentation/auth_controller.dart';

import 'auth_controller_test.dart' show FakeAuth;

void main() {
  testWidgets('auth modes keep the official wordmark aligned on a small screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = AuthController(
      FakeAuth(),
      ApiClient(const ApiConfig(baseUrl: 'https://example.invalid')),
    );
    await auth.restore();
    await tester.pumpWidget(OurBudgetApp(authController: auth));
    await tester.pump(const Duration(milliseconds: 50));

    final logo = find.byType(Image);
    expect(logo, findsOneWidget);
    final image = tester.widget<Image>(logo);
    expect((image.image as AssetImage).assetName, 'assets/icons/our-budget-wordmark.png');
    expect(image.semanticLabel, 'OurBudget');
    final bounds = tester.getRect(logo);
    expect(bounds.width, 204);
    expect(bounds.height, 48);

    for (final label in [
      'Chưa có tài khoản? Đăng ký',
      'Đã có tài khoản? Đăng nhập',
      'Quên mật khẩu?',
    ]) {
      await tester.tap(find.text(label));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.getRect(logo), bounds);
      expect(tester.takeException(), isNull);
    }
  });
}
