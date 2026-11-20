import 'package:flutter_test/flutter_test.dart';
import 'package:ourbudget/core/config/api_config.dart';
import 'package:ourbudget/core/format/finance_format.dart';
import 'package:ourbudget/core/network/api_failure.dart';
import 'package:ourbudget/features/transactions/data/transaction_repository.dart';

void main() {
  test('giải mã BIGINT và thời điểm qua ranh giới ngày Việt Nam', () {
    final entry = TransactionEntry.fromJson({
      'id': '1',
      'category': 'Lương',
      'wallet_id': 'bank',
      'amount': '9223372036854775807',
      'occurred_at': '2026-11-30T18:00:00Z',
    });
    expect(entry.amount.toString(), '9223372036854775807');
    expect(formatVnd(entry.amount), '9.223.372.036.854.775.807 đ');
    expect(displayDate(entry.occurredAt), '01/12/2026');
    expect(displayTime(entry.occurredAt), '01:00');
    expect(
      encodeVietnamTime(entry.occurredAt),
      '2026-12-01T01:00:00.000+07:00',
    );
    expect(decodeVietnamTime('2026-11-30T10:00:00-08:00'), entry.occurredAt);
    expect(() => decodeVnd('25000.00'), throwsFormatException);
    expect(() => decodeVnd(25000), throwsFormatException);
    expect(
      () => decodeVietnamTime('2026-11-30T18:00:00'),
      throwsFormatException,
    );
  });

  test('tập trung tiền tố API và ánh xạ lỗi HTTP', () {
    final uri = const ApiConfig(baseUrl: 'https://example.invalid/')
        .endpoint(['transactions']);
    expect(uri.path, '/api/v1/transactions');
    expect(
      () =>
          const ApiConfig(baseUrl: 'https://example.invalid/api/v1')
              .endpoint([]),
      throwsFormatException,
    );
    expect(ApiFailure.fromStatus(401), ApiFailure.sessionExpired);
    expect(ApiFailure.fromStatus(404), ApiFailure.notFound);
    expect(ApiFailure.fromStatus(409), ApiFailure.conflict);
    expect(ApiFailure.fromStatus(422), ApiFailure.invalidInput);
    expect(ApiFailure.fromStatus(500), ApiFailure.unavailable);
  });
}
