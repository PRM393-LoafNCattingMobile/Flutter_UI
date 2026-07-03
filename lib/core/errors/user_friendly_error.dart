import 'package:loafncatting_mobile/services/api_service.dart';

const _networkMessage =
    'Không kết nối được máy chủ. Vui lòng kiểm tra kết nối và thử lại.';
const _temporaryServerMessage =
    'Máy chủ đang tạm thời gián đoạn. Vui lòng thử lại sau.';
const _serverErrorMessage = 'Hệ thống đang gặp sự cố. Vui lòng thử lại sau.';
const _notFoundMessage = 'Không tìm thấy nội dung này.';
const _sessionExpiredMessage =
    'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
const _invalidRequestMessage = 'Thông tin chưa hợp lệ. Vui lòng kiểm tra lại.';
const _genericMessage = 'Đã có lỗi xảy ra. Vui lòng thử lại sau.';

String friendlyErrorMessage(Object? error) {
  final statusCode = error is ApiException ? error.statusCode : null;
  final rawMessage =
      error is ApiException ? error.message : error?.toString() ?? '';
  final normalized = _normalize(rawMessage);

  final businessMessage = _businessMessage(normalized);
  if (businessMessage != null) {
    return businessMessage;
  }

  if (_looksLikeNetworkError(normalized)) {
    return _networkMessage;
  }

  if (_looksLikeTemporaryServerError(normalized) ||
      statusCode == 502 ||
      statusCode == 503 ||
      statusCode == 504) {
    return _temporaryServerMessage;
  }

  if (_looksLikeServerException(normalized) ||
      (statusCode != null && statusCode >= 500)) {
    return _serverErrorMessage;
  }

  if (statusCode == 401 || statusCode == 403) {
    return _sessionExpiredMessage;
  }

  if (statusCode == 404) {
    return _notFoundMessage;
  }

  if (statusCode == 400 || statusCode == 409 || statusCode == 422) {
    return _invalidRequestMessage;
  }

  if (normalized.isEmpty) {
    return _genericMessage;
  }

  return _genericMessage;
}

String _normalize(String message) {
  return message
      .trim()
      .replaceFirst(
          RegExp(r'^(exception|apiexception):\s*', caseSensitive: false), '')
      .toLowerCase();
}

String? _businessMessage(String message) {
  if (message.contains('invalid login credentials')) {
    return 'Email, số điện thoại hoặc mật khẩu chưa đúng.';
  }
  if (message.contains('email address is not verified')) {
    return 'Tài khoản này chưa xác minh email. Vui lòng kiểm tra email để lấy mã xác minh.';
  }
  if (message.contains('email or phone number already exists')) {
    return 'Email hoặc số điện thoại này đã được sử dụng.';
  }
  if (message.contains('invalid or expired verification code')) {
    return 'Mã xác minh không đúng hoặc đã hết hạn.';
  }
  if (message.contains('account not found') ||
      message.contains('email is already verified')) {
    return 'Không tìm thấy tài khoản, hoặc email đã được xác minh.';
  }
  if (message.contains('product is unavailable') ||
      message.contains('out of stock')) {
    return 'Món này hiện đã hết hàng.';
  }
  if (message.contains('product was not found') ||
      message.contains('product data is invalid')) {
    return 'Không tìm thấy món này hoặc thông tin món chưa hợp lệ.';
  }
  if (message.contains('order could not be created')) {
    return 'Chưa thể tạo đơn. Vui lòng kiểm tra lại giỏ hàng.';
  }
  if (message.contains('order was not found')) {
    return 'Không tìm thấy đơn hàng này.';
  }
  if (message.contains('cannot create payment link')) {
    return 'Chưa thể tạo liên kết thanh toán. Vui lòng thử lại.';
  }
  if (message.contains('payment') || message.contains('payos')) {
    return 'Chưa thể xử lý thanh toán. Vui lòng thử lại sau.';
  }
  if (message.contains('table is not available')) {
    return 'Bàn này không còn trống vào thời gian đã chọn.';
  }
  if (message.contains('table was not found') ||
      message.contains('table data is invalid')) {
    return 'Không tìm thấy bàn này hoặc thông tin bàn chưa hợp lệ.';
  }
  if (message.contains('reservation was not found')) {
    return 'Không tìm thấy lượt đặt bàn này.';
  }
  if (message.contains('status transition is invalid')) {
    return 'Trạng thái hiện tại không thể cập nhật theo cách này.';
  }
  if (message.contains('category was not found') ||
      message.contains('category data is invalid')) {
    return 'Không tìm thấy danh mục này hoặc thông tin danh mục chưa hợp lệ.';
  }
  if (message.contains('cat was not found') ||
      message.contains('cat data is invalid')) {
    return 'Không tìm thấy thông tin mèo này hoặc dữ liệu chưa hợp lệ.';
  }
  if (message.contains('store location was not found')) {
    return 'Chưa có thông tin vị trí cửa hàng.';
  }
  if (message.contains('staff data is invalid') ||
      message.contains('user was not found')) {
    return 'Không thể cập nhật tài khoản này. Vui lòng kiểm tra lại thông tin.';
  }
  if (message.contains('conversation not found')) {
    return 'Không tìm thấy cuộc trò chuyện này.';
  }
  if (message.contains('not allowed') ||
      message.contains('forbid') ||
      message.contains('forbidden') ||
      message.contains('session role is not allowed')) {
    return 'Bạn không có quyền thực hiện thao tác này.';
  }
  if (message.contains('missing session token') ||
      message.contains('session is invalid') ||
      message.contains('session does not match')) {
    return _sessionExpiredMessage;
  }
  if (message == 'not found' || message.contains('notfound')) {
    return _notFoundMessage;
  }
  return null;
}

bool _looksLikeNetworkError(String message) {
  return message.contains('socketexception') ||
      message.contains('clientexception') ||
      message.contains('connection refused') ||
      message.contains('failed host lookup') ||
      message.contains('network is unreachable') ||
      message.contains('connection reset') ||
      message.contains('connection timed out') ||
      message.contains('timed out') ||
      message.contains('xmlhttprequest error');
}

bool _looksLikeTemporaryServerError(String message) {
  return message.contains('502') ||
      message.contains('503') ||
      message.contains('504') ||
      message.contains('bad gateway') ||
      message.contains('service unavailable') ||
      message.contains('gateway timeout');
}

bool _looksLikeServerException(String message) {
  return message.contains('sqlexception') ||
      message.contains('dbupdateexception') ||
      message.contains('invalidoperationexception') ||
      message.contains('nullreferenceexception') ||
      message.contains('stack trace') ||
      message.contains(' at microsoft.') ||
      message.contains(' at system.') ||
      message.contains('<html') ||
      message.contains('<!doctype');
}
