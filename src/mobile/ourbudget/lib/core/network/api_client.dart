import 'dart:convert';
import 'dart:io';

import '../config/api_config.dart';

class ApiException implements Exception {
  const ApiException(
    this.status,
    this.code,
    this.message, [
    this.fields = const {},
  ]);
  final int status;
  final String code;
  final String message;
  final Map<String, dynamic> fields;
}

class ApiClient {
  ApiClient(this.config);
  final ApiConfig config;
  String? Function()? sessionToken;
  void Function(String token)? onExpired;

  Future<Map<String, dynamic>> send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    String? explicitToken,
  }) async {
    final token =
        explicitToken ?? (authenticated ? sessionToken?.call() : null);
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.openUrl(
        method,
        config.endpoint(path.split('/')),
      );
      request.headers.contentType = ContentType.json;
      if (token != null) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');
      }
      if (body != null) request.write(jsonEncode(body));
      final response = await request.close().timeout(
        const Duration(seconds: 15),
      );
      final raw = await response
          .transform(utf8.decoder)
          .join()
          .timeout(const Duration(seconds: 15));
      final json = jsonDecode(raw) as Map<String, dynamic>;
      if (response.statusCode >= 400) {
        final error = json['error'] as Map<String, dynamic>;
        if (response.statusCode == 401 &&
            error['code'] == 'unauthenticated' &&
            token != null) {
          onExpired?.call(token);
        }
        throw ApiException(
          response.statusCode,
          error['code'] as String,
          error['message'] as String,
          Map<String, dynamic>.from(error['fields'] as Map),
        );
      }
      return Map<String, dynamic>.from(json['data'] as Map);
    } on ApiException {
      rethrow;
    } on Exception {
      throw const ApiException(
        0,
        'network_unavailable',
        'Không kết nối được máy chủ. Kiểm tra mạng rồi thử lại.',
      );
    } finally {
      client.close(force: true);
    }
  }
}
