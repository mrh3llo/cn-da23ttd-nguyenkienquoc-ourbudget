import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ourbudget/core/config/api_config.dart';
import 'package:ourbudget/core/network/api_client.dart';
import 'package:ourbudget/features/auth/data/auth_repository.dart';
import 'package:ourbudget/features/auth/presentation/auth_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android auth, secure storage, restore and account isolation', (
    tester,
  ) async {
    final store = SecureTokenStore();
    await store.clear();
    AuthController controller() => AuthController(
      AuthRepository(ApiClient(const ApiConfig())),
      store,
      GoogleLogin(),
    );
    final first = controller();
    final suffix = DateTime.now().microsecondsSinceEpoch;
    final email = 'android-$suffix@ourbudget.test';
    try {
      await first.restore();
      expect(first.state, SessionState.signedOut);
      expect(await first.register('Android A', email, 'Password!123'), isTrue);
      final id = first.user!['id'];
      expect(await store.read(), matches(r'^[a-f0-9]{64}$'));
      final restored = controller();
      await restored.restore();
      expect(restored.state, SessionState.signedIn);
      expect(restored.user!['id'], id);
      expect(
        await restored.updateProfile({
          'name': 'Android updated',
          'email': email,
        }),
        isTrue,
      );
      expect(restored.user!['name'], 'Android updated');
      await restored.logout();
      expect(await store.read(), isNull);
      await first.restore();
      expect(first.state, SessionState.signedOut);
      expect(await first.passwordLogin(email, 'WrongPassword'), isFalse);
      expect(await first.passwordLogin(email, 'Password!123'), isTrue);
      expect(first.user!['id'], id);
      await first.logout();
      expect(
        await first.register(
          'Android B',
          'android-b-$suffix@ourbudget.test',
          'Password!123',
        ),
        isTrue,
      );
      expect(first.user!['id'], isNot(id));
      expect(first.user!['name'], 'Android B');
      restored.dispose();
    } finally {
      await first.logout();
      first.dispose();
      await store.clear();
    }
  });
}
