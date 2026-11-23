import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:ourbudget/core/config/api_config.dart';
import 'package:ourbudget/core/network/api_client.dart';
import 'package:ourbudget/features/auth/data/auth_repository.dart';
import 'package:ourbudget/features/auth/presentation/auth_controller.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeAuth implements AuthGateway {
  final eventsController = StreamController<AuthEvent>.broadcast();
  @override
  bool hasSession = false;
  bool registrationNeedsVerification = true;
  bool googleCanStart = true;
  int loginCalls = 0;
  @override
  String? accessToken;

  void signedIn() {
    hasSession = true;
    accessToken = 'supabase-access-token';
    currentUser = {
      'id': 'user-1',
      'name': 'Test User',
      'email': 'test@example.com',
      'phone': '',
      'avatar_url': '',
      'email_verified': true,
      'has_password': true,
      'google_linked': false,
    };
    eventsController.add(AuthEvent.signedIn);
  }

  @override
  Stream<AuthEvent> get events => eventsController.stream;
  @override
  Future<void> passwordLogin(String email, String password) async {
    loginCalls++;
    if (password == 'wrong-password') {
      throw const AuthException('Invalid login credentials');
    }
    signedIn();
  }

  @override
  Future<bool> register(String name, String email, String password) async {
    if (email == 'duplicate@example.com') {
      throw const AuthException('User already registered');
    }
    if (!registrationNeedsVerification) signedIn();
    return !registrationNeedsVerification;
  }

  @override
  Future<bool> googleLogin() async => googleCanStart;
  @override
  Future<void> forgot(String email) async {}
  @override
  Future<void> reset(String password) async => signedIn();
  @override
  Future<void> resendVerification(String email) async {}
  @override
  Future<void> updateProfile(Map<String, dynamic> values) async {
    currentUser = {...?currentUser, 'name': values['name']};
  }
  @override
  Future<bool> linkGoogle() async => true;
  @override
  Future<void> signOut() async {
    hasSession = false;
    accessToken = null;
    currentUser = null;
    eventsController.add(AuthEvent.signedOut);
  }

  @override
  Map<String, dynamic>? get currentUser => _currentUser;
  set currentUser(Map<String, dynamic>? value) => _currentUser = value;
  Map<String, dynamic>? _currentUser;

  Future<void> close() => eventsController.close();
}

void main() {
  late FakeAuth gateway;
  late AuthController auth;
  late ApiClient api;

  setUp(() async {
    gateway = FakeAuth();
    api = ApiClient(const ApiConfig(baseUrl: 'https://example.invalid'));
    auth = AuthController(gateway, api);
    await auth.restore();
  });
  tearDown(() async {
    auth.dispose();
    await gateway.close();
  });

  test('restores Supabase session and exposes its bearer token to API', () async {
    gateway.signedIn();
    await auth.restore();
    expect(auth.state, SessionState.signedIn);
    expect(auth.user!['id'], 'user-1');
    expect(api.sessionToken!(), 'supabase-access-token');
  });

  test('successful email login opens the authenticated route', () async {
    expect(await auth.passwordLogin('test@example.com', 'Password!123'), isTrue);
    expect(auth.state, SessionState.signedIn);
  });

  test('incorrect credentials remain signed out with a clear error', () async {
    expect(await auth.passwordLogin('test@example.com', 'wrong-password'), isFalse);
    expect(auth.state, SessionState.signedOut);
    expect(auth.error, 'Email hoặc mật khẩu không đúng.');
  });

  test('registration waits for email confirmation when Supabase requires it', () async {
    expect(await auth.register('Test', 'test@example.com', 'Password!123'), isTrue);
    expect(auth.state, SessionState.signedOut);
    expect(auth.notice, contains('xác minh'));
  });

  test('duplicate registration reports the provider error without signing in', () async {
    expect(
      await auth.register('Test', 'duplicate@example.com', 'Password!123'),
      isFalse,
    );
    expect(auth.state, SessionState.signedOut);
    expect(auth.error, 'Email này đã được đăng ký.');
  });

  test('forgot password uses a generic notice and recovery event opens reset mode', () async {
    expect(await auth.forgot('test@example.com'), isTrue);
    expect(auth.notice, contains('Nếu email đã đăng ký'));
    gateway.eventsController.add(AuthEvent.passwordRecovery);
    await Future<void>.delayed(Duration.zero);
    expect(auth.isPasswordRecovery, isTrue);
    expect(auth.state, SessionState.signedOut);
  });

  test('password reset accepts the recovery session and enters the app', () async {
    gateway.signedIn();
    gateway.eventsController.add(AuthEvent.passwordRecovery);
    await Future<void>.delayed(Duration.zero);
    expect(await auth.reset('NewPassword!123'), isTrue);
    expect(auth.isPasswordRecovery, isFalse);
    expect(auth.state, SessionState.signedIn);
  });

  test('Google cancellation leaves the authentication screen available', () async {
    gateway.googleCanStart = false;
    expect(await auth.googleLogin(), isFalse);
    expect(auth.state, SessionState.signedOut);
    expect(auth.notice, 'Đăng nhập Google đã bị hủy.');
  });

  test('Google callback event restores the authenticated route', () async {
expect(authRedirectUrl, 'com.ourbudget.ourbudget://auth-callback');
    expect(await auth.googleLogin(), isTrue);
    gateway.signedIn();
    await Future<void>.delayed(Duration.zero);
    expect(auth.state, SessionState.signedIn);
  });

  test('logout clears session and authenticated user state', () async {
    gateway.signedIn();
    await auth.restore();
    await auth.logout();
    expect(auth.state, SessionState.signedOut);
    expect(auth.user, isNull);
    expect(gateway.hasSession, isFalse);
  });
}
