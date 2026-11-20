import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

final _vietnam = _loadVietnam();

tz.Location _loadVietnam() {
  tz_data.initializeTimeZones();
  return tz.getLocation('Asia/Ho_Chi_Minh');
}

final _integer = RegExp(r'^-?[0-9]+$');
final _offset = RegExp(r'T.+(?:Z|[+-][0-9]{2}:[0-9]{2})$');

BigInt decodeVnd(Object? value) {
  if (value is! String || !_integer.hasMatch(value)) {
    throw const FormatException('Số tiền phải là chuỗi số nguyên VND.');
  }
  return BigInt.parse(value);
}

String formatVnd(BigInt amount, {bool showPlus = false}) {
  final digits = amount.abs().toString();
  final groups = <String>[];
  for (var end = digits.length; end > 0; end -= 3) {
    groups.add(digits.substring(end < 3 ? 0 : end - 3, end));
  }
  final sign = amount.isNegative
      ? '−'
      : (showPlus && amount > BigInt.zero ? '+' : '');
  return '$sign${groups.reversed.join('.')} đ';
}

DateTime decodeVietnamTime(Object? value) {
  if (value is! String || !_offset.hasMatch(value)) {
    throw const FormatException('Thời điểm phải có độ lệch múi giờ.');
  }
  return vietnamTime(DateTime.parse(value));
}

tz.TZDateTime vietnamTime(DateTime instant) =>
    tz.TZDateTime.from(instant, _vietnam);

DateTime vietnamDateTime(DateTime day, int hour, int minute) =>
    tz.TZDateTime(_vietnam, day.year, day.month, day.day, hour, minute);

String encodeVietnamTime(DateTime instant) {
  final local = vietnamTime(instant);
  final offsetMinutes = local.timeZoneOffset.inMinutes;
  final sign = offsetMinutes < 0 ? '-' : '+';
  final absolute = offsetMinutes.abs();
  return '${DateTime.utc(local.year, local.month, local.day, local.hour, local.minute, local.second, local.millisecond, local.microsecond).toIso8601String().replaceFirst(RegExp(r'Z$'), '')}'
      '$sign${_two(absolute ~/ 60)}:${_two(absolute % 60)}';
}

String _two(int value) => value.toString().padLeft(2, '0');

String displayDate(DateTime instant) {
  final date = vietnamTime(instant);
  return '${_two(date.day)}/${_two(date.month)}/${date.year}';
}

String displayTime(DateTime instant) {
  final time = vietnamTime(instant);
  return '${_two(time.hour)}:${_two(time.minute)}';
}
