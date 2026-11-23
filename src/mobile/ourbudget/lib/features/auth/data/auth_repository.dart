import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_client.dart';

const authRedirectUrl = 'com.ourbudget.ourbudget://auth-callback';

enum AuthEvent { initialSession, signedIn, signedOut, tokenRefreshed, passwordRecovery, userUpdated }

abstract interface class AuthGateway {
  Stream<AuthEvent> get events;
  Map<String, dynamic>? get currentUser;
  String? get accessToken;
  bool get hasSession;
  Future<void> passwordLogin(String email, String password);
  Future<bool> register(String name, String email, String password);
  Future<bool> googleLogin();
  Future<void> forgot(String email);
  Future<void> reset(String password);
  Future<void> resendVerification(String email);
  Future<void> updateProfile(Map<String, dynamic> values);
  Future<bool> linkGoogle();
  Future<void> signOut();
}

class SupabaseSecureLocalStorage extends LocalStorage {
  SupabaseSecureLocalStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'ourbudget_supabase_session';
  final FlutterSecureStorage _storage;
  String? _session;

  @override
  Future<void> initialize() async => _session = await _storage.read(key: _key);

  @override
  Future<bool> hasAccessToken() async => _session != null;

  @override
  Future<String?> accessToken() async => _session;

  @override
  Future<void> persistSession(String persistSessionString) async {
    _session = persistSessionString;
    await _storage.write(key: _key, value: persistSessionString);
  }

  @override
  Future<void> removePersistedSession() async {
    _session = null;
    await _storage.delete(key: _key);
  }
}

class AuthRepository implements AuthGateway {
  AuthRepository(this.api, this.client);

  final ApiClient api;
  final SupabaseClient client;

  @override
  String? get accessToken => client.auth.currentSession?.accessToken;

  @override
  bool get hasSession => client.auth.currentSession != null;

  @override
  Map<String, dynamic>? get currentUser {
    final user = client.auth.currentUser;
    if (user == null) return null;
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final providers = user.identities?.map((identity) => identity.provider).toSet() ?? {};
    return {
      'id': user.id,
      'name': metadata['full_name'] ?? metadata['name'] ?? user.email?.split('@').first ?? 'Người dùng',
      'email': user.email ?? '',
      'phone': metadata['phone'] ?? user.phone ?? '',
      'avatar_url': metadata['avatar_url'] ?? '',
      'email_verified': user.emailConfirmedAt != null,
      'has_password': providers.contains('email'),
      'google_linked': providers.contains('google'),
    };
  }

  @override
  Stream<AuthEvent> get events => client.auth.onAuthStateChange.map((state) {
    final event = state.event;
    if (event == AuthChangeEvent.signedIn) return AuthEvent.signedIn;
    if (event == AuthChangeEvent.signedOut) return AuthEvent.signedOut;
    if (event == AuthChangeEvent.tokenRefreshed) return AuthEvent.tokenRefreshed;
    if (event == AuthChangeEvent.passwordRecovery) return AuthEvent.passwordRecovery;
    if (event == AuthChangeEvent.initialSession) return AuthEvent.initialSession;
    return AuthEvent.userUpdated;
  });

  @override
  Future<void> passwordLogin(String email, String password) async {
    await client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<bool> register(String name, String email, String password) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: authRedirectUrl,
      data: {'full_name': name},
    );
    return response.session != null;
  }

  @override
  Future<bool> googleLogin() => client.auth.signInWithOAuth(
    OAuthProvider.google,
    redirectTo: authRedirectUrl,
    authScreenLaunchMode: LaunchMode.externalApplication,
  );

  @override
  Future<void> forgot(String email) => client.auth.resetPasswordForEmail(
    email,
    redirectTo: authRedirectUrl,
  );

  @override
  Future<void> reset(String password) async {
    await client.auth.updateUser(UserAttributes(password: password));
  }

  @override
  Future<void> resendVerification(String email) => client.auth.resend(
    type: OtpType.signup,
    email: email,
    emailRedirectTo: authRedirectUrl,
  );

  @override
  Future<void> updateProfile(Map<String, dynamic> values) async {
    final current = client.auth.currentUser;
    if (current == null) throw const AuthException('Vui lòng đăng nhập lại.');
    final metadata = <String, dynamic>{
      ...?current.userMetadata,
      'full_name': values['name'],
      'phone': values['phone'],
      'avatar_url': values['avatar_url'],
    };
    final email = values['email'] as String?;
    await client.auth.updateUser(
      UserAttributes(
        email: email == current.email ? null : email,
        data: metadata,
        currentPassword: values['current_password'] as String?,
      ),
    );
  }

  @override
  Future<bool> linkGoogle() => client.auth.linkIdentity(
    OAuthProvider.google,
    redirectTo: authRedirectUrl,
    authScreenLaunchMode: LaunchMode.externalApplication,
  );

  @override
  Future<void> signOut() => client.auth.signOut(scope: SignOutScope.local);
}
