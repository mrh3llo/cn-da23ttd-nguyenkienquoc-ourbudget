import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';
import '../data/auth_repository.dart';

enum SessionState { restoring, signedOut, signedIn, unavailable }

class AuthController extends ChangeNotifier {
  AuthController(this.repository, this.store, this.google) {
    repository.api.sessionToken = () => _token;
    repository.api.onExpired = (token) {
      if (token == _token) logout(expired: true);
    };
  }
  final AuthRepository repository;
  final TokenStore store;
  final GoogleLogin google;
  SessionState state = SessionState.restoring;
  Map<String, dynamic>? user;
  String? error;
  bool busy = false;
  int generation = 0;
  String? _token;
  bool _disposed = false;
  Future<void> _storageTail = Future.value();

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _storage(Future<void> Function() operation) {
    final result = _storageTail.then((_) => operation());
    _storageTail = result.catchError((Object _) {});
    return result;
  }

  Future<void> restore() async {
    final version = ++generation;
    state = SessionState.restoring;
    error = null;
    _notify();
    try {
      final token = await store.read();
      if (version != generation) return;
      _token = token;
      if (token == null) {
        state = SessionState.signedOut;
      } else {
        final result = await repository.request('GET', 'me');
        if (version != generation) return;
        user = Map<String, dynamic>.from(result['user'] as Map);
        state = SessionState.signedIn;
      }
    } on Exception catch (e) {
      if (version != generation) return;
      state = SessionState.unavailable;
      error = e is ApiException
          ? e.message
          : 'Không đọc được phiên đã lưu. Hãy thử lại.';
    }
    if (version == generation) _notify();
  }

  Future<bool> _operation(
    Future<Map<String, dynamic>> Function() action, {
    bool login = false,
  }) async {
    if (busy) return false;
    final version = generation;
    busy = true;
    error = null;
    _notify();
    try {
      final result = await action();
      if (version != generation) return false;
      if (login) {
        final token = result['token'] as String;
        await _storage(() async {
          if (version == generation) await store.write(token);
        });
        if (version != generation) return false;
        _token = token;
        generation++;
        state = SessionState.signedIn;
      }
      if (result['user'] != null) {
        user = Map<String, dynamic>.from(result['user'] as Map);
      }
      if (result['mail_warning'] == true) {
        error = 'Đã lưu thành công nhưng chưa xếp được email vào hàng đợi. Hãy yêu cầu gửi lại mã nếu cần.';
      }
      return true;
    } on Exception catch (e) {
      if (version == generation) {
        error = e is ApiException
            ? e.message
            : 'Không hoàn tất thao tác. Vui lòng thử lại.';
      }
      return false;
    } finally {
      // A logout supersedes this request and owns its own state.
      if (version == generation ||
          (login &&
              version + 1 == generation &&
              state == SessionState.signedIn)) {
        busy = false;
        _notify();
      }
    }
  }

  Future<bool> passwordLogin(String email, String password) => _operation(
    () => repository.request(
      'POST',
      'auth/login',
      authenticated: false,
      body: {'email': email, 'password': password},
    ),
    login: true,
  );
  Future<bool> register(String name, String email, String password) =>
      _operation(
        () => repository.request(
          'POST',
          'auth/register',
          authenticated: false,
          body: {'name': name, 'email': email, 'password': password},
        ),
        login: true,
      );
  Future<bool> googleLogin() => _operation(
    () async => repository.request(
      'POST',
      'auth/google',
      authenticated: false,
      body: {'id_token': await google.token()},
    ),
    login: true,
  );
  Future<bool> linkGoogle(String password) => _operation(
    () async => repository.request(
      'POST',
      'auth/google/link',
      body: {'id_token': await google.token(), 'password': password},
    ),
  );
  Future<bool> verifyEmail(String code) => _operation(
    () => repository.request('POST', 'auth/verify-email', body: {'code': code}),
  );
  Future<bool> resendVerification() => _operation(
    () => repository.request('POST', 'auth/resend-verification', body: {}),
  );
  Future<bool> forgot(String email) => _operation(
    () => repository.request(
      'POST',
      'auth/forgot-password',
      authenticated: false,
      body: {'email': email},
    ),
  );
  Future<bool> reset(String email, String code, String password) => _operation(
    () => repository.request(
      'POST',
      'auth/reset-password',
      authenticated: false,
      body: {'email': email, 'code': code, 'password': password},
    ),
  );
  Future<bool> updateProfile(Map<String, dynamic> values) => _operation(
    () async {
      if (values['email'] != user?['email'] && user?['has_password'] == false) {
        values['id_token'] = await google.token();
      }
      return repository.request('PATCH', 'me', body: values);
    },
  );

  Future<void> logout({bool expired = false}) async {
    final token = _token;
    final version = ++generation;
    _token = null;
    user = null;
    busy = false;
    state = SessionState.signedOut;
    error = expired ? 'Phiên đã hết hạn. Vui lòng đăng nhập lại.' : null;
    _notify();
    try {
      await _storage(store.clear);
    } on Exception {
      if (version == generation) {
        error =
            'Không xóa được phiên trong bộ nhớ bảo mật. Hãy thử đăng xuất lại.';
      }
    }
    if (!expired && token != null) {
      try {
        await repository.request(
          'POST',
          'auth/logout',
          body: {},
          authenticated: false,
          token: token,
        );
      } on Exception {
        if (version == generation) error = 'Đã thoát trên thiết bị; chưa xác nhận thu hồi phiên trên máy chủ.';
      }
    }
    try {
      if (version == generation) await google.signOut();
    } on Exception {
      /* Internal session has already been cleared. */
    }
    if (version == generation) _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    generation++;
    repository.api.onExpired = null;
    super.dispose();
  }
}
