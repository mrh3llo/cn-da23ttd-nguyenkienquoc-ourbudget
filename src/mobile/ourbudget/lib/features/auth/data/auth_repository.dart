import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/network/api_client.dart';

abstract interface class TokenStore {
  Future<String?> read();
  Future<void> write(String token);
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  final _storage = const FlutterSecureStorage();
  static const _key = 'ourbudget_session';
  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String token) => _storage.write(key: _key, value: token);
  @override
  Future<void> clear() => _storage.delete(key: _key);
}

class AuthRepository {
  AuthRepository(this.api);
  final ApiClient api;
  Future<Map<String, dynamic>> request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? token,
  }) => api.send(
    method,
    path,
    body: body,
    authenticated: authenticated,
    explicitToken: token,
  );
}

class GoogleLogin {
  Future<void>? _initialized;
  Future<String> token() async {
    _initialized ??= GoogleSignIn.instance.initialize(
      serverClientId: const String.fromEnvironment(
        'GOOGLE_SERVER_CLIENT_ID',
        defaultValue: '171608086306-eov7trctrio9s8jpof6g8bu2k8qemg4n.apps.googleusercontent.com',
      ),
    );
    await _initialized;
    final account = await GoogleSignIn.instance.authenticate();
    final token = account.authentication.idToken;
    if (token == null) {
      throw const ApiException(
        401,
        'google_token_missing',
        'Google không trả mã đăng nhập.',
      );
    }
    return token;
  }

  Future<void> signOut() async {
    if (_initialized != null) {
      await _initialized;
      await GoogleSignIn.instance.signOut();
    }
  }
}
