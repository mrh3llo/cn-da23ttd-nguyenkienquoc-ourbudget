import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ourbudget/app/ourbudget_app.dart';
import 'package:ourbudget/features/auth/presentation/auth_controller.dart';

import 'auth_controller_test.dart' show MemoryStore, StubAuth, FakeGoogle;

void main() {
  testWidgets(
    'official wordmark stays aligned across auth modes and small screens',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = AuthController(StubAuth(), MemoryStore(), FakeGoogle());
      await auth.restore();
      await tester.pumpWidget(OurBudgetApp(authController: auth));
      await tester.pumpAndSettle();
      final logo = find.byType(Image);
      expect(logo, findsOneWidget);
      final image = tester.widget<Image>(logo);
      expect(
        (image.image as AssetImage).assetName,
        'assets/icons/our-budget-wordmark.png',
      );
      expect(image.semanticLabel, 'OurBudget');
      final bounds = tester.getRect(logo);
      expect(bounds.width, 204);
      expect(bounds.height, 48);

      for (final label in [
        'Chưa có tài khoản? Đăng ký',
        'Đã có tài khoản? Đăng nhập',
        'Quên mật khẩu?',
      ]) {
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(tester.getRect(logo), bounds);
        expect(tester.takeException(), isNull);
      }
      // The header remains visible when the form scrolls above the keyboard.
      tester.view.viewInsets = const FakeViewPadding(bottom: 280);
      addTearDown(tester.view.resetViewInsets);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      expect(tester.getRect(logo), bounds);
      await tester.scrollUntilVisible(
        find.text('Quay lại đăng nhập'),
        100,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
