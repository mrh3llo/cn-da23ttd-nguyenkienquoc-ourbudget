import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ourbudget/core/config/api_config.dart';
import 'package:ourbudget/core/network/api_failure.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Android reaches PHP and MySQL through the shared API prefix', (
    tester,
  ) async {
    const config = ApiConfig();
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 10);
    try {
      final request = await client.getUrl(config.endpoint(['health']));
      final response = await request.close();
      final json = jsonDecode(
        await response.transform(utf8.decoder).join(),
      ) as Map<String, dynamic>;
      expect(response.statusCode, 200);
      expect(json['data']['database'], 'ok');
      expect(json['data']['schema'], 'report-standardized-sign-amount');
      expect(json['meta']['request_id'], matches(r'^[a-f0-9]{32}$'));

      final missing = await client.getUrl(config.endpoint(['does-not-exist']));
      final missingResponse = await missing.close();
      await missingResponse.drain<void>();
      expect(
        ApiFailure.fromStatus(missingResponse.statusCode),
        ApiFailure.notFound,
      );
    } finally {
      client.close(force: true);
    }
  });
}
