import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:loafncatting_mobile/core/errors/user_friendly_error.dart';
import 'package:loafncatting_mobile/providers/app_state.dart';
import 'package:loafncatting_mobile/services/api_service.dart';

void main() {
  group('friendlyErrorMessage', () {
    test('maps connection failures to a network message', () {
      final message = friendlyErrorMessage(
        const SocketException('Connection refused'),
      );

      expect(
        message,
        'Không kết nối được máy chủ. Vui lòng kiểm tra kết nối và thử lại.',
      );
    });

    test('maps login failures to friendly Vietnamese copy', () {
      final message = friendlyErrorMessage(
        ApiException('Invalid login credentials.', statusCode: 401),
      );

      expect(message, 'Email, số điện thoại hoặc mật khẩu chưa đúng.');
    });

    test('maps known backend business errors by message', () {
      expect(
        friendlyErrorMessage(ApiException(
          'Email or phone number already exists.',
          statusCode: 409,
        )),
        'Email hoặc số điện thoại này đã được sử dụng.',
      );
      expect(
        friendlyErrorMessage(ApiException(
          'Product is unavailable or out of stock.',
          statusCode: 400,
        )),
        'Món này hiện đã hết hàng.',
      );
      expect(
        friendlyErrorMessage(ApiException(
          'Table is not available for the selected time.',
          statusCode: 400,
        )),
        'Bàn này không còn trống vào thời gian đã chọn.',
      );
    });

    test('maps raw status and server details without leaking technical text',
        () {
      expect(
        friendlyErrorMessage(
          ApiException('<html>502 Bad Gateway</html>', statusCode: 502),
        ),
        'Máy chủ đang tạm thời gián đoạn. Vui lòng thử lại sau.',
      );
      expect(
        friendlyErrorMessage(ApiException('Not Found', statusCode: 404)),
        'Không tìm thấy nội dung này.',
      );
      expect(
        friendlyErrorMessage(ApiException(
          'Microsoft.Data.SqlClient.SqlException: Invalid object name Products',
          statusCode: 500,
        )),
        'Hệ thống đang gặp sự cố. Vui lòng thử lại sau.',
      );
    });
  });

  test('LoadableProvider stores friendly errors instead of raw exceptions',
      () async {
    final provider = LoadableProvider();

    await provider.run(() async {
      throw ApiException('Invalid login credentials.', statusCode: 401);
    });

    expect(provider.error, 'Email, số điện thoại hoặc mật khẩu chưa đúng.');
  });
}
