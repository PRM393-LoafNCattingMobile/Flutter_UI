import 'package:flutter_test/flutter_test.dart';
import 'package:loafncatting_mobile/features/admin/widgets/admin_widgets.dart';

void main() {
  test('admin date-time formatter converts UTC values to local time', () {
    final utc = DateTime.utc(2026, 7, 14, 6, 5);
    final local = utc.toLocal();

    String two(int value) => value.toString().padLeft(2, '0');
    final expected = '${two(local.day)}/${two(local.month)}/${local.year} '
        '${two(local.hour)}:${two(local.minute)}';

    expect(formatAdminDateTime(utc), expected);
  });
}
