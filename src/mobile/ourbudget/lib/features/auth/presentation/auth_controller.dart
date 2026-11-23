import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/network/api_client.dart';
import '../data/auth_repository.dart';

enum SessionState { restoring, signedOut, signedIn, unavailable }

class AuthController extends ChangeNotifier {
  AuthController(this.repository, this.api) {
    api.sessionToken = () => repository.accessToken;
    api.onExpired = (token) {
      if (token == repository.accessToken) unawaited(logout(expired: true));
    };
    _subscription = repository.events.listen(
      _onAuthEvent,
      onError: _onAuthError,
    );
  }

  final AuthGateway repository;
  final ApiClient api;
  SessionState state = SessionState.restoring;
  Map<String, dynamic>? user;
  String? error;
  String? notice;
  bool busy = false;
  bool isPasswordRecovery = false;
  int generation = 0;
  bool _disposed = false;
  late final StreamSubscription<AuthEvent> _subscription;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  void _acceptSession() {
    final current = repository.currentUser;
    if (!repository.hasSession || current == null) {
      state = SessionState.signedOut;
      user = null;
    } else {
      final changedAccount =
          state != SessionState.signedIn || user?['id'] != current['id'];
      user = current;
      state = SessionState.signedIn;
      isPasswordRecovery = false;
      if (changedAccount) generation++;
    }
  }

  void _onAuthEvent(AuthEvent event) {
    switch (event) {
      case AuthEvent.initialSession:
        return;
      case AuthEvent.passwordRecovery:
        isPasswordRecovery = true;
        user = null;
        state = SessionState.signedOut;
        generation++;
      case AuthEvent.signedOut:
        user = null;
        isPasswordRecovery = false;
        state = SessionState.signedOut;
        generation++;
      case AuthEvent.signedIn:
      case AuthEvent.tokenRefreshed:
      case AuthEvent.userUpdated:
        if (!isPasswordRecovery && repository.hasSession) _acceptSession();
    }
    _notify();
  }

  void _onAuthError(Object _) {
    error = 'Không hoàn tất được xác thực. Hãy thử lại.';
    if (!repository.hasSession) state = SessionState.signedOut;
    _notify();
  }

  Future<void> restore() async {
    state = SessionState.restoring;
    error = null;
    _notify();
    try {
      await Future<void>.value();
      if (isPasswordRecovery) return;
      _acceptSession();
    } on Exception {
      state = SessionState.unavailable;
      error = 'Không khôi phục được phiên. Hãy thử lại.';
    }
    _notify();
  }

  Future<bool> _operation(Future<bool> Function() action) async {
    if (busy) return false;
    busy = true;
    error = null;
    notice = null;
    _notify();
    try {
      return await action();
    } on AuthException catch (e) {
      final message = e.message.toLowerCase();
      error = message.contains('invalid login credentials')
          ? 'Email hoặc mật khẩu không đúng.'
          : message.contains('already registered') ||
                message.contains('already exists')
          ? 'Email này đã được đăng ký.'
          : message.contains('email not confirmed')
          ? 'Hãy xác minh email trước khi đăng nhập.'
          : 'Không hoàn tất được thao tác xác thực. Hãy thử lại.';
      return false;
    } on ApiException catch (e) {
      error = e.message;
      return false;
    } on Exception {
      error = 'Không kết nối được dịch vụ. Kiểm tra mạng rồi thử lại.';
      return false;
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<bool> passwordLogin(String email, String password) =>
      _operation(() async {
        await repository.passwordLogin(email.trim(), password);
        _acceptSession();
        return state == SessionState.signedIn;
      });

  Future<bool> register(String name, String email, String password) =>
      _operation(() async {
        final hasSession = await repository.register(
          name.trim(),
          email.trim(),
          password,
        );
        if (hasSession) {
          _acceptSession();
        } else {
          notice =
              'Đã tạo yêu cầu đăng ký. Hãy mở email xác minh rồi đăng nhập.';
          state = SessionState.signedOut;
        }
        return true;
      });

  Future<bool> googleLogin() => _operation(() async {
    final started = await repository.googleLogin();
    if (!started) notice = 'Đăng nhập Google đã bị hủy.';
    return started;
  });

  Future<bool> forgot(String email) => _operation(() async {
    await repository.forgot(email.trim());
    notice = 'Nếu email đã đăng ký, hướng dẫn khôi phục mật khẩu sẽ được gửi đến hộp thư.';
    return true;
  });

  Future<bool> reset(String password) => _operation(() async {
    await repository.reset(password);
    isPasswordRecovery = false;
    _acceptSession();
    return state == SessionState.signedIn;
  });

  Future<bool> resendVerification(String email) => _operation(() async {
    await repository.resendVerification(email);
    notice = 'Đã yêu cầu gửi lại email xác minh.';
    return true;
  });

  Future<bool> updateProfile(Map<String, dynamic> values) =>
      _operation(() async {
        await repository.updateProfile(values);
        _acceptSession();
        notice = 'Đã cập nhật hồ sơ. Nếu đổi email, hãy xác minh địa chỉ mới.';
        return true;
      });

  Future<bool> linkGoogle(String _) => _operation(() async {
    final started = await repository.linkGoogle();
    if (started) notice = 'Đã mở trang Google để liên kết tài khoản.';
    return started;
  });

  Future<void> logout({bool expired = false}) async {
    error = expired ? 'Phiên đã hết hạn. Vui lòng đăng nhập lại.' : null;
    try {
      await repository.signOut();
    } on Exception {
      error = 'Đã xóa phiên trên thiết bị; máy chủ chưa xác nhận đăng xuất.';
    }
    user = null;
    isPasswordRecovery = false;
    state = SessionState.signedOut;
    generation++;
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    api.onExpired = null;
    _subscription.cancel();
    super.dispose();
  }
}
