import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ourbudget/core/config/api_config.dart';
import 'package:ourbudget/core/network/api_client.dart';
import 'package:ourbudget/features/auth/data/auth_repository.dart';
import 'package:ourbudget/features/auth/presentation/auth_controller.dart';

class MemoryStore implements TokenStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String token) async {
    value = token;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

class FakeGoogle extends GoogleLogin {
  @override
  Future<void> signOut() async {}
}

class StubAuth extends AuthRepository {
  StubAuth()
    : super(ApiClient(const ApiConfig(baseUrl: 'https://example.invalid')));
  Future<Map<String, dynamic>> Function(
    String path,
    Map<String, dynamic>? body,
  )?
  handler;
  @override
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? token,
  }) => handler!(path, body);
}

Map<String, dynamic> account(String id) => {
  'id': id,
  'name': 'User $id',
  'email': '$id@example.test',
  'email_verified': true,
  'has_password': true,
  'google_linked': false,
};

void main() {
  late MemoryStore store;
  late StubAuth repository;
  late AuthController auth;
  setUp(() {
    store = MemoryStore();
    repository = StubAuth();
    auth = AuthController(repository, store, FakeGoogle());
  });
  tearDown(() => auth.dispose());

  test('offline restore retains token without opening private UI', () async {
    store.value = 'saved';
    repository.handler = (_, _) async =>
        throw const ApiException(0, 'network_unavailable', 'Offline');
    await auth.restore();
    expect(auth.state, SessionState.unavailable);
    expect(auth.user, isNull);
    expect(store.value, 'saved');
  });

  test('late profile response from A cannot enter session B', () async {
    repository.handler = (_, _) async => {
      'token': 'token-a',
      'user': account('a'),
    };
    await auth.passwordLogin('a@example.test', 'Password!123');
    final delayed = Completer<Map<String, dynamic>>();
    repository.handler = (path, _) async =>
        path == 'me' ? delayed.future : {'revoked': true};
    final update = auth.updateProfile({
      'name': 'Old A',
      'email': 'a@example.test',
    });
    await auth.logout();
    expect(store.value, isNull);
    repository.handler = (_, _) async => {
      'token': 'token-b',
      'user': account('b'),
    };
    await auth.passwordLogin('b@example.test', 'Password!123');
    delayed.complete({'user': account('a')});
    expect(await update, isFalse);
    expect(auth.user!['id'], 'b');
    expect(store.value, 'token-b');
    repository.api.onExpired!('token-a');
    await Future<void>.delayed(Duration.zero);
    expect(auth.user!['id'], 'b');
  });

  test('late sign-in cannot resurrect a logged-out session', () async {
    final delayed = Completer<Map<String, dynamic>>();
    repository.handler = (_, _) => delayed.future;
    final login = auth.passwordLogin('a@example.test', 'Password!123');
    await auth.logout();
    delayed.complete({'token': 'old', 'user': account('a')});
    expect(await login, isFalse);
    expect(auth.state, SessionState.signedOut);
    expect(store.value, isNull);
  });

  test(
    'offline logout clears local session and reports unconfirmed revoke',
    () async {
      repository.handler = (_, _) async => {
        'token': 'token-a',
        'user': account('a'),
      };
      await auth.passwordLogin('a@example.test', 'Password!123');
      repository.handler = (_, _) async =>
          throw const ApiException(0, 'network_unavailable', 'Offline');
      await auth.logout();
      expect(store.value, isNull);
      expect(auth.user, isNull);
      expect(auth.state, SessionState.signedOut);
      expect(auth.error, contains('chưa xác nhận'));
    },
  );

  test('expired current session clears secure storage', () async {
    repository.handler = (_, _) async => {
      'token': 'token-a',
      'user': account('a'),
    };
    await auth.passwordLogin('a@example.test', 'Password!123');
    repository.api.onExpired!('token-a');
    await Future<void>.delayed(Duration.zero);
    expect(store.value, isNull);
    expect(auth.state, SessionState.signedOut);
  });
}
