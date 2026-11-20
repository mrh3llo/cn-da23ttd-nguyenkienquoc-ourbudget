import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ourbudget/core/format/finance_format.dart';
import 'package:ourbudget/core/network/api_failure.dart';
import 'package:ourbudget/features/transactions/data/transaction_repository.dart';

void main() {
  test('shared PHP fixtures preserve money, dates and HTTP failure types', () {
    final fixtures = jsonDecode(
      File('../../contracts/http-fixtures.json').readAsStringSync(),
    ) as List<dynamic>;
    final entry = TransactionEntry.fromJson(fixtures.first['body']['data']);
    expect(entry.amount.toString(), '9223372036854775807');
    expect(displayDate(entry.occurredAt), '01/12/2026');
    const expected = {
      401: ApiFailure.sessionExpired,
      404: ApiFailure.notFound,
      409: ApiFailure.conflict,
      422: ApiFailure.invalidInput,
      500: ApiFailure.unavailable,
    };
    for (final fixture in fixtures.skip(1)) {
      final status = fixture['status'] as int;
      expect(ApiFailure.fromStatus(status), expected[status]);
      expect(fixture['body']['error']['fields'], isA<Map<String, dynamic>>());
    }
    expect(fixtures[4]['body']['error']['fields']['amount'], isNotEmpty);
  });
}
